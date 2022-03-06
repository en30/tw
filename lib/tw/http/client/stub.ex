defmodule Tw.HTTP.Client.Stub do
  @moduledoc """
  Stub HTTP client adapter mainly for testing.
  """

  @behaviour Tw.HTTP.Client

  @type stub :: {{atom(), binary(), binary() | Regex.t()} | {atom(), binary()}, Tw.HTTP.Client.response()}
  @type stubs :: list(stub())

  @impl Tw.HTTP.Client
  def request(method, url, _headers, body, opts) do
    case pop(opts[:pid]) do
      {{^method, ^url}, resp} ->
        {:ok, resp}

      {{^method, ^url, ^body}, resp} ->
        {:ok, resp}

      {{^method, ^url, %Regex{} = body_pat}, resp} ->
        if Regex.match?(body_pat, body) do
          {:ok, resp}
        else
          raise "Stubbed body does not match with the pattern.\npattern:\n#{Regex.source(body_pat)}\n\nbody:\n#{body}"
        end

      stub ->
        raise "Unstubbed request to #{method} #{url} with body:\n#{body}\n\nCurrent stub: #{inspect(stub)}"
    end
  end

  use GenServer

  # Client

  def start_link(default) do
    GenServer.start_link(__MODULE__, default)
  end

  def pop(pid) do
    GenServer.call(pid, :pop)
  end

  # Server (callbacks)

  @impl GenServer
  def init(stubs) do
    {:ok, stubs}
  end

  @impl GenServer
  def handle_call(:pop, _from, [head | tail]) do
    {:reply, head, tail}
  end

  @impl GenServer
  def handle_call(:pop, _from, []) do
    {:reply, nil, []}
  end
end
