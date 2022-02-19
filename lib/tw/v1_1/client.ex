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
  def request(client, method, path, query_params \\ []) do
    uri =
      @base_uri
      |> URI.merge(%URI{
        path: Path.join(@base_uri.path, path),
        query: URI.encode_query(query_params, :rfc3986)
      })

    req =
      HTTP.Request.new(method, uri)
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

  defp sign(%HTTP.Request{} = request, credentials) do
    params = OAuth.V1_0a.params(credentials)

    value =
      OAuth.V1_0a.signature(request, credentials, params)
      |> OAuth.V1_0a.authorization_header_value(params)

    request
    |> HTTP.Request.add_header("Authorization", value)
  end
end
