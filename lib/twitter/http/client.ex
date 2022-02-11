defmodule Twitter.HTTP.Client do
  @moduledoc """
  HTTP Client contract.
  """

  @type method() :: atom()

  @type url() :: binary()

  @type status() :: non_neg_integer()

  @type header() :: {binary(), binary()}

  @type body() :: binary()

  @doc """
  Callback to make an HTTP request.
  """
  @callback request(method(), url(), [header()], body(), opts :: keyword()) ::
              {:ok, %{status: status, headers: [header()], body: body()}}
              | {:error, Exception.t()}

  @doc false
  def request(module, request, opts) do
    module.request(
      request.method,
      request.uri |> URI.to_string(),
      request.headers,
      request.body,
      opts
    )
  end
end
