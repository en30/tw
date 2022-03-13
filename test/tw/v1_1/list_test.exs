defmodule Tw.V1_1.ListTest do
  alias Tw.V1_1.List, as: TwList
  alias Tw.V1_1.User

  use ExUnit.Case, async: true

  import Tw.V1_1.EndpointHelper

  @json_path "test/support/fixtures/v1_1/list.json"

  describe "decode!/1" do
    setup do
      json = @json_path |> File.read!() |> Jason.decode!(keys: :atoms)
      list = TwList.decode!(json)
      %{list: list, json: json}
    end

    test "create a List struct", %{list: list} do
      assert %TwList{} = list
    end

    test "decodes created_at into DateTime", %{list: list} do
      assert ~U[2009-09-23 01:18:01Z] = list.created_at
    end

    test "decodes user into User", %{list: list} do
      assert %User{} = list.user
    end

    test "decodes mode to atom", %{list: list} do
      assert list.mode == :public
    end
  end

  test "get/2 requests to /lists/show.json" do
    client =
      stub_client([
        {
          {:get, "https://api.twitter.com/1.1/lists/show.json?owner_screen_name=twitter&slug=team"},
          json_response(200, File.read!("test/support/fixtures/v1_1/list.json"))
        }
      ])

    assert {:ok, %TwList{slug: "team", user: %User{screen_name: "twitter"}}} =
             TwList.get(client, %{slug: "team", owner_screen_name: "twitter"})
  end

  test "create/2 requests to /lists/create.json" do
    client =
      stub_client([
        {
          {:post, "https://api.twitter.com/1.1/lists/create.json",
           %{name: "team", mode: "private"} |> URI.encode_query(:www_form)},
          json_response(200, File.read!("test/support/fixtures/v1_1/list.json"))
        }
      ])

    assert {:ok, %TwList{}} = TwList.create(client, %{name: "team", mode: :private})
  end

  test "update/3 requests to /lists/update.json" do
    client =
      stub_client([
        {
          {:post, "https://api.twitter.com/1.1/lists/update.json",
           %{list_id: 574, mode: "private"} |> URI.encode_query(:www_form)},
          json_response(200, File.read!("test/support/fixtures/v1_1/list.json"))
        }
      ])

    assert {:ok, %TwList{}} = TwList.update(client, %{list_id: 574, mode: :private})
  end

  test "update/2 accepts a List" do
    list = File.read!("test/support/fixtures/v1_1/list.json") |> Jason.decode!(keys: :atoms) |> TwList.decode!()

    client =
      stub_client([
        {
          {:post, "https://api.twitter.com/1.1/lists/update.json",
           %{list_id: list.id, mode: "public", name: "updated"}
           |> URI.encode_query(:www_form)},
          json_response(200, File.read!("test/support/fixtures/v1_1/list.json"))
        }
      ])

    assert {:ok, %TwList{}} = TwList.update(client, %{list: list, name: "updated"})
  end

  test "delete/2 requests to /lists/destroy.json" do
    client =
      stub_client([
        {
          {:post, "https://api.twitter.com/1.1/lists/destroy.json", %{list_id: 574} |> URI.encode_query(:www_form)},
          json_response(200, File.read!("test/support/fixtures/v1_1/list.json"))
        }
      ])

    assert {:ok, %TwList{}} = TwList.delete(client, %{list_id: 574})
  end

  test "delete/2 accepts a List" do
    list = File.read!("test/support/fixtures/v1_1/list.json") |> Jason.decode!(keys: :atoms) |> TwList.decode!()

    client =
      stub_client([
        {
          {:post, "https://api.twitter.com/1.1/lists/destroy.json", %{list_id: list.id} |> URI.encode_query(:www_form)},
          json_response(200, File.read!("test/support/fixtures/v1_1/list.json"))
        }
      ])

    assert {:ok, %TwList{}} = TwList.delete(client, %{list: list})
  end

  describe "put_member/2" do
    test "requests to /lists/members/create.json" do
      client =
        stub_client([
          {
            {:post, "https://api.twitter.com/1.1/lists/members/create.json",
             %{owner_screen_name: "twitter", screen_name: "kurrik", slug: "team"} |> URI.encode_query(:www_form)},
            json_response(200, File.read!("test/support/fixtures/v1_1/list.json"))
          }
        ])

      assert {:ok, %TwList{}} =
               TwList.put_member(client, %{owner_screen_name: "twitter", slug: "team", screen_name: "kurrik"})
    end

    test "accepts struct as parameters" do
      list = File.read!("test/support/fixtures/v1_1/list.json") |> Jason.decode!(keys: :atoms) |> TwList.decode!()
      user = File.read!("test/support/fixtures/v1_1/user.json") |> Jason.decode!(keys: :atoms) |> User.decode!()

      client =
        stub_client([
          {
            {:post, "https://api.twitter.com/1.1/lists/members/create.json",
             %{list_id: list.id, user_id: user.id} |> URI.encode_query(:www_form)},
            json_response(200, File.read!("test/support/fixtures/v1_1/list.json"))
          }
        ])

      assert {:ok, %TwList{}} = TwList.put_member(client, %{list: list, user: user})
    end
  end

  describe "put_members/2" do
    test "requests to /lists/members/create_all.json" do
      client =
        stub_client([
          {
            {:post, "https://api.twitter.com/1.1/lists/members/create_all.json",
             %{list_id: 23, screen_name: "rsarver,episod,jasoncosta,theseancook,kurrik,froginthevalley"}
             |> URI.encode_query(:www_form)},
            json_response(200, File.read!("test/support/fixtures/v1_1/list.json"))
          }
        ])

      assert {:ok, %TwList{}} =
               TwList.put_members(client, %{
                 list_id: 23,
                 screen_names: ~w[rsarver episod jasoncosta theseancook kurrik froginthevalley]
               })
    end

    test "accepts struct as parameters" do
      list = File.read!("test/support/fixtures/v1_1/list.json") |> Jason.decode!(keys: :atoms) |> TwList.decode!()
      user = File.read!("test/support/fixtures/v1_1/user.json") |> Jason.decode!(keys: :atoms) |> User.decode!()

      client =
        stub_client([
          {
            {:post, "https://api.twitter.com/1.1/lists/members/create_all.json",
             %{list_id: list.id, user_id: user.id} |> URI.encode_query(:www_form)},
            json_response(200, File.read!("test/support/fixtures/v1_1/list.json"))
          }
        ])

      assert {:ok, %TwList{}} = TwList.put_members(client, %{list: list, users: [user]})
    end
  end

  describe "delete_member/2" do
    test "requests to /lists/members/destroy.json" do
      client =
        stub_client([
          {
            {:post, "https://api.twitter.com/1.1/lists/members/destroy.json",
             %{owner_screen_name: "twitter", screen_name: "kurrik", slug: "cool_people"} |> URI.encode_query(:www_form)},
            json_response(200, File.read!("test/support/fixtures/v1_1/list.json"))
          }
        ])

      assert {:ok, %TwList{}} =
               TwList.delete_member(client, %{owner_screen_name: "twitter", slug: "cool_people", screen_name: "kurrik"})
    end

    test "accepts struct as parameters" do
      list = File.read!("test/support/fixtures/v1_1/list.json") |> Jason.decode!(keys: :atoms) |> TwList.decode!()
      user = File.read!("test/support/fixtures/v1_1/user.json") |> Jason.decode!(keys: :atoms) |> User.decode!()

      client =
        stub_client([
          {
            {:post, "https://api.twitter.com/1.1/lists/members/destroy.json",
             %{list_id: list.id, user_id: user.id} |> URI.encode_query(:www_form)},
            json_response(200, File.read!("test/support/fixtures/v1_1/list.json"))
          }
        ])

      assert {:ok, %TwList{}} = TwList.delete_member(client, %{list: list, user: user})
    end
  end

  describe "delete_members/2" do
    test "requests to /lists/members/destroy_all.json" do
      client =
        stub_client([
          {
            {:post, "https://api.twitter.com/1.1/lists/members/destroy_all.json",
             %{list_id: 23, screen_name: "rsarver,episod,jasoncosta,theseancook,kurrik,froginthevalley"}
             |> URI.encode_query(:www_form)},
            json_response(200, File.read!("test/support/fixtures/v1_1/list.json"))
          }
        ])

      assert {:ok, %TwList{}} =
               TwList.delete_members(client, %{
                 list_id: 23,
                 screen_names: ~w[rsarver episod jasoncosta theseancook kurrik froginthevalley]
               })
    end

    test "accepts struct as parameters" do
      list = File.read!("test/support/fixtures/v1_1/list.json") |> Jason.decode!(keys: :atoms) |> TwList.decode!()
      user = File.read!("test/support/fixtures/v1_1/user.json") |> Jason.decode!(keys: :atoms) |> User.decode!()

      client =
        stub_client([
          {
            {:post, "https://api.twitter.com/1.1/lists/members/destroy_all.json",
             %{list_id: list.id, user_id: user.id} |> URI.encode_query(:www_form)},
            json_response(200, File.read!("test/support/fixtures/v1_1/list.json"))
          }
        ])

      assert {:ok, %TwList{}} = TwList.delete_members(client, %{list: list, users: [user]})
    end
  end

  test "list/2 requests to /lists/list.json" do
    client =
      stub_client([
        {
          {:get, "https://api.twitter.com/1.1/lists/list.json?screen_name=twitterapi"},
          json_response(200, File.read!("test/support/fixtures/v1_1/lists_list.json"))
        }
      ])

    assert {:ok, [%TwList{slug: "meetup-20100301"}, %TwList{slug: "team"}]} =
             TwList.list(client, %{screen_name: "twitterapi"})
  end

  test "owned_by/2 requests to /lists/ownerships.json" do
    client =
      stub_client([
        {
          {:get, "https://api.twitter.com/1.1/lists/ownerships.json?count=2&screen_name=twitter"},
          json_response(200, File.read!("test/support/fixtures/v1_1/lists_ownerships.json"))
        }
      ])

    assert {:ok, %{lists: [%TwList{slug: "official-twitter-accts"} | _]}} =
             TwList.owned_by(client, %{screen_name: "twitter", count: 2})
  end

  test "owned_by/2 accepts a User" do
    user = File.read!("test/support/fixtures/v1_1/user.json") |> Jason.decode!(keys: :atoms) |> User.decode!()

    client =
      stub_client([
        {
          {:get, "https://api.twitter.com/1.1/lists/ownerships.json?count=2&user_id=#{user.id}"},
          json_response(200, File.read!("test/support/fixtures/v1_1/lists_ownerships.json"))
        }
      ])

    assert {:ok, %{lists: [%TwList{slug: "official-twitter-accts"} | _]}} =
             TwList.owned_by(client, %{user: user, count: 2})
  end

  test "subscribed_by/2 requests to /lists/subscriptions.json" do
    client =
      stub_client([
        {
          {:get, "https://api.twitter.com/1.1/lists/subscriptions.json?count=5&cursor=-1&screen_name=episod"},
          json_response(200, File.read!("test/support/fixtures/v1_1/lists_subscriptions.json"))
        }
      ])

    assert {:ok, %{lists: [%TwList{slug: "team"} | _]}} =
             TwList.subscribed_by(client, %{count: 5, cursor: -1, screen_name: "episod"})
  end

  test "subscribed_by/2 accepts a User" do
    user = File.read!("test/support/fixtures/v1_1/user.json") |> Jason.decode!(keys: :atoms) |> User.decode!()

    client =
      stub_client([
        {
          {:get, "https://api.twitter.com/1.1/lists/subscriptions.json?count=5&cursor=-1&user_id=#{user.id}"},
          json_response(200, File.read!("test/support/fixtures/v1_1/lists_subscriptions.json"))
        }
      ])

    assert {:ok, %{lists: [%TwList{slug: "team"} | _]}} =
             TwList.subscribed_by(client, %{count: 5, cursor: -1, user: user})
  end

  test "containing/2 requests to /lists/memberships.json" do
    client =
      stub_client([
        {
          {:get, "https://api.twitter.com/1.1/lists/memberships.json?cursor=-1&screen_name=twitter"},
          json_response(200, File.read!("test/support/fixtures/v1_1/lists_memberships.json"))
        }
      ])

    assert {:ok, %{lists: [%TwList{slug: "vanessa-williams"} | _]}} =
             TwList.containing(client, %{cursor: -1, screen_name: "twitter"})
  end

  test "containing/2 accepts a User" do
    user = File.read!("test/support/fixtures/v1_1/user.json") |> Jason.decode!(keys: :atoms) |> User.decode!()

    client =
      stub_client([
        {
          {:get, "https://api.twitter.com/1.1/lists/memberships.json?cursor=-1&user_id=#{user.id}"},
          json_response(200, File.read!("test/support/fixtures/v1_1/lists_memberships.json"))
        }
      ])

    assert {:ok, %{lists: [%TwList{slug: "vanessa-williams"} | _]}} =
             TwList.containing(client, %{cursor: -1, user: user})
  end

  test "subscribe/2 requests to /lists/subscribers/create.json" do
    client =
      stub_client([
        {
          {:post, "https://api.twitter.com/1.1/lists/subscribers/create.json",
           %{list_id: 574} |> URI.encode_query(:www_form)},
          json_response(200, File.read!("test/support/fixtures/v1_1/list.json"))
        }
      ])

    assert {:ok, %TwList{}} = TwList.subscribe(client, %{list_id: 574})
  end

  test "subscribe/2 accepts a List" do
    list = File.read!("test/support/fixtures/v1_1/list.json") |> Jason.decode!(keys: :atoms) |> TwList.decode!()

    client =
      stub_client([
        {
          {:post, "https://api.twitter.com/1.1/lists/subscribers/create.json",
           %{list_id: list.id} |> URI.encode_query(:www_form)},
          json_response(200, File.read!("test/support/fixtures/v1_1/list.json"))
        }
      ])

    assert {:ok, %TwList{}} = TwList.subscribe(client, %{list: list})
  end

  test "unsubscribe/2 requests to /lists/subscribers/destroy.json" do
    client =
      stub_client([
        {
          {:post, "https://api.twitter.com/1.1/lists/subscribers/destroy.json",
           %{list_id: 574} |> URI.encode_query(:www_form)},
          json_response(200, File.read!("test/support/fixtures/v1_1/list.json"))
        }
      ])

    assert {:ok, %TwList{}} = TwList.unsubscribe(client, %{list_id: 574})
  end

  test "unsubscribe/2 accepts a List" do
    list = File.read!("test/support/fixtures/v1_1/list.json") |> Jason.decode!(keys: :atoms) |> TwList.decode!()

    client =
      stub_client([
        {
          {:post, "https://api.twitter.com/1.1/lists/subscribers/destroy.json",
           %{list_id: list.id} |> URI.encode_query(:www_form)},
          json_response(200, File.read!("test/support/fixtures/v1_1/list.json"))
        }
      ])

    assert {:ok, %TwList{}} = TwList.unsubscribe(client, %{list: list})
  end
end
