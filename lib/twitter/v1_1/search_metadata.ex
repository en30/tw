defmodule Twitter.V1_1.SearchMetadata do
  @moduledoc """
  Struct for search result metadata from GET /search/tweets.json.
  https://developer.twitter.com/en/docs/twitter-api/v1/tweets/search/api-reference/get-search-tweets
  """

  import Twitter.V1_1.Schema, only: :macros

  defobject("priv/schema/model/search_metadata.json")
end
