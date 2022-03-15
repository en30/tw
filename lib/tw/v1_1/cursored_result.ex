defmodule Tw.V1_1.CursoredResult.StreamError do
  @moduledoc """
  Wrap the error that occurred in `Tw.V1_1.CursedResult.stream!/3`.
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

  alias Tw.V1_1.CursoredResult.StreamError
  alias Tw.V1_1.TwitterAPIError

  @type cursor :: integer()

  @type t(key, type) :: %{
          key => type,
          next_cursor: cursor(),
          next_cursor_str: binary(),
          previous_cursor: cursor(),
          previous_cursor_str: binary()
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

      iex> Tw.V1_1.CursoredResult.stream!(:ids, fn cursor -> Tw.V1_1.User.fllower_ids(client, %{screen_name: "twitterapi", cursor: cursor} end)
      ...> |> Enum.each(&IO.inspect/1)

      iex> Tw.V1_1.CursoredResult.stream!(:ids, fn cursor -> Tw.V1_1.User.fllower_ids(client, %{screen_name: "twitterapi", cursor: cursor} end)
      ...> |> Stream.run()
      ** (Tw.V1_1.CursoredResult.StreamError) Rate limit exceeded

  """
  @spec stream!(atom(), (integer -> {:ok, map} | {:error, Exception.t()}), integer()) :: Enumerable.t()
  def stream!(key, func, initial_cursor \\ -1) do
    Stream.unfold(
      initial_cursor,
      fn
        0 ->
          nil

        cursor ->
          case func.(cursor) do
            {:ok, res} ->
              {Map.get(res, key), res.next_cursor}

            {:error, error} ->
              raise StreamError.exception(cursor: cursor, error: error)
          end
      end
    )
    |> Stream.flat_map(&Function.identity/1)
  end

  @doc """
  Return cursored endpoints results as `Stream`.
  If the rate limit is exceeded, sleep and retry.

  ## Examples

      iex> Tw.V1_1.CursoredResult.persevering_stream!(:ids, fn cursor -> Tw.V1_1.User.fllower_ids(client, %{screen_name: "twitterapi", cursor: cursor}) end)
      ...> |> Enum.each(&IO.inspect/1)


  """
  @spec persevering_stream!(atom(), (integer -> {:ok, map} | {:error, Exception.t()}), integer()) :: Enumerable.t()
  def persevering_stream!(key, func, initial_cursor \\ -1) do
    recursive_func = fn c ->
      g = fn
        0, _ ->
          nil

        cursor, f ->
          case func.(cursor) do
            {:ok, res} ->
              {Map.get(res, key), res.next_cursor}

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

    Stream.unfold(initial_cursor, recursive_func)
    |> Stream.flat_map(&Function.identity/1)
  end
end
