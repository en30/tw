defmodule Twitter.HTTP.Client do
  @moduledoc """
  Specification for a HTTP Client.
  """

  @type method() :: atom()

  @type url() :: String.t()

  @type status() :: non_neg_integer()

  @type header() :: {String.t(), String.t()}
  @type headers() :: list(header())

  @type body() :: String.t()

  @type client() :: map()

  @callback new(opts :: keyword()) :: client()
  @callback request(client(), method(), url(), headers(), body(), opts :: keyword()) ::
              {:ok, %{status: status(), headers: headers(), body: body()}} | {:error, term()}
end
