defmodule Tw.V1_1.SearchResult do
  @moduledoc """
  Struct for search result from GET /search/tweets.json.
  https://developer.twitter.com/en/docs/twitter-api/v1/tweets/search/api-reference/get-search-tweets
  """

  alias Tw.V1_1.SearchMetadata
  alias Tw.V1_1.Tweet

  @enforce_keys [:statuses, :search_metadata]
  defstruct([:statuses, :search_metadata])

  @type t :: %__MODULE__{statuses: list(Tweet.t()), search_metadata: SearchMetadata.t()}
  @spec decode!(map) :: t
  @doc """
  Decode JSON-decoded map into `t:t/0`
  """
  def decode!(json) do
    json =
      json
      |> Map.update!(:statuses, fn v -> Enum.map(v, &Tweet.decode!/1) end)
      |> Map.update!(:search_metadata, &SearchMetadata.decode!/1)

    struct(__MODULE__, json)
  end

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
    |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
    |> Map.new()
  end
end
