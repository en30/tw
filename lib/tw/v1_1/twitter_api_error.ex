defmodule Tw.V1_1.TwitterAPIError do
  @moduledoc """
  `Exception` which wraps an error response from Twitter API.

  See [the Twitter API documentation](https://developer.twitter.com/docs/basics/response-codes) for details.
  """

  defexception [:message, :errors, :response]

  alias Tw.HTTP.Response

  @type t :: %__MODULE__{
          __exception__: true,
          message: binary(),
          errors: list(%{message: binary(), code: pos_integer()}),
          response: Response.t()
        }

  @spec from_response(Response.t(), iodata() | nil) :: t
  @doc false
  def from_response(response, decoded_body)

  def from_response(response, %{"errors" => errors}) when errors != [] do
    errors = [%{message: message} | _] = Enum.map(errors, fn e -> %{message: e["message"], code: e["code"]} end)
    exception(message: message, errors: errors, response: response)
  end

  def from_response(response, _), do: exception(message: "Unknown Twitter API Error", errors: [], response: response)

  def rate_limit_exceeded?(%__MODULE__{} = error) do
    error.response.status == 429 && Enum.any?(error.errors, &(&1.code == 88))
  end

  def rate_limit_reset_at(%__MODULE__{} = error) do
    with [v] <- Response.get_header(error.response, "x-rate-limit-reset"),
         {unix, ""} <- Integer.parse(v),
         {:ok, dt} <- DateTime.from_unix(unix, :second) do
      dt
    else
      _ -> nil
    end
  end
end
