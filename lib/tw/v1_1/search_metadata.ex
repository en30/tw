defmodule Tw.V1_1.SearchMetadata do
  @moduledoc """
  Struct for search result metadata from GET /search/tweets.json.
  https://developer.twitter.com/en/docs/twitter-api/v1/tweets/search/api-reference/get-search-tweets
  """

  @enforce_keys [:completed_in, :max_id, :max_id_str, :next_results, :query, :count, :since_id, :since_id_str]
  defstruct([:completed_in, :max_id, :max_id_str, :next_results, :query, :count, :since_id, :since_id_str])

  @type t :: %__MODULE__{
          completed_in: float,
          max_id: integer,
          max_id_str: binary,
          next_results: binary,
          query: binary,
          count: integer,
          since_id: integer,
          since_id_str: binary
        }
  @spec decode!(map) :: t
  @doc """
  Decode JSON-decoded map into `t:t/0`
  """
  def decode!(json), do: struct(__MODULE__, json)
end
