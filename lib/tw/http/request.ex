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
    %__MODULE__{
      method: method,
      uri: uri,
      headers: headers,
      body: body
    }
  end

  @spec add_header(t, binary, binary) :: t
  def add_header(%__MODULE__{headers: headers} = request, key, value) do
    %{request | headers: [{key, value} | headers]}
  end
end
