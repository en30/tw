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
end
