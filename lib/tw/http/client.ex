defmodule Tw.HTTP.Client do
  @moduledoc """
  HTTP Client contract.
  """

  @type method :: atom()

  @type url :: binary()

  @type status :: non_neg_integer()

  @type header :: {binary(), binary()}

  @type body :: binary()

  @type response :: %{status: status, headers: [header()], body: body}

  @type result :: {:ok, response()} | {:error, Exception.t()}

  @doc """
  Callback to make an HTTP request.
  """
  @callback request(method(), url(), [header()], body(), opts :: keyword()) :: result

  @doc false
  @spec request(atom, Tw.HTTP.Request.t(), keyword) :: result
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
