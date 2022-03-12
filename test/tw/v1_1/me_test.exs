defmodule Tw.V1_1.MeTest do
  alias Tw.V1_1.Me

  use ExUnit.Case, async: true

  import Tw.V1_1.EndpointHelper

  test "get/1 requests to /account/verify_credentials.json" do
    client =
      stub_client([
        {
          {:get, "https://api.twitter.com/1.1/account/verify_credentials.json?", ""},
          json_response(200, File.read!("test/support/fixtures/v1_1/account_verify_credentials.json"))
        }
      ])

    assert {:ok, %Me{}} = Me.get(client)
  end

  test "get_setting/1 requests to /account/settings.json" do
    client =
      stub_client([
        {
          {:get, "https://api.twitter.com/1.1/account/settings.json?", ""},
          json_response(200, File.read!("test/support/fixtures/v1_1/account_settings.json"))
        }
      ])

    assert {:ok, %{always_use_https: true}} = Me.get_setting(client)
  end

  test "update_setting/1 requests to /account/settings.json" do
    client =
      stub_client([
        {
          {:post, "https://api.twitter.com/1.1/account/settings.json", %{lang: "en"} |> URI.encode_query(:www_form)},
          json_response(200, File.read!("test/support/fixtures/v1_1/account_settings.json"))
        }
      ])

    assert {:ok, %{always_use_https: true}} = Me.update_setting(client, %{lang: "en"})
  end

  test "update_profile_banner/2 requests to /account/update_profile_banner.json" do
    image = File.read!("test/support/fixtures/1x1.png") |> Base.encode64()

    client =
      stub_client([
        {
          {:post, "https://api.twitter.com/1.1/account/update_profile_banner.json",
           %{banner: image} |> URI.encode_query(:www_form)},
          html_response(200, "")
        }
      ])

    assert {:ok, ""} = Me.update_profile_banner(client, %{banner: image})
  end

  test "delete_profile_banner/1 requests to /account/remove_profile_banner.json" do
    client =
      stub_client([
        {
          {:post, "https://api.twitter.com/1.1/account/remove_profile_banner.json", ""},
          html_response(200, "")
        }
      ])

    assert {:ok, ""} = Me.delete_profile_banner(client)
  end

  test "update_profile_image/2 requests to /account/update_profile_image.json" do
    image = File.read!("test/support/fixtures/1x1.png") |> Base.encode64()

    client =
      stub_client([
        {
          {:post, "https://api.twitter.com/1.1/account/update_profile_image.json",
           %{image: image} |> URI.encode_query(:www_form)},
          json_response(200, File.read!("test/support/fixtures/v1_1/account_verify_credentials.json"))
        }
      ])

    assert {:ok, %Me{}} = Me.update_profile_image(client, %{image: image})
  end
end
