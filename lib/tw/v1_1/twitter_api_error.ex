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

  def from_response(response, %{errors: errors}) when errors != [] do
    [%{message: message} | _] = errors
    exception(message: message, errors: errors, response: response)
  end

  def from_response(response, _), do: exception(message: "Unknown Twitter API Error", errors: [], response: response)

  @spec rate_limit_exceeded?(t()) :: boolean
  def rate_limit_exceeded?(%__MODULE__{} = error) do
    error.response.status == 429 && Enum.any?(error.errors, &(&1.code == 88))
  end

  for {name, code} <- [
        no_user_matched?: 17,
        resource_not_found?: 34,
        user_not_found?: 50,
        member_not_found?: 108,
        subscriber_not_found?: 109
      ] do
    @spec unquote(name)(t()) :: boolean
    def unquote(name)(%__MODULE__{} = error) do
      Enum.any?(error.errors, &(&1.code == unquote(code)))
    end
  end

  @doc """
  Return `DateTime` when the rate limit is reset.
  If the given error is not related to rate limiting, return `nil`.
  """
  @spec rate_limit_reset_at(t()) :: DateTime.t() | nil
  def rate_limit_reset_at(%__MODULE__{} = error) do
    with [v] <- Response.get_header(error.response, "x-rate-limit-reset"),
         {unix, ""} <- Integer.parse(v),
         {:ok, dt} <- DateTime.from_unix(unix, :second) do
      dt
    else
      _ -> nil
    end
  end

  @doc """
  Return time until rate limit is reset in milliseconds.
  If the given error is not related to rate limiting, return `nil`.

  ## Examples
      TwitterAPIError.rate_limit_reset_in(error)
      |> Process.sleep()
  """
  @spec rate_limit_reset_in(t()) :: non_neg_integer() | nil
  def rate_limit_reset_in(%__MODULE__{} = error, base_fn \\ fn -> DateTime.utc_now() |> DateTime.to_unix(:second) end) do
    with [v] <- Response.get_header(error.response, "x-rate-limit-reset"),
         {target, ""} <- Integer.parse(v) do
      :timer.seconds(target - base_fn.())
    else
      _ -> nil
    end
  end
end
