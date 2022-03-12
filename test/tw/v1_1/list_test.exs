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
end
