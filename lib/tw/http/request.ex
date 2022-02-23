defmodule Tw.HTTP.Request do
  @moduledoc false

  defstruct [:method, :uri, :headers, :body]

  @type t :: %__MODULE__{
          method: atom,
          uri: URI.t(),
          headers: list({binary, binary}),
          body: nil | binary
        }

  @spec new(atom, URI.t()) :: t
  def new(method, uri) do
    %__MODULE__{
      method: method,
      uri: uri,
      headers: [],
      body: ""
    }
  end

  @spec new(atom, URI.t(), list({binary, binary}), binary) :: t
  def new(method, uri, headers, body) do
    base = %__MODULE__{
      method: method,
      uri: uri,
      headers: [],
      body: body
    }

    headers
    |> Enum.reduce(base, fn {k, v}, a -> add_header(a, k, v) end)
  end

  @spec add_header(t, binary, binary) :: t
  def add_header(%__MODULE__{headers: headers} = request, key, value) do
    %{request | headers: [{String.downcase(key), value} | headers]}
  end

  @spec get_header(t, binary) :: list(binary())
  @doc false
  def get_header(%__MODULE__{} = request, key) do
    request.headers
    |> Enum.reduce([], fn
      {^key, value}, a -> [value | a]
      _, a -> a
    end)
    |> Enum.reverse()
  end
end
