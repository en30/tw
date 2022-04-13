defmodule Tw.OAuth.V1_0a.Credentials do
  @moduledoc """
  Data structure for OAuth 1.0a credentials.
  """

  @derive {Inspect, only: []}
  defstruct [:consumer_key, :consumer_secret, :access_token, :access_token_secret]

  @type t :: %__MODULE__{
          consumer_key: binary,
          consumer_secret: binary,
          access_token: binary,
          access_token_secret: binary
        }

  def new(opts), do: struct!(__MODULE__, opts)
end
