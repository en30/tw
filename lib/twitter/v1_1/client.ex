defmodule Twitter.V1_1.Client do
  @moduledoc """
  Client for Twitter API v1.1.
  """

  alias Twitter.HTTP
  alias Twitter.OAuth

  @base_uri URI.parse("https://api.twitter.com/1.1")

  defstruct [:http_client, :credentials]

  def new(opts), do: struct!(__MODULE__, opts)

  def request(client, method, path, query_params \\ []) do
    uri =
      @base_uri
      |> URI.merge(%URI{
        path: Path.join(@base_uri.path, path),
        query: URI.encode_query(query_params)
      })

    req =
      HTTP.Request.new(method, uri)
      |> sign(client.credentials)

    HTTP.Client.request(client.http_client, req, [])
  end

  defp sign(%HTTP.Request{} = request, credentials) do
    params = Twitter.OAuth.V1_0a.params(credentials)

    value =
      OAuth.V1_0a.signature(request, credentials, params)
      |> OAuth.V1_0a.authorization_header_value(params)

    request
    |> HTTP.Request.add_header("Authorization", value)
  end
end
