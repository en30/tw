defmodule Tw.URLTest do
  alias Tw.URL

  use ExUnit.Case, async: true

  import Tw.V1_1.Fixture

  test "user/1 returns user url" do
    assert URL.user(1) == "https://twitter.com/i/user/1"

    user = user_fixture()
    assert URL.user(user) == "https://twitter.com/i/user/#{user.id}"
  end

  test "tweet/1 returns tweet url" do
    assert URL.tweet(1) == "https://twitter.com/i/web/status/1"

    tweet = tweet_fixture()
    assert URL.tweet(tweet) == "https://twitter.com/i/web/status/#{tweet.id}"
  end

  test "list/1 returns list url" do
    assert URL.list(1) == "https://twitter.com/i/lists/1"

    list = list_fixture()
    assert URL.list(list) == "https://twitter.com/i/lists/#{list.id}"
  end

  test "search/1 returns search url" do
    assert URL.search(%{q: "test"}) == "https://twitter.com/search?q=test"
  end

  test "hashtag/1 returns hashtag url" do
    assert URL.hashtag("test") == "https://twitter.com/hashtag/test"
  end

  test "new_tweet/1 returns new tweet url" do
    assert URL.new_tweet(%{text: "test"}) == "https://twitter.com/intent/tweet?text=test"
  end

  test "new_retweet/1 returns new retweet url" do
    tweet = tweet_fixture()

    assert URL.new_retweet(%{tweet: tweet}) == "https://twitter.com/intent/retweet?tweet_id=#{tweet.id}"

    assert URL.new_retweet(%{tweet_id: 1}) == "https://twitter.com/intent/retweet?tweet_id=1"
  end

  test "new_like/1 returns new like url" do
    tweet = tweet_fixture()

    assert URL.new_like(%{tweet: tweet}) == "https://twitter.com/intent/like?tweet_id=#{tweet.id}"

    assert URL.new_like(%{tweet_id: 1}) == "https://twitter.com/intent/like?tweet_id=1"
  end

  test "new_follow/1 returns new follow url" do
    user = user_fixture()

    assert URL.new_follow(%{user: user}) == "https://twitter.com/intent/follow?user_id=#{user.id}"
    assert URL.new_follow(%{user_id: user.id}) == "https://twitter.com/intent/follow?user_id=#{user.id}"

    assert URL.new_follow(%{screen_name: user.screen_name}) ==
             "https://twitter.com/intent/follow?screen_name=#{user.screen_name}"
  end

  test "switch_account/0 returns switch account url" do
    assert URL.switch_account() == "https://twitter.com/account/switch"
  end
end
