defmodule Tw.V1_1.Client do
  @moduledoc """
  Client for Twitter API v1.1.
  """

  alias Tw.HTTP
  alias Tw.JSON
  alias Tw.OAuth
  alias Tw.V1_1.TwitterAPIError

  @base_uri URI.parse("https://api.twitter.com/1.1")
  @media_base_uri URI.parse("https://upload.twitter.com/1.1")

  defstruct [:http_client, :credentials, :json]

  @type t :: %__MODULE__{
          http_client: {HTTP.Client.implementation(), HTTP.Client.options()},
          json: {JSON.Serializer.implementation(), JSON.Serializer.encode_options(), JSON.Serializer.decode_options()},
          credentials: OAuth.V1_0a.Credentials.t()
        }

  @type error :: TwitterAPIError.t() | Exception.t()

  @type new_opt ::
          {:http_client, {HTTP.Client.implementation(), HTTP.Client.options()}}
          | {:json,
             {JSON.Serializer.implementation(), JSON.Serializer.encode_options(), JSON.Serializer.decode_options()}}
          | {:credentials, OAuth.V1_0a.Credentials.t()}
  @spec new([new_opt()]) :: t
  def new(opts) do
    opts =
      opts
      |> Keyword.put_new_lazy(:http_client, fn -> {HTTP.Client.Hackney, []} end)
      # I trust Twitter API.
      |> Keyword.put_new_lazy(:json, fn -> {JSON.Serializer.Jason, [], [keys: :atoms]} end)

    struct!(__MODULE__, opts)
  end

  @spec decode_json(t, iodata, keyword()) :: {:ok, term} | {:error, Exception.t()}
  def decode_json(client, body, opts \\ []) do
    {serializer, _, default_opts} = client.json
    opts = Keyword.merge(default_opts, opts)
    serializer.decode(body, opts)
  end

  @spec request(t, atom, binary, %{atom => term}) ::
          {:ok, term()} | {:error, error()}
  def request(client, method, path, params \\ %{}) do
    req =
      build(client, method, path, params)
      |> sign(client.credentials)

    {mod, http_client_opts} = client.http_client

    case HTTP.Client.request(mod, req, http_client_opts) do
      {:ok, %{status: status} = resp} when status < 400 ->
        case HTTP.Response.get_header(resp, "content-type") do
          ["application/json" <> _] ->
            decode_json(client, resp.body)

          _ ->
            {:ok, resp.body}
        end

      {:ok, error_resp} ->
        error =
          case decode_json(client, error_resp.body) do
            {:ok, decoded} -> TwitterAPIError.from_response(error_resp, decoded)
            _ -> TwitterAPIError.from_response(error_resp, nil)
          end

        {:error, error}

      {:error, error} ->
        {:error, error}
    end
  end

  defp build(client, method, path, params)

  defp build(_client, :get, path, params) do
    {path, params} = embed_path_params(path, params)
    base_uri = base_uri(path)

    uri =
      base_uri
      |> URI.merge(%URI{
        path: Path.join(base_uri.path, path),
        query: encode_query_params(params)
      })

    HTTP.Request.new(:get, uri)
  end

  defp build(client, method, path, params) do
    {path, params} = embed_path_params(path, params)
    base_uri = base_uri(path)

    uri =
      base_uri
      |> URI.merge(%URI{
        path: Path.join(base_uri.path, path)
      })

    {content_type, body} = encode_body(client, method, path, params)

    HTTP.Request.new(
      method,
      uri,
      [{"content-type", content_type}],
      body
    )
  end

  defp encode_body(client, method, path, params)
  defp encode_body(client, :post, "/media/metadata/" <> _, params), do: encode_json_params(client, params)
  defp encode_body(client, :post, "/media/subtitles/" <> _, params), do: encode_json_params(client, params)

  defp encode_body(_client, :post, "/media/upload" <> _, params) do
    mp = HTTP.MultipartFormData.new(parts: params |> Enum.map(fn {k, v} -> {to_string(k), to_string(v)} end))
    {HTTP.MultipartFormData.content_type(mp), HTTP.MultipartFormData.encode(mp)}
  end

  defp encode_body(_client, _method, _path, params) do
    {
      "application/x-www-form-urlencoded; charset=UTF-8",
      params |> URI.encode_query(:www_form)
    }
  end

  defp encode_json_params(client, params) do
    {serializer, opts, _} = client.json
    {:ok, encoded} = serializer.encode(params, opts)
    {"application/json; charset=UTF-8", encoded}
  end

  defp sign(%HTTP.Request{} = request, credentials) do
    params = OAuth.V1_0a.params(credentials)

    value =
      OAuth.V1_0a.signature(request, credentials, params)
      |> OAuth.V1_0a.authorization_header_value(params)

    request
    |> HTTP.Request.add_header("Authorization", value)
  end

  defp encode_query_params(query_params) do
    query_params
    |> URI.encode_query(:rfc3986)
  end

  defp embed_path_params(path, query_params) do
    Path.split(path)
    |> Enum.filter(&String.starts_with?(&1, ":"))
    |> Enum.map(&Path.basename(&1, ".json"))
    |> Enum.reduce({path, query_params}, fn ":" <> name = e, {path, params} ->
      key = String.to_existing_atom(name)

      {
        String.replace(path, e, Map.fetch!(params, key) |> to_string()),
        params |> Map.delete(key)
      }
    end)
  end

  defp base_uri(path)
  defp base_uri("/media/" <> _), do: @media_base_uri
  defp base_uri(_), do: @base_uri
end
