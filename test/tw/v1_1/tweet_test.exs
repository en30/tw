defmodule Tw.V1_1.TweetTest do
  alias Tw.V1_1.Tweet
  alias Tw.V1_1.User

  use ExUnit.Case, async: true

  import Tw.V1_1.EndpointHelper

  @deprecated_keys ~W[
    geo
  ]a

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
    describe "decode!(#{name})" do
      setup do
        json = File.read!(unquote(path)) |> Jason.decode!(keys: :atoms)
        tweet = json |> Tweet.decode!()
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
          assert Map.has_key?(tweet, key)
        end
      end
    end
  end

  describe "home_timeline/2" do
    test "requets /statuses/home_timeline.json and returns tweets" do
      client =
        stub_client([
          {
            {:get, "https://api.twitter.com/1.1/statuses/home_timeline.json?count=10", ""},
            json_response(200, File.read!("test/support/fixtures/v1_1/tweets.json"))
          }
        ])

      assert {:ok, [%Tweet{} | _]} = Tweet.home_timeline(client, %{count: 10})
    end
  end

  describe "user_timeline/2" do
    test "requets /statuses/user_timeline.json and returns tweets" do
      client =
        stub_client([
          {
            {:get, "https://api.twitter.com/1.1/statuses/user_timeline.json?count=9", ""},
            json_response(200, File.read!("test/support/fixtures/v1_1/tweets.json"))
          }
        ])

      assert {:ok, [%Tweet{} | _]} = Tweet.user_timeline(client, %{count: 9})
    end
  end

  describe "mentions_timeline/2" do
    test "requets /statuses/mentions_timeline.json and returns tweets" do
      client =
        stub_client([
          {
            {:get, "https://api.twitter.com/1.1/statuses/mentions_timeline.json?count=8", ""},
            json_response(200, File.read!("test/support/fixtures/v1_1/tweets.json"))
          }
        ])

      assert {:ok, [%Tweet{} | _]} = Tweet.mentions_timeline(client, %{count: 8})
    end
  end
end
