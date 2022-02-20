defmodule Tw.V1_1.Friendship do
  @moduledoc """
  Module for `friendships/*` endpoints.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/follow-search-get-users/api-reference/get-friendships-show) for details.
  """

  import Tw.V1_1.Schema, only: :macros

  defobject("priv/schema/model/friendship_relationship.json")

  map_endpoint(:get, "/friendships/incoming.json", to: pending_incoming_requests)
  map_endpoint(:get, "/friendships/outgoing.json", to: pending_outgoing_requests)
  map_endpoint(:get, "/friendships/no_retweets/ids.json", to: no_retweet_ids)
  map_endpoint(:get, "/friendships/lookup.json", to: list)
  map_endpoint(:get, "/friendships/show.json", to: find)
  map_endpoint(:post, "/friendships/create.json", to: create)
  map_endpoint(:post, "/friendships/destroy.json", to: destroy)
  map_endpoint(:post, "/friendships/update.json", to: update)
end
