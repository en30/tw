defmodule Tw.V1_1.UserTest do
  alias Tw.V1_1.User
  alias Tw.V1_1.UserEntities

  use ExUnit.Case, async: true

  import Tw.V1_1.EndpointHelper
  import Tw.V1_1.Fixture

  @deprecated_keys ~W[
    utc_offset
    time_zone
    lang
    geo_enabled
    following
    follow_request_sent
    has_extended_profile
    notifications
    profile_location
    contributors_enabled
    profile_image_url
    profile_background_color
    profile_background_image_url
    profile_background_image_url_https
    profile_background_tile
    profile_link_color
    profile_sidebar_border_color
    profile_sidebar_fill_color
    profile_text_color
    profile_use_background_image
    is_translator
    is_translation_enabled
    translator_type
  ]a

  # https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/user#:~:text=Example%20user%20object%3A
  @json_path "test/support/fixtures/v1_1/user.json"

  describe "decode!/1" do
    setup do
      json = @json_path |> File.read!() |> Jason.decode!(keys: :atoms)
      user = User.decode!(json)
      %{user: user, json: json}
    end

    test "create a User struct", %{user: user} do
      assert %User{} = user
    end

    test "decodes entities into UserEntities", %{user: user} do
      assert %UserEntities{} = user.entities
    end

    test "decodes created_at into DateTime", %{user: user} do
      assert ~U[2007-05-23 06:01:13Z] = user.created_at
    end

    test "uses all keys of the json", %{user: user, json: json} do
      for {key, _value} <- json, !Enum.member?(@deprecated_keys, key) do
        assert Map.has_key?(user, key)
      end
    end
  end

  test "get/2 requests to /users/show.json" do
    client =
      stub_client([
        {
          {:get, "https://api.twitter.com/1.1/users/show.json?screen_name=twitterapi"},
          json_response(200, File.read!("test/support/fixtures/v1_1/user.json"))
        }
      ])

    assert {:ok, %User{}} = User.get(client, %{screen_name: "twitterapi"})
  end

  test "get/2 returns {:ok, nil} if no user is found by the params" do
    client =
      stub_client([
        {
          {:get, "https://api.twitter.com/1.1/users/show.json?screen_name=twitterapiiiiiiiiiii"},
          json_response(404, ~s/{"errors":[{"code":50,"message":"User not found"}]}/)
        }
      ])

    assert {:ok, nil} = User.get(client, %{screen_name: "twitterapiiiiiiiiiii"})
  end

  test "list/2 requests to /users/lookup.json" do
    client =
      stub_client([
        {
          {:get, "https://api.twitter.com/1.1/users/lookup.json?screen_name=twitterapi"},
          json_response(200, File.read!("test/support/fixtures/v1_1/users.json"))
        }
      ])

    assert {:ok, [%User{} | _]} = User.list(client, %{screen_names: ["twitterapi"]})
  end

  test "list/2 returns {:ok, []} if no user is found by the params" do
    client =
      stub_client([
        {
          {:get, "https://api.twitter.com/1.1/users/lookup.json?screen_name=twitterapiiiiiiiiiii"},
          json_response(404, ~s/{"errors":[{"code":17,"message":"No user matches for specified terms."}]}/)
        }
      ])

    assert {:ok, []} = User.list(client, %{screen_names: ["twitterapiiiiiiiiiii"]})
  end

  test "search/2 requests to /users/search.json" do
    client =
      stub_client([
        {
          {:get, "https://api.twitter.com/1.1/users/search.json?q=Twitter%20API"},
          json_response(200, File.read!("test/support/fixtures/v1_1/users.json"))
        }
      ])

    assert {:ok, [%User{} | _]} = User.search(client, %{q: "Twitter API"})
  end

  test "follower_ids/2 requests to /followers/ids.json" do
    client =
      stub_client([
        {
          {:get, "https://api.twitter.com/1.1/followers/ids.json?screen_name=twitterdev"},
          json_response(200, """
          {
            "ids": [1, 2, 3],
            "next_cursor": 0,
            "next_cursor_str": "0",
            "previous_cursor": 0,
            "previous_cursor_str": "0"
          }
          """)
        }
      ])

    assert {:ok, %{ids: [1, 2, 3]}} = User.follower_ids(client, %{screen_name: "twitterdev"})
  end

  test "follower_ids/2 accests a User" do
    user = user_fixture()

    client =
      stub_client([
        {
          {:get, "https://api.twitter.com/1.1/followers/ids.json?user_id=#{user.id}"},
          json_response(200, """
          {
            "ids": [1, 2, 3],
            "next_cursor": 0,
            "next_cursor_str": "0",
            "previous_cursor": 0,
            "previous_cursor_str": "0"
          }
          """)
        }
      ])

    assert {:ok, %{ids: [1, 2, 3]}} = User.follower_ids(client, %{user: user})
  end

  test "friend_ids/2 requests to /friends/ids.json" do
    client =
      stub_client([
        {
          {:get, "https://api.twitter.com/1.1/friends/ids.json?screen_name=twitterdev"},
          json_response(200, """
          {
            "ids": [1, 2, 3],
            "next_cursor": 0,
            "next_cursor_str": "0",
            "previous_cursor": 0,
            "previous_cursor_str": "0"
          }
          """)
        }
      ])

    assert {:ok, %{ids: [1, 2, 3]}} = User.friend_ids(client, %{screen_name: "twitterdev"})
  end

  test "friend_ids/2 accepts a User" do
    user = user_fixture()

    client =
      stub_client([
        {
          {:get, "https://api.twitter.com/1.1/friends/ids.json?user_id=#{user.id}"},
          json_response(200, """
          {
            "ids": [1, 2, 3],
            "next_cursor": 0,
            "next_cursor_str": "0",
            "previous_cursor": 0,
            "previous_cursor_str": "0"
          }
          """)
        }
      ])

    assert {:ok, %{ids: [1, 2, 3]}} = User.friend_ids(client, %{user: user})
  end

  test "followers/2 requests to /followers/list.json" do
    client =
      stub_client([
        {
          {:get, "https://api.twitter.com/1.1/followers/list.json?screen_name=twitterdev"},
          json_response(200, """
          {
            "users": #{File.read!("test/support/fixtures/v1_1/users.json")},
            "next_cursor": 0,
            "next_cursor_str": "0",
            "previous_cursor": 0,
            "previous_cursor_str": "0"
          }
          """)
        }
      ])

    assert {:ok, %{users: [%User{} | _]}} = User.followers(client, %{screen_name: "twitterdev"})
  end

  test "followers/2 accespts a User" do
    user = user_fixture()

    client =
      stub_client([
        {
          {:get, "https://api.twitter.com/1.1/followers/list.json?user_id=#{user.id}"},
          json_response(200, """
          {
            "users": #{File.read!("test/support/fixtures/v1_1/users.json")},
            "next_cursor": 0,
            "next_cursor_str": "0",
            "previous_cursor": 0,
            "previous_cursor_str": "0"
          }
          """)
        }
      ])

    assert {:ok, %{users: [%User{} | _]}} = User.followers(client, %{user: user})
  end

  test "friends/2 requests to /friends/list.json" do
    client =
      stub_client([
        {
          {:get, "https://api.twitter.com/1.1/friends/list.json?screen_name=twitterdev"},
          json_response(200, """
          {
            "users": #{File.read!("test/support/fixtures/v1_1/users.json")},
            "next_cursor": 0,
            "next_cursor_str": "0",
            "previous_cursor": 0,
            "previous_cursor_str": "0"
          }
          """)
        }
      ])

    assert {:ok, %{users: [%User{} | _]}} = User.friends(client, %{screen_name: "twitterdev"})
  end

  test "friends/2 accespts a User" do
    user = user_fixture()

    client =
      stub_client([
        {
          {:get, "https://api.twitter.com/1.1/friends/list.json?user_id=#{user.id}"},
          json_response(200, """
          {
            "users": #{File.read!("test/support/fixtures/v1_1/users.json")},
            "next_cursor": 0,
            "next_cursor_str": "0",
            "previous_cursor": 0,
            "previous_cursor_str": "0"
          }
          """)
        }
      ])

    assert {:ok, %{users: [%User{} | _]}} = User.friends(client, %{user: user})
  end

  test "blocked_ids/2 requests to /blocks/ids.json" do
    client =
      stub_client([
        {
          {:get, "https://api.twitter.com/1.1/blocks/ids.json?count=10"},
          json_response(200, """
          {
            "ids": [1, 2, 3],
            "next_cursor": 0,
            "next_cursor_str": "0",
            "previous_cursor": 0,
            "previous_cursor_str": "0"
          }
          """)
        }
      ])

    assert {:ok, %{ids: [1, 2, 3]}} = User.blocked_ids(client, %{count: 10})
  end

  test "blocked/2 requests to /blocks/list.json" do
    client =
      stub_client([
        {
          {:get, "https://api.twitter.com/1.1/blocks/list.json?count=5"},
          json_response(200, """
          {
            "users": #{File.read!("test/support/fixtures/v1_1/users.json")},
            "next_cursor": 0,
            "next_cursor_str": "0",
            "previous_cursor": 0,
            "previous_cursor_str": "0"
          }
          """)
        }
      ])

    assert {:ok, %{users: [%User{} | _]}} = User.blocked(client, %{count: "5"})
  end

  test "muted_ids/2 requests to /mutes/users/ids.json" do
    client =
      stub_client([
        {
          {:get, "https://api.twitter.com/1.1/mutes/users/ids.json?count=10"},
          json_response(200, """
          {
            "ids": [1, 2, 3],
            "next_cursor": 0,
            "next_cursor_str": "0",
            "previous_cursor": 0,
            "previous_cursor_str": "0"
          }
          """)
        }
      ])

    assert {:ok, %{ids: [1, 2, 3]}} = User.muted_ids(client, %{count: 10})
  end

  test "muted/2 requests to /mutes/users/list.json" do
    client =
      stub_client([
        {
          {:get, "https://api.twitter.com/1.1/mutes/users/list.json?count=5"},
          json_response(200, """
          {
            "users": #{File.read!("test/support/fixtures/v1_1/users.json")},
            "next_cursor": 0,
            "next_cursor_str": "0",
            "previous_cursor": 0,
            "previous_cursor_str": "0"
          }
          """)
        }
      ])

    assert {:ok, %{users: [%User{} | _]}} = User.muted(client, %{count: "5"})
  end

  test "retweeter_ids/2 requests to /statuses/retweeters/ids.json" do
    client =
      stub_client([
        {
          {:get, "https://api.twitter.com/1.1/statuses/retweeters/ids.json?id=10"},
          json_response(200, """
          {
            "ids": [1, 2, 3],
            "next_cursor": 0,
            "next_cursor_str": "0",
            "previous_cursor": 0,
            "previous_cursor_str": "0"
          }
          """)
        }
      ])

    assert {:ok, %{ids: [1, 2, 3]}} = User.retweeter_ids(client, %{tweet_id: 10})
  end

  test "retweeter_ids/2 accepts a Tweet" do
    tweet = tweet_fixture()

    client =
      stub_client([
        {
          {:get, "https://api.twitter.com/1.1/statuses/retweeters/ids.json?id=#{tweet.id}"},
          json_response(200, """
          {
            "ids": [1, 2, 3],
            "next_cursor": 0,
            "next_cursor_str": "0",
            "previous_cursor": 0,
            "previous_cursor_str": "0"
          }
          """)
        }
      ])

    assert {:ok, %{ids: [1, 2, 3]}} = User.retweeter_ids(client, %{tweet: tweet})
  end

  test "get_profile_banner/2 requests to /users/profile_banner.json" do
    client =
      stub_client([
        {
          {:get, "https://api.twitter.com/1.1/users/profile_banner.json?screen_name=twitterapi"},
          json_response(200, File.read!("test/support/fixtures/v1_1/users_profile_banner.json"))
        }
      ])

    assert {:ok,
            %{sizes: %{ipad: %{h: 313, w: 626, url: "https://pbs.twimg.com/profile_banners/6253282/1347394302/ipad"}}}} =
             User.get_profile_banner(client, %{screen_name: "twitterapi"})
  end

  test "get_profile_banner/2 accepts a User" do
    user = user_fixture()

    client =
      stub_client([
        {
          {:get, "https://api.twitter.com/1.1/users/profile_banner.json?user_id=#{user.id}"},
          json_response(200, File.read!("test/support/fixtures/v1_1/users_profile_banner.json"))
        }
      ])

    assert {:ok,
            %{sizes: %{ipad: %{h: 313, w: 626, url: "https://pbs.twimg.com/profile_banners/6253282/1347394302/ipad"}}}} =
             User.get_profile_banner(client, %{user: user})
  end

  test "list_subscriber/2 requests to /lists/subscribers/show.json" do
    client =
      stub_client([
        {
          {:get,
           "https://api.twitter.com/1.1/lists/subscribers/show.json?owner_screen_name=twitter&screen_name=episod&slug=team"},
          json_response(200, File.read!("test/support/fixtures/v1_1/user.json"))
        }
      ])

    assert {:ok, %User{}} =
             User.list_subscriber(client, %{slug: "team", owner_screen_name: "twitter", screen_name: "episod"})
  end

  test "list_subscriber/2 accepts structs" do
    user = user_fixture()
    list = list_fixture()

    client =
      stub_client([
        {
          {:get, "https://api.twitter.com/1.1/lists/subscribers/show.json?list_id=#{list.id}&user_id=#{user.id}"},
          json_response(200, File.read!("test/support/fixtures/v1_1/user.json"))
        }
      ])

    assert {:ok, %User{}} = User.list_subscriber(client, %{list: list, user: user})
  end

  test "list_member/2 requests to /lists/members/show.json" do
    client =
      stub_client([
        {
          {:get,
           "https://api.twitter.com/1.1/lists/members/show.json?owner_screen_name=twitter&screen_name=episod&slug=team"},
          json_response(200, File.read!("test/support/fixtures/v1_1/user.json"))
        }
      ])

    assert {:ok, %User{}} =
             User.list_member(client, %{slug: "team", owner_screen_name: "twitter", screen_name: "episod"})
  end

  test "list_member/2 accepts structs" do
    user = user_fixture()
    list = list_fixture()

    client =
      stub_client([
        {
          {:get, "https://api.twitter.com/1.1/lists/members/show.json?list_id=#{list.id}&user_id=#{user.id}"},
          json_response(200, File.read!("test/support/fixtures/v1_1/user.json"))
        }
      ])

    assert {:ok, %User{}} = User.list_member(client, %{list: list, user: user})
  end

  test "list_members/2 requests to /lists/members.json" do
    client =
      stub_client([
        {
          {:get, "https://api.twitter.com/1.1/lists/members.json?owner_screen_name=twitterapi&slug=team"},
          json_response(200, """
          {
            "users": #{File.read!("test/support/fixtures/v1_1/users.json")},
            "next_cursor": 0,
            "next_cursor_str": "0",
            "previous_cursor": 0,
            "previous_cursor_str": "0"
          }
          """)
        }
      ])

    assert {:ok, %{users: [%User{} | _]}} = User.list_members(client, %{slug: "team", owner_screen_name: "twitterapi"})
  end

  test "list_members/2 accepts a List" do
    list = list_fixture()

    client =
      stub_client([
        {
          {:get, "https://api.twitter.com/1.1/lists/members.json?list_id=#{list.id}"},
          json_response(200, """
          {
            "users": #{File.read!("test/support/fixtures/v1_1/users.json")},
            "next_cursor": 0,
            "next_cursor_str": "0",
            "previous_cursor": 0,
            "previous_cursor_str": "0"
          }
          """)
        }
      ])

    assert {:ok, %{users: [%User{} | _]}} = User.list_members(client, %{list: list})
  end

  test "list_subscribers/2 requests to /lists/subscribers.json" do
    client =
      stub_client([
        {
          {:get, "https://api.twitter.com/1.1/lists/subscribers.json?owner_screen_name=twitterapi&slug=team"},
          json_response(200, """
          {
            "users": #{File.read!("test/support/fixtures/v1_1/users.json")},
            "next_cursor": 0,
            "next_cursor_str": "0",
            "previous_cursor": 0,
            "previous_cursor_str": "0"
          }
          """)
        }
      ])

    assert {:ok, %{users: [%User{} | _]}} =
             User.list_subscribers(client, %{slug: "team", owner_screen_name: "twitterapi"})
  end

  test "list_subscribers/2 accepts a List" do
    list = list_fixture()

    client =
      stub_client([
        {
          {:get, "https://api.twitter.com/1.1/lists/subscribers.json?list_id=#{list.id}"},
          json_response(200, """
          {
            "users": #{File.read!("test/support/fixtures/v1_1/users.json")},
            "next_cursor": 0,
            "next_cursor_str": "0",
            "previous_cursor": 0,
            "previous_cursor_str": "0"
          }
          """)
        }
      ])

    assert {:ok, %{users: [%User{} | _]}} = User.list_subscribers(client, %{list: list})
  end

  test "block/2 requests to /blocks/create.json" do
    client =
      stub_client([
        {
          {:post, "https://api.twitter.com/1.1/blocks/create.json", "screen_name=twitterapi"},
          json_response(200, File.read!("test/support/fixtures/v1_1/user.json"))
        }
      ])

    assert {:ok, %User{}} = User.block(client, %{screen_name: "twitterapi"})
  end

  test "block/2 accepts a User" do
    user = user_fixture()

    client =
      stub_client([
        {
          {:post, "https://api.twitter.com/1.1/blocks/create.json", "user_id=#{user.id}"},
          json_response(200, File.read!("test/support/fixtures/v1_1/user.json"))
        }
      ])

    assert {:ok, %User{}} = User.block(client, %{user: user})
  end

  test "unblock/2 requests to /blocks/destroy.json" do
    client =
      stub_client([
        {
          {:post, "https://api.twitter.com/1.1/blocks/destroy.json", "screen_name=twitterapi"},
          json_response(200, File.read!("test/support/fixtures/v1_1/user.json"))
        }
      ])

    assert {:ok, %User{}} = User.unblock(client, %{screen_name: "twitterapi"})
  end

  test "unblock/2 accepts a User" do
    user = user_fixture()

    client =
      stub_client([
        {
          {:post, "https://api.twitter.com/1.1/blocks/destroy.json", "user_id=#{user.id}"},
          json_response(200, File.read!("test/support/fixtures/v1_1/user.json"))
        }
      ])

    assert {:ok, %User{}} = User.unblock(client, %{user: user})
  end

  test "mute/2 requests to /mutes/create.json" do
    client =
      stub_client([
        {
          {:post, "https://api.twitter.com/1.1/mutes/users/create.json", "screen_name=twitterapi"},
          json_response(200, File.read!("test/support/fixtures/v1_1/user.json"))
        }
      ])

    assert {:ok, %User{}} = User.mute(client, %{screen_name: "twitterapi"})
  end

  test "mute/2 accepts a User" do
    user = user_fixture()

    client =
      stub_client([
        {
          {:post, "https://api.twitter.com/1.1/mutes/users/create.json", "user_id=#{user.id}"},
          json_response(200, File.read!("test/support/fixtures/v1_1/user.json"))
        }
      ])

    assert {:ok, %User{}} = User.mute(client, %{user: user})
  end

  test "unmute/2 requests to /mutes/users/destroy.json" do
    client =
      stub_client([
        {
          {:post, "https://api.twitter.com/1.1/mutes/users/destroy.json", "screen_name=twitterapi"},
          json_response(200, File.read!("test/support/fixtures/v1_1/user.json"))
        }
      ])

    assert {:ok, %User{}} = User.unmute(client, %{screen_name: "twitterapi"})
  end

  test "unmute/2 accepts a User" do
    user = user_fixture()

    client =
      stub_client([
        {
          {:post, "https://api.twitter.com/1.1/mutes/users/destroy.json", "user_id=#{user.id}"},
          json_response(200, File.read!("test/support/fixtures/v1_1/user.json"))
        }
      ])

    assert {:ok, %User{}} = User.unmute(client, %{user: user})
  end

  test "report_spam/2 requests to /users/report_spam.json" do
    client =
      stub_client([
        {
          {:post, "https://api.twitter.com/1.1/users/report_spam.json", "screen_name=twitterapi"},
          json_response(200, File.read!("test/support/fixtures/v1_1/user.json"))
        }
      ])

    assert {:ok, %User{}} = User.report_spam(client, %{screen_name: "twitterapi"})
  end

  test "report_spam/2 accepts a User" do
    user = user_fixture()

    client =
      stub_client([
        {
          {:post, "https://api.twitter.com/1.1/users/report_spam.json", "user_id=#{user.id}"},
          json_response(200, File.read!("test/support/fixtures/v1_1/user.json"))
        }
      ])

    assert {:ok, %User{}} = User.report_spam(client, %{user: user})
  end

  test "follow/2 requests to /friendships/create.json" do
    client =
      stub_client([
        {
          {:post, "https://api.twitter.com/1.1/friendships/create.json", "screen_name=twitterapi"},
          json_response(200, File.read!("test/support/fixtures/v1_1/user.json"))
        }
      ])

    assert {:ok, %User{}} = User.follow(client, %{screen_name: "twitterapi"})
  end

  test "follow/2 accepts a User" do
    user = user_fixture()

    client =
      stub_client([
        {
          {:post, "https://api.twitter.com/1.1/friendships/create.json", "user_id=#{user.id}"},
          json_response(200, File.read!("test/support/fixtures/v1_1/user.json"))
        }
      ])

    assert {:ok, %User{}} = User.follow(client, %{user: user})
  end

  test "unfollow/2 requests to /friendships/destroy.json" do
    client =
      stub_client([
        {
          {:post, "https://api.twitter.com/1.1/friendships/destroy.json", "screen_name=twitterapi"},
          json_response(200, File.read!("test/support/fixtures/v1_1/user.json"))
        }
      ])

    assert {:ok, %User{}} = User.unfollow(client, %{screen_name: "twitterapi"})
  end

  test "unfollow/2 accepts a User" do
    user = user_fixture()

    client =
      stub_client([
        {
          {:post, "https://api.twitter.com/1.1/friendships/destroy.json", "user_id=#{user.id}"},
          json_response(200, File.read!("test/support/fixtures/v1_1/user.json"))
        }
      ])

    assert {:ok, %User{}} = User.unfollow(client, %{user: user})
  end

  test "pending_follower_ids/2 requests to /friendships/incoming.json" do
    client =
      stub_client([
        {
          {:get, "https://api.twitter.com/1.1/friendships/incoming.json?cursor=-1"},
          json_response(200, """
          {
            "ids": [1, 2, 3],
            "next_cursor": 0,
            "next_cursor_str": "0",
            "previous_cursor": 0,
            "previous_cursor_str": "0"
          }
          """)
        }
      ])

    assert {:ok, %{ids: [1, 2, 3]}} = User.pending_follower_ids(client, %{cursor: -1})
  end

  test "pending_friend_ids/2 requests to /friendships/outgoing.json" do
    client =
      stub_client([
        {
          {:get, "https://api.twitter.com/1.1/friendships/outgoing.json?cursor=-1"},
          json_response(200, """
          {
            "ids": [1, 2, 3],
            "next_cursor": 0,
            "next_cursor_str": "0",
            "previous_cursor": 0,
            "previous_cursor_str": "0"
          }
          """)
        }
      ])

    assert {:ok, %{ids: [1, 2, 3]}} = User.pending_friend_ids(client, %{cursor: -1})
  end

  test "no_retweet_ids/2 requests to /friendships/no_retweets/ids.json" do
    client =
      stub_client([
        {
          {:get, "https://api.twitter.com/1.1/friendships/no_retweets/ids.json?cursor=-1"},
          json_response(200, """
          {
            "ids": [1, 2, 3],
            "next_cursor": 0,
            "next_cursor_str": "0",
            "previous_cursor": 0,
            "previous_cursor_str": "0"
          }
          """)
        }
      ])

    assert {:ok, %{ids: [1, 2, 3]}} = User.no_retweet_ids(client, %{cursor: -1})
  end

  test "list_friendships/2 requests to /friendships/lookup.json" do
    client =
      stub_client([
        {
          {:get,
           "https://api.twitter.com/1.1/friendships/lookup.json?screen_name=andypiper%2Cbinary_aaron%2Ctwitterdev%2Chappycamper%2Charris_0ff"},
          json_response(200, File.read!("test/support/fixtures/v1_1/friendships_lookup.json"))
        }
      ])

    assert {:ok,
            [
              %{screen_name: "andypiper", connections: [:following]},
              %{screen_name: "binary_aaron", connections: [:following, :followed_by]},
              %{screen_name: "TwitterDev", connections: [:following]},
              %{screen_name: "happycamper", connections: [:none]},
              %{screen_name: "Harris_0ff", connections: [:following, :following_requested, :followed_by]}
            ]} =
             User.list_friendships(client, %{
               screen_names: ~w[andypiper binary_aaron twitterdev happycamper harris_0ff]
             })
  end

  test "get_friendship/2 requests to /friendships/show.json" do
    client =
      stub_client([
        {
          {:get,
           "https://api.twitter.com/1.1/friendships/show.json?source_screen_name=twitter&target_screen_name=twitterdev"},
          json_response(200, File.read!("test/support/fixtures/v1_1/friendships_show.json"))
        }
      ])

    assert {:ok, %{relationship: %{source: %{screen_name: "Twitter"}, target: %{screen_name: "TwitterDev"}}}} =
             User.get_friendship(client, %{source_screen_name: "twitter", target_screen_name: "twitterdev"})
  end

  test "get_friendship/2 accepts source and target as User" do
    source = user_fixture() |> Map.put(:id, 1)
    target = user_fixture() |> Map.put(:id, 2)

    client =
      stub_client([
        {
          {:get, "https://api.twitter.com/1.1/friendships/show.json?source_id=#{source.id}&target_id=#{target.id}"},
          json_response(200, File.read!("test/support/fixtures/v1_1/friendships_show.json"))
        }
      ])

    assert {:ok, %{}} = User.get_friendship(client, %{source: source, target: target})
  end

  test "update_friendship/2 requests to /friendships/update.json" do
    client =
      stub_client([
        {
          {:post, "https://api.twitter.com/1.1/friendships/update.json", "device=true&user_id=2244994945"},
          json_response(200, File.read!("test/support/fixtures/v1_1/friendships_show.json"))
        }
      ])

    assert {:ok, _} = User.update_friendship(client, %{user_id: 2_244_994_945, device: true})
  end

  test "update_friendship/2 accepts a User" do
    user = user_fixture()

    client =
      stub_client([
        {
          {:post, "https://api.twitter.com/1.1/friendships/update.json", "retweets=true&user_id=#{user.id}"},
          json_response(200, File.read!("test/support/fixtures/v1_1/friendships_show.json"))
        }
      ])

    assert {:ok, %{}} = User.update_friendship(client, %{user: user, retweets: true})
  end
end
