defmodule Tw.V1_1.SearchResult do
  @moduledoc """
  Struct for search result from GET /search/tweets.json.
  https://developer.twitter.com/en/docs/twitter-api/v1/tweets/search/api-reference/get-search-tweets
  """

  import Tw.V1_1.Schema, only: :macros

  defobject("priv/schema/model/search_result.json")

  @spec next_params(t) :: Tw.V1_1.Tweet.search_params()
  @doc """
  Returns the next search params from a search result.

  ```
  {:ok, res} = Tw.V1_1.Tweet.search(client, %{q: "twitter"})
  next_params = Tw.V1_1.SearchResult.next_params(res)
  {:ok, next_res} = Tw.V1_1.Tweet.search(client, next_params)
  ```
  """
  def next_params(%__MODULE__{} = search_result) do
    search_result.search_metadata.next_results
    |> String.trim_leading("?")
    |> URI.decode_query()
    |> Enum.map(fn {k, v} -> {String.to_existing_atom(k), v} end)
    |> Map.new()
  end
end
