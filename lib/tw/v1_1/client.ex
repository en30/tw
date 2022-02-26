defmodule Tw.V1_1.Client do
  @moduledoc """
  Client for Twitter API v1.1.
  """

  alias Tw.HTTP
  alias Tw.OAuth
  alias Tw.V1_1.TwitterAPIError

  @base_uri URI.parse("https://api.twitter.com/1.1")
  @media_base_uri URI.parse("https://upload.twitter.com/1.1")

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

  defp build(method, path, params)

  defp build(:post, "/media/metadata/" <> _ = path, params), do: post_json_request(@media_base_uri, path, params)
  defp build(:post, "/media/subtitles/" <> _ = path, params), do: post_json_request(@media_base_uri, path, params)
  defp build(:post, "/media/upload" <> _ = path, params), do: post_multi_part_request(@media_base_uri, path, params)

  defp build(:get, path, params) do
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
      params |> Enum.map(&to_binary_value/1) |> URI.encode_query(:www_form)
    )
  end

  defp post_multi_part_request(base_uri, path, params) do
    {path, params} = embed_path_params(path, params)

    uri =
      base_uri
      |> URI.merge(%URI{
        path: Path.join(base_uri.path, path)
      })

    mp = HTTP.MultipartFormData.new(parts: params |> Enum.map(fn {k, v} -> to_binary_value({to_string(k), v}) end))

    HTTP.Request.new(
      :post,
      uri,
      [{"content-type", HTTP.MultipartFormData.content_type(mp)}],
      HTTP.MultipartFormData.encode(mp)
    )
  end

  defp post_json_request(base_uri, path, params) do
    {path, params} = embed_path_params(path, params)

    uri =
      base_uri
      |> URI.merge(%URI{
        path: Path.join(base_uri.path, path)
      })

    HTTP.Request.new(
      :post,
      uri,
      [{"content-type", "application/json; charset=UTF-8"}],
      params |> Map.new() |> Jason.encode!()
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

  defp to_binary_value({k, [e | _] = v}) when is_integer(e), do: {k, Enum.join(v, ",")}
  defp to_binary_value({k, v}) when is_binary(v), do: {k, v}
  defp to_binary_value({k, v}), do: {k, to_string(v)}

  defp encode_query_params(query_params) do
    query_params
    |> Enum.map(&to_binary_value/1)
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

  defp base_uri(path)
  defp base_uri("/media/" <> _), do: @media_base_uri
  defp base_uri(_), do: @base_uri
end
