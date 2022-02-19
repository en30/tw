defmodule Tw.V1_1.TweetTest do
  alias Tw.V1_1.Tweet
  alias Tw.V1_1.User

  use ExUnit.Case, async: true

  @deprecated_keys ~W[
    geo
  ]

  # from https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/example-payloads
  @files ~W[
    test/support/fixtures/v1_1/tweet.json
    test/support/fixtures/v1_1/tweet_reply.json
    test/support/fixtures/v1_1/extended_tweet.json
    test/support/fixtures/v1_1/extended_tweet_with_tweet_mode_extended.json
    test/support/fixtures/v1_1/tweet_with_extended_entities_with_tweet_mode_extended.json
    test/support/fixtures/v1_1/retweet.json
    test/support/fixtures/v1_1/retweet_with_tweet_mode_extended.json
    test/support/fixtures/v1_1/quote_tweet.json
    test/support/fixtures/v1_1/quote_tweet_with_tweet_mode_extended.json
    test/support/fixtures/v1_1/retweeted_quote_tweet_with_tweet_mode_extended.json
    test/support/fixtures/v1_1/retweeted_quote_tweet.json
  ] |> Enum.map(&{Path.basename(&1), &1})

  for {name, path} <- @files do
    describe "decode(#{name})" do
      setup do
        json = File.read!(unquote(path)) |> Jason.decode!()
        tweet = json |> Tweet.decode()
        %{tweet: tweet, json: json}
      end

      test "creates a Tweet struct", %{tweet: tweet} do
        assert %Tweet{} = tweet
      end

      test "decodes created_at into DateTime", %{tweet: tweet} do
        assert %DateTime{} = tweet.created_at
      end

      test "decodes user into User", %{tweet: tweet} do
        assert %User{} = tweet.user
      end

      test "uses all keys of the json", %{tweet: tweet, json: json} do
        for {key, _value} <- json, !Enum.member?(@deprecated_keys, key) do
          assert Map.has_key?(tweet, String.to_atom(key))
        end
      end
    end
  end
end
