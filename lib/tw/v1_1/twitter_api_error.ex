defmodule Tw.V1_1.TwitterAPIError do
  @moduledoc """
  `Exception` which wraps an error response from Twitter API.

  See [the Twitter API documentation](https://developer.twitter.com/docs/basics/response-codes) for details.
  """

  defexception [:message, :errors, :response]

  @type t :: %__MODULE__{
          __exception__: true,
          message: binary(),
          errors: list(%{message: binary(), code: pos_integer()}),
          response: Tw.HTTP.Client.response()
        }

  @spec from_response(Tw.HTTP.Client.response()) :: t
  @doc false
  def from_response(response) do
    case Jason.decode(response.body) do
      {:ok, %{"errors" => errors}} when errors != [] > 0 ->
        errors = [%{message: message} | _] = Enum.map(errors, fn e -> %{message: e["message"], code: e["code"]} end)
        exception(message: message, errors: errors, response: response)

      _ ->
        exception(message: "Unknown Twitter API Error", errors: [], response: response)
    end
  end
end
