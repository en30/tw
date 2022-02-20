defmodule Tw.V1_1.Tweet do
  @moduledoc """
  Tweet data structure and related functions.
  https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/tweet
  """

  import Tw.V1_1.Schema, only: :macros

  defobject("priv/schema/model/tweet.json")

  map_endpoint(:get, "/statuses/home_timeline.json", to: home_timeline)
  map_endpoint(:get, "/statuses/user_timeline.json", to: user_timeline)
  map_endpoint(:get, "/statuses/mentions_timeline.json", to: mentions_timeline)
  map_endpoint(:get, "/search/tweets.json", to: search)
  map_endpoint(:get, "/favorites/list.json", to: favorites)
  map_endpoint(:get, "/lists/statuses.json", to: of_list)
  map_endpoint(:get, "/statuses/lookup.json", to: list)
  map_endpoint(:get, "/statuses/retweets_of_me.json", to: retweets_of_me)
end
