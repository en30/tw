defmodule Tw.HTTP.Client do
  @moduledoc """
  HTTP Client contract.
  """

  alias Tw.HTTP.Request
  alias Tw.HTTP.Response

  @type method :: atom()

  @type url :: binary()

  @type status :: non_neg_integer()

  @type header :: {binary(), binary()}

  @type body :: binary()

  @type response :: %{status: status, headers: [header()], body: body}

  @type result :: {:ok, response()} | {:error, Exception.t()}

  @type options :: keyword()

  @typedoc """
  Module which implements the Tw.HTTP.Client behavior.
  """
  @type implementation :: module()

  @doc """
  Callback to make an HTTP request.
  """
  @callback request(method(), url(), [header()], body(), options()) :: result

  @doc false
  @spec request(atom, Request.t(), options()) :: {:ok, Response.t()} | {:error, Exception.t()}
  def request(module, request, opts) do
    case module.request(
           request.method,
           request.uri |> URI.to_string(),
           request.headers,
           request.body,
           opts
         ) do
      {:ok, response} -> {:ok, response |> Keyword.new() |> Response.new()}
      {:error, error} -> {:error, error}
    end
  end
end
