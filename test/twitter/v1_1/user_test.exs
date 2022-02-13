defmodule Twitter.V1_1.UserTest do
  alias Twitter.V1_1.User
  alias Twitter.V1_1.UserEntities

  use ExUnit.Case, async: true

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
  ]

  # https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/user#:~:text=Example%20user%20object%3A
  @json_path "test/support/fixtures/v1_1/user.json"

  describe "decode/1" do
    setup do
      json = @json_path |> File.read!() |> Jason.decode!()
      user = User.decode(json)
      %{user: user, json: json}
    end

    test "create a User struct", %{user: user} do
      assert %User{} = user
    end

    test "decodes entities into UserEntities", %{user: user} do
      assert %UserEntities{} = user.entities
    end

    test "decodes created_at into NaiveDateTime", %{user: user} do
      assert ~N[2007-05-23 06:01:13] = user.created_at
    end

    test "uses all keys of the json", %{user: user, json: json} do
      for {key, _value} <- json, !Enum.member?(@deprecated_keys, key) do
        assert Map.has_key?(user, String.to_atom(key))
      end
    end
  end
end
