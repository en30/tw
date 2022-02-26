defmodule Tw.V1_1.User do
  @moduledoc """
  User data structure and related functions.
  https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/user
  """

  import Tw.V1_1.Schema, only: :macros

  @type id :: pos_integer()

  defobject("priv/schema/model/user.json")

  map_endpoint(:get, "/account/verify_credentials.json", to: me)
  map_endpoint(:get, "/users/show.json", to: find)
  map_endpoint(:get, "/users/lookup.json", to: list)
  map_endpoint(:get, "/users/search.json", to: search)
  map_endpoint(:get, "/followers/ids.json", to: follower_ids)
  map_endpoint(:get, "/friends/ids.json", to: friend_ids)
  map_endpoint(:get, "/followers/list.json", to: followers)
  map_endpoint(:get, "/friends/list.json", to: friends)
  map_endpoint(:get, "/blocks/ids.json", to: blocking_ids)
  map_endpoint(:get, "/blocks/list.json", to: blocking_users)
  map_endpoint(:get, "/mutes/users/ids.json", to: muting_ids)
  map_endpoint(:get, "/mutes/users/list.json", to: muting_users)
  map_endpoint(:get, "/statuses/retweeters/ids.json", to: retweeter_ids)
  map_endpoint(:get, "/lists/members.json", to: list_members)
  map_endpoint(:get, "/lists/subscribers.json", to: list_subscribers)
  map_endpoint(:post, "/blocks/create.json", to: block)
  map_endpoint(:post, "/blocks/destroy.json", to: unblock)
  map_endpoint(:post, "/mutes/users/create.json", to: mute)
  map_endpoint(:post, "/mutes/users/destroy.json", to: unmute)
  map_endpoint(:post, "/users/report_spam.json", to: report_spam)
  map_endpoint(:post, "/friendships/create.json", to: follow)
  map_endpoint(:post, "/friendships/destroy.json", to: unfollow)
end
