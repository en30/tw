defmodule Tw.V1_1.User do
  @moduledoc """
  User data structure and related functions.
  https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/user
  """

  import Tw.V1_1.Schema, only: :macros

  defobject("priv/schema/model/user.json")

  map_endpoint(:get, "/users/show.json", to: find)
  map_endpoint(:get, "/followers/ids.json", to: follower_ids)
  map_endpoint(:get, "/friends/ids.json", to: friend_ids)
  map_endpoint(:get, "/followers/list.json", to: followers)
  map_endpoint(:get, "/friends/list.json", to: friends)
  map_endpoint(:get, "/friendships/incoming.json", to: pending_incoming_follow_requests)
  map_endpoint(:get, "/friendships/outgoing.json", to: pending_outgoing_follow_requests)
  map_endpoint(:get, "/friendships/no_retweets/ids.json", to: no_retweet_ids)
  map_endpoint(:get, "/friendships/lookup.json", to: list_friendships)
end
