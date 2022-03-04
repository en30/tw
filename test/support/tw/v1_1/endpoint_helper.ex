defmodule Tw.V1_1.EndpointHelper do
  @moduledoc false

  alias Tw.HTTP
  alias Tw.OAuth.V1_0a.Credentials
  alias Tw.V1_1.Client

  @spec stub_client(HTTP.Client.Stub.stubs()) :: Client.t()
  def stub_client(stubs) do
    credentials =
      Credentials.new(
        consumer_key: "xxx",
        consumer_secret: "xxx",
        access_token: "xxx",
        access_token_secret: "xxx"
      )

    Client.new(
      http_client: {HTTP.Client.Stub, [stubs: stubs]},
      credentials: credentials
    )
  end

  def json_response(status, body) do
    %{
      status: status,
      headers: [{"content-type", "application/json"}],
      body: body
    }
  end
end
