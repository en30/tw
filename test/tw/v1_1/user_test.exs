defmodule Tw.V1_1.UserTest do
  alias Tw.V1_1.User
  alias Tw.V1_1.UserEntities

  use ExUnit.Case, async: true

  import Tw.V1_1.EndpointHelper

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
end
