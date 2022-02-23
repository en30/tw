defmodule Tw.OAuth.V1_0a do
  @moduledoc false

  alias Tw.HTTP
  alias Tw.OAuth.V1_0a.Credentials

  # Based on https://developer.twitter.com/en/docs/authentication/oauth-1-0a/creating-a-signature

  @typep params :: list({binary, binary})

  @spec authorization_header_value(signature :: binary, oauth_params :: params) :: binary
  def authorization_header_value(signature, oauth_params) do
    dst =
      [
        {"oauth_signature", signature |> Base.encode64()}
        | oauth_params
      ]
      |> Enum.map(fn {k, v} ->
        {encode(k), encode(v)}
      end)
      |> Enum.sort()
      |> Enum.map_join(", ", fn {k, v} -> ~s[#{k}="#{v}"] end)

    "OAuth " <> dst
  end

  @spec signature(HTTP.Request.t(), Credentials.t(), params) :: binary
  def signature(request, credentials, oauth_params) do
    parameter_string = parameter_string(request, oauth_params)
    signature_base_string = signature_base_string(request, parameter_string)

    :crypto.mac(:hmac, :sha, signing_key(credentials), signature_base_string)
  end

  @spec parameter_string(HTTP.Request.t(), params) :: binary
  def parameter_string(request, oauth_params) do
    body_params =
      with ["application/x-www-form-urlencoded" <> _] <- HTTP.Request.get_header(request, "content-type"),
           body when not is_nil(body) and body != "" <- request.body do
        body
        |> URI.query_decoder(:www_form)
        |> Enum.to_list()
      else
        _ -> []
      end

    query_params =
      case request.uri.query do
        nil ->
          []

        query ->
          query
          |> URI.query_decoder(:rfc3986)
          |> Enum.to_list()
      end

    params = oauth_params ++ query_params ++ body_params

    params
    |> Enum.map(fn {k, v} ->
      {encode(k), encode(v)}
    end)
    |> Enum.sort()
    |> Enum.map_join("&", fn {k, v} -> "#{k}=#{v}" end)
  end

  @spec signature_base_string(HTTP.Request.t(), binary) :: binary
  def signature_base_string(request, parameter_string) do
    [
      request.method |> to_string() |> String.upcase(),
      %{request.uri | query: nil} |> URI.to_string(),
      parameter_string
    ]
    |> Enum.map_join("&", &encode/1)
  end

  @spec signing_key(Credentials.t()) :: binary
  def signing_key(credentials) do
    [
      credentials.consumer_secret,
      credentials.access_token_secret
    ]
    |> Enum.map_join("&", &encode/1)
  end

  @spec params(Credentials.t(), (() -> binary), (() -> binary)) :: params
  def params(credentials, nonce_fn \\ &nonce/0, timestamp_fn \\ &timestamp/0) do
    [
      {"oauth_consumer_key", credentials.consumer_key},
      {"oauth_nonce", nonce_fn.()},
      {"oauth_signature_method", "HMAC-SHA1"},
      {"oauth_timestamp", timestamp_fn.()},
      {"oauth_token", credentials.access_token},
      {"oauth_version", "1.0"}
    ]
  end

  # https://developer.twitter.com/en/docs/authentication/oauth-1-0a/percent-encoding-parameters
  defp encode(str), do: URI.encode(str, &URI.char_unreserved?/1)

  defp nonce, do: :crypto.strong_rand_bytes(24) |> Base.encode64()
  defp timestamp, do: DateTime.utc_now() |> DateTime.to_unix() |> to_string()
end
