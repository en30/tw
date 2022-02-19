defmodule Tw.V1_1.FriendshipLookupResult do
  @moduledoc """
  Struct for search result from GET /friendships/lookup.json.
  https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/follow-search-get-users/api-reference/get-friendships-lookup
  """

  import Tw.V1_1.Schema, only: :macros

  @connections ~W[following following_requested followed_by none blocking muting]
  def decode_connection(str) do
    if Enum.member?(@connections, str) do
      String.to_atom(str)
    else
      :unknown
    end
  end

  defobject("priv/schema/model/friendship_lookup_result.json")
end
