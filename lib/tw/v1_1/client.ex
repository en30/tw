defmodule Tw.V1_1.Client do
  @moduledoc """
  Client for Twitter API v1.1.
  """

  alias Tw.HTTP
  alias Tw.OAuth
  alias Tw.V1_1.TwitterAPIError

  @base_uri URI.parse("https://api.twitter.com/1.1")

  defstruct [:http_client, :credentials]

  @type t :: %__MODULE__{
          http_client: HTTP.Client,
          credentials: OAuth.V1_0a.Credentials.t()
        }

  @spec new(keyword) :: t
  def new(opts), do: struct!(__MODULE__, opts)

  @spec request(t, atom, binary, keyword) :: {:ok, HTTP.Response.t()} | {:error, TwitterAPIError.t()}
  def request(client, method, path, params \\ []) do
    req =
      build(method, path, params)
      |> sign(client.credentials)

    case HTTP.Client.request(client.http_client, req, []) do
      {:ok, %{status: status} = resp} when status < 400 ->
        {:ok, resp}

      {:ok, error_resp} ->
        {:error, TwitterAPIError.from_response(error_resp)}

      {:error, error} ->
        {:error, error}
    end
  end

  defp build(:get, path, params) do
    {path, params} = embed_path_params(path, params)

    uri =
      @base_uri
      |> URI.merge(%URI{
        path: Path.join(@base_uri.path, path),
        query: encode_query_params(params)
      })

    HTTP.Request.new(:get, uri)
  end

  defp build(method, path, params) do
    {path, params} = embed_path_params(path, params)

    uri =
      @base_uri
      |> URI.merge(%URI{
        path: Path.join(@base_uri.path, path)
      })

    HTTP.Request.new(
      method,
      uri,
      [{"content-type", "application/x-www-form-urlencoded; charset=UTF-8"}],
      URI.encode_query(params, :www_form)
    )
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
    |> Enum.map(fn
      {k, v} when is_list(v) -> {k, Enum.join(v, ",")}
      {k, v} -> {k, v}
    end)
    |> URI.encode_query(:rfc3986)
  end

  defp embed_path_params(path, query_params) do
    Path.split(path)
    |> Enum.filter(&String.starts_with?(&1, ":"))
    |> Enum.map(&Path.basename(&1, ".json"))
    |> Enum.reduce({path, query_params}, fn ":" <> name = e, {path, params} ->
      key = String.to_existing_atom(name)

      {
        String.replace(path, e, Keyword.fetch!(params, key) |> to_string()),
        params |> Keyword.delete(key)
      }
    end)
  end
end
