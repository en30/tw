defmodule Twitter.HTTP.Request do
  @moduledoc """
  An internal data structure for HTTP request.
  """

  defstruct [:method, :uri, :headers, :body]

  alias Twitter.OAuth.V1_0a, as: OAuth

  @type t :: %__MODULE__{
          method: atom,
          uri: URI.t(),
          headers: list({binary, binary}),
          body: nil | binary
        }

  @spec add_header(t, binary, binary) :: t
  def add_header(%__MODULE__{headers: headers} = request, key, value) do
    %{request | headers: [{key, value} | headers]}
  end

  @doc """
  Add authorization header for OAuth 1.0a to a given request.
  """
  @spec sign(t, OAuth.credentials()) :: t
  def sign(%__MODULE__{} = request, credentials) do
    params = OAuth.params(credentials)

    value =
      OAuth.signature(request, credentials, params)
      |> OAuth.authorization_header_value(params)

    request
    |> add_header("Authorization", value)
  end
end
