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
          {:post, "https://api.twitter.com/1.1/account/settings.json", %{lang: "en"} |> URI.encode_query()},
          json_response(200, File.read!("test/support/fixtures/v1_1/account_settings.json"))
        }
      ])

    assert {:ok, %{always_use_https: true}} = Me.update_setting(client, %{lang: "en"})
  end
end
