defmodule Tw.V1_1.EndpointHelper do
  @moduledoc false

  alias Tw.HTTP
  alias Tw.OAuth.V1_0a.Credentials
  alias Tw.V1_1.Client

  @spec stub_client(HTTP.Client.Stub.stubs()) :: Client.t()
  def stub_client(stubs) do
    {:ok, pid} = ExUnit.Callbacks.start_supervised({HTTP.Client.Stub, stubs})

    credentials =
      Credentials.new(
        consumer_key: "xxx",
        consumer_secret: "xxx",
        access_token: "xxx",
        access_token_secret: "xxx"
      )

    Client.new(
      http_client: {HTTP.Client.Stub, [pid: pid]},
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

  def json_response(status, headers, body) do
    %{
      status: status,
      headers: [{"content-type", "application/json"} | headers],
      body: body
    }
  end

  def html_response(status, body) do
    %{
      status: status,
      headers: [{"content-type", "text/html; charset=UTF-8"}],
      body: body
    }
  end
end
