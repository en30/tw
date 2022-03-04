defmodule Tw.HTTP.Client.Stub do
  @moduledoc """
  Stub HTTP client adapter mainly for testing.
  """

  @behaviour Tw.HTTP.Client

  @type stubs :: %{
          {method :: atom(), url :: binary(), body :: binary()} => Tw.HTTP.Client.response()
        }

  @impl true
  def request(method, url, _headers, body, stubs: stubs) do
    stubs
    |> Enum.find(&match?({{^method, ^url, ^body}, _}, &1))
    |> case do
      nil ->
        raise "Unstubbed request to #{method} #{url} with body:\n#{body}"

      {_req, resp} ->
        {:ok, resp}
    end
  end
end
