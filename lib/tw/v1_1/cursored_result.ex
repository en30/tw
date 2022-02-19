defmodule Tw.V1_1.CursoredResult do
  @moduledoc """
  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/pagination) for details.
  """

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
end
