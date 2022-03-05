defmodule Tw.V1_1.CursoredResult.StreamError do
  @moduledoc """
  Wrap the error that occurred in `Tw.V1_1.CursedResult.stream!/4`.
  """
  defexception [:cursor, :message, :original_error]

  @impl true
  def exception(opts) do
    error = opts[:error]
    %__MODULE__{cursor: opts[:cursor], message: error.message, original_error: error}
  end
end

defmodule Tw.V1_1.CursoredResult do
  @moduledoc """
  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/pagination) for details.
  """

  alias Tw.V1_1.Client
  alias Tw.V1_1.CursoredResult.StreamError
  alias Tw.V1_1.TwitterAPIError

  @type t(key, type) :: %{
          key => type,
          next_cursor: integer,
          next_cursor_str: binary,
          previous_cursor: integer,
          previous_cursor_str: binary
        }

  @doc """
  Return if there is a next page from a cursor.

  ## Examples

      iex> {:ok, res} = Tw.V1_1.User.follower_ids(client)
      iex> Tw.V1_1.CursoredResult.has_next?(res)
      true
  """
  @spec has_next?(%{next_cursor: integer}) :: boolean()
  def has_next?(cursored_result) do
    cursored_result.next_cursor != 0
  end

  @doc """
  Return if there is a previous page from a cursor.

  ## Examples

      iex> {:ok, res} = Tw.V1_1.User.follower_ids(client)
      iex> Tw.V1_1.CursoredResult.has_previous?(res)
      false
  """
  @spec has_previous?(%{previous_cursor: integer}) :: boolean()
  def has_previous?(cursored_result) do
    cursored_result.previous_cursor != 0
  end

  @doc """
  Return cursored endpoints results as `Stream`.

  ## Examples

      iex> Tw.V1_1.CursoredResult.stream!(client, &Tw.V1_1.User.fllower_ids/2, %{screen_name: "twitterapi"}, :ids)
      ...> |> Enum.each(&IO.inspect/1)

      iex> Tw.V1_1.CursoredResult.stream!(client, &Tw.V1_1.User.fllower_ids/2, %{screen_name: "twitterapi"}, :ids)
      ...> |> Stream.run()
      ** (Tw.V1_1.CursoredResult.StreamError) Rate limit exceeded

  """
  @spec stream!(Client.t(), (Client.t(), map -> map), map, atom()) :: Enumerable.t()
  def stream!(client, func, params, keys) do
    Stream.resource(
      fn -> params[:cursor] || -1 end,
      fn
        0 ->
          {:halt, nil}

        cursor ->
          case func.(client, params |> Map.put(:cursor, cursor)) do
            {:ok, res} ->
              {Map.get(res, keys), res.next_cursor}

            {:error, error} ->
              raise StreamError.exception(cursor: cursor, error: error)
          end
      end,
      &Function.identity/1
    )
  end

  @doc """
  Return cursored endpoints results as `Stream`.
  If the rate limit is exceeded, sleep and retry.

  ## Examples

      iex> Tw.V1_1.CursoredResult.persevering_stream!(client, &Tw.V1_1.User.fllower_ids/2, %{screen_name: "twitterapi"}, :ids)
      ...> |> Enum.each(&IO.inspect/1)


  """
  @spec persevering_stream!(Client.t(), (Client.t(), map -> map), map, atom()) :: Enumerable.t()
  def persevering_stream!(client, func, params, keys) do
    next_fn = fn c ->
      g = fn
        0, _ ->
          {:halt, nil}

        cursor, f ->
          case func.(client, params |> Map.put(:cursor, cursor)) do
            {:ok, res} ->
              {Map.get(res, keys), res.next_cursor}

            {:error, %TwitterAPIError{} = error} ->
              if TwitterAPIError.rate_limit_exceeded?(error) do
                TwitterAPIError.rate_limit_reset_in(error)
                |> Process.sleep()

                f.(cursor, f)
              else
                raise StreamError.exception(cursor: cursor, error: error)
              end

            {:error, error} ->
              raise StreamError.exception(cursor: cursor, error: error)
          end
      end

      g.(c, g)
    end

    Stream.resource(
      fn -> params[:cursor] || -1 end,
      next_fn,
      &Function.identity/1
    )
  end
end
