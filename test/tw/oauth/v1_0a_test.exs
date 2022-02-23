defmodule Tw.OAuth.V1_0aTest do
  @moduledoc """
  Based on https://developer.twitter.com/en/docs/authentication/oauth-1-0a/creating-a-signature
  """
  use ExUnit.Case

  alias Tw.HTTP.Request
  alias Tw.OAuth.V1_0a, as: OAuth

  @nonce "kYjzVBB8Y0ZFabxSWbWovY3uYSQ2pTgmZeNu2VS4cg"
  @timestamp "1318622958"

  @request %Request{
    method: "POST",
    uri: URI.parse("https://api.twitter.com/1.1/statuses/update.json?include_entities=true"),
    headers: [
      {"content-type", "application/x-www-form-urlencoded"}
    ],
    body: "status=Hello%20Ladies%20%2b%20Gentlemen%2c%20a%20signed%20OAuth%20request%21"
  }

  @fake_credentials %{
    consumer_key: "xvz1evFS4wEEPTGEFPHBog",
    consumer_secret: "kAcSOqF21Fu85e7zjz7ZN2U4ZRhfV3WpwPAoE3Z7kBw",
    access_token: "370773112-GmHxMAgYyLbNEtIKZeRNFsMKPR9EyMZeS9weJAEb",
    access_token_secret: "LswwdoUaIvS8ltyTt5jkRh4J50vUPVVHtR2YPi5kE"
  }

  @params OAuth.params(@fake_credentials, fn -> @nonce end, fn -> @timestamp end)

  @expected_parameter_string "include_entities=true&oauth_consumer_key=xvz1evFS4wEEPTGEFPHBog&oauth_nonce=kYjzVBB8Y0ZFabxSWbWovY3uYSQ2pTgmZeNu2VS4cg&oauth_signature_method=HMAC-SHA1&oauth_timestamp=1318622958&oauth_token=370773112-GmHxMAgYyLbNEtIKZeRNFsMKPR9EyMZeS9weJAEb&oauth_version=1.0&status=Hello%20Ladies%20%2B%20Gentlemen%2C%20a%20signed%20OAuth%20request%21"

  test "parameter_string/2" do
    assert OAuth.parameter_string(@request, @params) == @expected_parameter_string
  end

  test "parameter_string/2 dost not include body params if content-type is not application/x-www-form-urlencoded" do
    request = %Request{
      method: "POST",
      uri: URI.parse("https://api.twitter.com/1.1/statuses/update.json?include_entities=true"),
      headers: [
        {"content-type", "multipart/form-data; boundary=bounday"}
      ],
      body:
        """
        --boundary
        Content-Disposition: form-data; name="status"

        Hello Ladies + Gentlemen, a signed OAuth request!
        --boundary--

        """
        |> String.replace("\n", "\r\n")
    }

    refute OAuth.parameter_string(request, @params) == @expected_parameter_string
  end

  test "signature_base_string/2" do
    assert OAuth.signature_base_string(@request, @expected_parameter_string) ==
             "POST&https%3A%2F%2Fapi.twitter.com%2F1.1%2Fstatuses%2Fupdate.json&include_entities%3Dtrue%26oauth_consumer_key%3Dxvz1evFS4wEEPTGEFPHBog%26oauth_nonce%3DkYjzVBB8Y0ZFabxSWbWovY3uYSQ2pTgmZeNu2VS4cg%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1318622958%26oauth_token%3D370773112-GmHxMAgYyLbNEtIKZeRNFsMKPR9EyMZeS9weJAEb%26oauth_version%3D1.0%26status%3DHello%2520Ladies%2520%252B%2520Gentlemen%252C%2520a%2520signed%2520OAuth%2520request%2521"
  end

  test "signing_key/1" do
    assert OAuth.signing_key(@fake_credentials) ==
             "kAcSOqF21Fu85e7zjz7ZN2U4ZRhfV3WpwPAoE3Z7kBw&LswwdoUaIvS8ltyTt5jkRh4J50vUPVVHtR2YPi5kE"
  end

  test "signature/3" do
    sig = OAuth.signature(@request, @fake_credentials, @params)

    assert sig ==
             <<0x84, 0x2B, 0x52, 0x99, 0x88, 0x7E, 0x88, 0x76, 0x02, 0x12, 0xA0, 0x56, 0xAC, 0x4E, 0xC2, 0xEE, 0x16,
               0x26, 0xB5, 0x49>>

    assert Base.encode64(sig) == "hCtSmYh+iHYCEqBWrE7C7hYmtUk="
  end

  test "authorization_header_value/2" do
    value =
      OAuth.signature(@request, @fake_credentials, @params)
      |> OAuth.authorization_header_value(@params)

    assert value ==
             ~s[OAuth oauth_consumer_key="xvz1evFS4wEEPTGEFPHBog", oauth_nonce="kYjzVBB8Y0ZFabxSWbWovY3uYSQ2pTgmZeNu2VS4cg", oauth_signature="hCtSmYh%2BiHYCEqBWrE7C7hYmtUk%3D", oauth_signature_method="HMAC-SHA1", oauth_timestamp="1318622958", oauth_token="370773112-GmHxMAgYyLbNEtIKZeRNFsMKPR9EyMZeS9weJAEb", oauth_version="1.0"]
  end
end
