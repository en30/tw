defmodule Tw.V1_1.TweetTest do
  alias Tw.V1_1.Tweet
  alias Tw.V1_1.User

  use ExUnit.Case, async: true

  import Tw.V1_1.EndpointHelper
  import Tw.V1_1.Fixture

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
            {:get, "https://api.twitter.com/1.1/statuses/home_timeline.json?count=10&tweet_mode=extended", ""},
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
            {:get, "https://api.twitter.com/1.1/statuses/user_timeline.json?count=9&tweet_mode=extended", ""},
            json_response(200, File.read!("test/support/fixtures/v1_1/tweets.json"))
          }
        ])

      assert {:ok, [%Tweet{} | _]} = Tweet.user_timeline(client, %{count: 9})
    end

    test "accepts user param as User" do
      user = user_fixture()

      client =
        stub_client([
          {
            {:get, "https://api.twitter.com/1.1/statuses/user_timeline.json?tweet_mode=extended&user_id=#{user.id}"},
            json_response(200, File.read!("test/support/fixtures/v1_1/tweets.json"))
          }
        ])

      assert {:ok, [%Tweet{} | _]} = Tweet.user_timeline(client, %{user: user})
    end
  end

  describe "mentions_timeline/2" do
    test "requets /statuses/mentions_timeline.json and returns tweets" do
      client =
        stub_client([
          {
            {:get, "https://api.twitter.com/1.1/statuses/mentions_timeline.json?count=8&tweet_mode=extended", ""},
            json_response(200, File.read!("test/support/fixtures/v1_1/tweets.json"))
          }
        ])

      assert {:ok, [%Tweet{} | _]} = Tweet.mentions_timeline(client, %{count: 8})
    end
  end

  describe "search/2" do
    test "requests /search/tweets.json" do
      client =
        stub_client([
          {
            {:get, "https://api.twitter.com/1.1/search/tweets.json?q=nasa&result_type=popular&tweet_mode=extended"},
            json_response(200, File.read!("test/support/fixtures/v1_1/search_tweets.json"))
          }
        ])

      assert {:ok, %{statuses: [%Tweet{} | _]}} = Tweet.search(client, %{q: "nasa", result_type: :popular})
    end

    test "encodes paramters" do
      client =
        stub_client([
          {
            {:get,
             "https://api.twitter.com/1.1/search/tweets.json?geocode=37.781157%2C-122.39872%2C1mi&q=nasa&tweet_mode=extended&until=2015-07-19"},
            json_response(200, File.read!("test/support/fixtures/v1_1/search_tweets.json"))
          }
        ])

      assert {:ok, _} =
               Tweet.search(client, %{q: "nasa", geocode: {37.781157, -122.398720, "1mi"}, until: ~D[2015-07-19]})
    end
  end

  describe "favorites/2" do
    test "requets /favorites/list.json and returns tweets" do
      client =
        stub_client([
          {
            {:get, "https://api.twitter.com/1.1/favorites/list.json?count=8&tweet_mode=extended", ""},
            json_response(200, File.read!("test/support/fixtures/v1_1/tweets.json"))
          }
        ])

      assert {:ok, [%Tweet{} | _]} = Tweet.favorites(client, %{count: 8})
    end

    test "accepts user param as User" do
      user = user_fixture()

      client =
        stub_client([
          {
            {:get, "https://api.twitter.com/1.1/favorites/list.json?tweet_mode=extended&user_id=#{user.id}"},
            json_response(200, File.read!("test/support/fixtures/v1_1/tweets.json"))
          }
        ])

      assert {:ok, [%Tweet{} | _]} = Tweet.favorites(client, %{user: user})
    end
  end

  describe "of_list/2" do
    test "requets /lists/statuses.json and returns tweets" do
      client =
        stub_client([
          {
            {:get,
             "https://api.twitter.com/1.1/lists/statuses.json?count=1&owner_screen_name=MLS&slug=teams&tweet_mode=extended",
             ""},
            json_response(200, File.read!("test/support/fixtures/v1_1/tweets.json"))
          }
        ])

      assert {:ok, [%Tweet{} | _]} = Tweet.of_list(client, %{slug: "teams", owner_screen_name: "MLS", count: 1})
    end

    test "accepts list param as List" do
      list = list_fixture()

      client =
        stub_client([
          {
            {:get, "https://api.twitter.com/1.1/lists/statuses.json?list_id=#{list.id}&tweet_mode=extended"},
            json_response(200, File.read!("test/support/fixtures/v1_1/tweets.json"))
          }
        ])

      assert {:ok, [%Tweet{} | _]} = Tweet.of_list(client, %{list: list})
    end
  end

  test "list/2 requets /statuses/lookup.json and returns tweets" do
    client =
      stub_client([
        {
          {:get, "https://api.twitter.com/1.1/statuses/lookup.json?id=1%2C2%2C3&tweet_mode=extended"},
          json_response(200, File.read!("test/support/fixtures/v1_1/tweets.json"))
        }
      ])

    assert {:ok, [%Tweet{} | _]} = Tweet.list(client, %{tweet_ids: [1, 2, 3]})
  end

  describe "retweets/2" do
    test "requets /statuses/retweets/:id.json and returns tweets" do
      client =
        stub_client([
          {
            {:get, "https://api.twitter.com/1.1/statuses/retweets/1128692733353218048.json?tweet_mode=extended", ""},
            json_response(200, File.read!("test/support/fixtures/v1_1/tweets.json"))
          }
        ])

      assert {:ok, [%Tweet{} | _]} = Tweet.retweets(client, %{tweet_id: 1_128_692_733_353_218_048})
    end

    test "accepts tweet param as Tweet" do
      tweet = tweet_fixture()

      client =
        stub_client([
          {
            {:get, "https://api.twitter.com/1.1/statuses/retweets/#{tweet.id}.json?tweet_mode=extended"},
            json_response(200, File.read!("test/support/fixtures/v1_1/tweets.json"))
          }
        ])

      assert {:ok, [%Tweet{} | _]} = Tweet.retweets(client, %{tweet: tweet})
    end
  end

  test "get/2 requets /statuses/show/:id.json and returns tweets" do
    client =
      stub_client([
        {
          {:get, "https://api.twitter.com/1.1/statuses/show/210462857140252672.json?tweet_mode=extended"},
          json_response(200, File.read!("test/support/fixtures/v1_1/tweet.json"))
        }
      ])

    assert {:ok, %Tweet{}} = Tweet.get(client, %{tweet_id: 210_462_857_140_252_672})
  end

  test "oembed/2 requets /statuses/oembed.json and returns tweets" do
    client =
      stub_client([
        {
          {:get,
           "https://api.twitter.com/1.1/statuses/oembed.json?url=https%3A%2F%2Ftwitter.com%2FInterior%2Fstatus%2F507185938620219395"},
          json_response(200, File.read!("test/support/fixtures/v1_1/statuses_oembed.json"))
        }
      ])

    assert {:ok, %{html: _}} = Tweet.oembed(client, %{url: "https://twitter.com/Interior/status/507185938620219395"})
  end

  test "create/2 requets /statuses/show/:id.json and returns tweets" do
    client =
      stub_client([
        {
          {:post, "https://api.twitter.com/1.1/statuses/update.json",
           "exclude_reply_user_ids=786491%2C54931584&media_ids=471592142565957632&status=Test+tweet+using+the+POST+statuses%2Fupdate+endpoint&tweet_mode=extended"},
          json_response(200, File.read!("test/support/fixtures/v1_1/tweet.json"))
        }
      ])

    assert {:ok, %Tweet{}} =
             Tweet.create(client, %{
               status: "Test tweet using the POST statuses/update endpoint",
               media_ids: [471_592_142_565_957_632],
               exclude_reply_user_ids: [786_491, 54_931_584]
             })
  end

  describe "delete/2" do
    test "requests to /statuses/destroy/:id.json" do
      client =
        stub_client([
          {
            {:post, "https://api.twitter.com/1.1/statuses/destroy/240854986559455234.json", "tweet_mode=extended"},
            json_response(200, File.read!("test/support/fixtures/v1_1/tweet.json"))
          }
        ])

      assert {:ok, %Tweet{}} = Tweet.delete(client, %{tweet_id: 240_854_986_559_455_234})
    end

    test "accepts the tweet paramter as Tweet" do
      tweet = tweet_fixture()

      client =
        stub_client([
          {
            {:post, "https://api.twitter.com/1.1/statuses/destroy/#{tweet.id}.json", "tweet_mode=extended"},
            json_response(200, File.read!("test/support/fixtures/v1_1/tweet.json"))
          }
        ])

      assert {:ok, %Tweet{}} = Tweet.delete(client, %{tweet: tweet})
    end
  end

  describe "retweet/2" do
    test "requests to /statuses/retweet/:id.json" do
      client =
        stub_client([
          {
            {:post, "https://api.twitter.com/1.1/statuses/retweet/240854986559455234.json", "tweet_mode=extended"},
            json_response(200, File.read!("test/support/fixtures/v1_1/tweet.json"))
          }
        ])

      assert {:ok, %Tweet{}} = Tweet.retweet(client, %{tweet_id: 240_854_986_559_455_234})
    end

    test "accepts the tweet paramter as Tweet" do
      tweet = tweet_fixture()

      client =
        stub_client([
          {
            {:post, "https://api.twitter.com/1.1/statuses/retweet/#{tweet.id}.json", "tweet_mode=extended"},
            json_response(200, File.read!("test/support/fixtures/v1_1/tweet.json"))
          }
        ])

      assert {:ok, %Tweet{}} = Tweet.retweet(client, %{tweet: tweet})
    end
  end

  describe "unretweet/2" do
    test "requests to /statuses/unretweet/:id.json" do
      client =
        stub_client([
          {
            {:post, "https://api.twitter.com/1.1/statuses/unretweet/240854986559455234.json", "tweet_mode=extended"},
            json_response(200, File.read!("test/support/fixtures/v1_1/tweet.json"))
          }
        ])

      assert {:ok, %Tweet{}} = Tweet.unretweet(client, %{tweet_id: 240_854_986_559_455_234})
    end

    test "accepts the tweet paramter as Tweet" do
      tweet = tweet_fixture()

      client =
        stub_client([
          {
            {:post, "https://api.twitter.com/1.1/statuses/unretweet/#{tweet.id}.json", "tweet_mode=extended"},
            json_response(200, File.read!("test/support/fixtures/v1_1/tweet.json"))
          }
        ])

      assert {:ok, %Tweet{}} = Tweet.unretweet(client, %{tweet: tweet})
    end
  end

  describe "favorite/2" do
    test "requests to /favorites/create.json" do
      client =
        stub_client([
          {
            {:post, "https://api.twitter.com/1.1/favorites/create.json", "id=240854986559455234&tweet_mode=extended"},
            json_response(200, File.read!("test/support/fixtures/v1_1/tweet.json"))
          }
        ])

      assert {:ok, %Tweet{}} = Tweet.favorite(client, %{tweet_id: 240_854_986_559_455_234})
    end

    test "accepts the tweet paramter as Tweet" do
      tweet = tweet_fixture()

      client =
        stub_client([
          {
            {:post, "https://api.twitter.com/1.1/favorites/create.json", "id=#{tweet.id}&tweet_mode=extended"},
            json_response(200, File.read!("test/support/fixtures/v1_1/tweet.json"))
          }
        ])

      assert {:ok, %Tweet{}} = Tweet.favorite(client, %{tweet: tweet})
    end
  end

  describe "unfavorite/2" do
    test "requests to /favorites/destroy.json" do
      client =
        stub_client([
          {
            {:post, "https://api.twitter.com/1.1/favorites/destroy.json", "id=240854986559455234&tweet_mode=extended"},
            json_response(200, File.read!("test/support/fixtures/v1_1/tweet.json"))
          }
        ])

      assert {:ok, %Tweet{}} = Tweet.unfavorite(client, %{tweet_id: 240_854_986_559_455_234})
    end

    test "accepts the tweet paramter as Tweet" do
      tweet = tweet_fixture()

      client =
        stub_client([
          {
            {:post, "https://api.twitter.com/1.1/favorites/destroy.json", "id=#{tweet.id}&tweet_mode=extended"},
            json_response(200, File.read!("test/support/fixtures/v1_1/tweet.json"))
          }
        ])

      assert {:ok, %Tweet{}} = Tweet.unfavorite(client, %{tweet: tweet})
    end
  end
end
