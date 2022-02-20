defmodule Tw.V1_1.FriendshipSource do
  @moduledoc """
  Struct for result from GET /friendships/show.json.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/follow-search-get-users/api-reference/get-friendships-show) for details.
  """

  import Tw.V1_1.Schema, only: :macros

  defobject("priv/schema/model/friendship_source.json")
end
