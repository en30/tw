defmodule Tw.V1_1.CursoredResultTest do
  alias Tw.V1_1.CursoredResult
  alias Tw.V1_1.User

  use ExUnit.Case, async: true

  import Tw.V1_1.EndpointHelper

  test "stream!/4 returns Stream of the resource requested" do
    client =
      stub_client([
        {
          {:get, "https://api.twitter.com/1.1/followers/ids.json?cursor=-1&screen_name=twitterapi"},
          json_response(200, """
          {
            "ids": [1],
            "next_cursor": 1,
            "next_cursor_str": "1",
            "previous_cursor": 0,
            "previous_cursor_str": "1"
          }
          """)
        },
        {
          {:get, "https://api.twitter.com/1.1/followers/ids.json?cursor=1&screen_name=twitterapi"},
          json_response(200, """
          {
            "ids": [2],
            "next_cursor": 0,
            "next_cursor_str": "0",
            "previous_cursor": -1,
            "previous_cursor_str": "-1"
          }
          """)
        }
      ])

    assert CursoredResult.stream!(client, &User.follower_ids/2, %{screen_name: "twitterapi"}, :ids) |> Enum.to_list() ==
             [1, 2]
  end

  test "persevering_stream!/4 returns Stream of the resource requested even if rate limit exceeded error happens" do
    client =
      stub_client([
        {
          {:get, "https://api.twitter.com/1.1/followers/ids.json?cursor=-1&screen_name=twitterapi"},
          json_response(200, """
          {
            "ids": [1],
            "next_cursor": 1,
            "next_cursor_str": "1",
            "previous_cursor": 0,
            "previous_cursor_str": "1"
          }
          """)
        },
        {
          {:get, "https://api.twitter.com/1.1/followers/ids.json?cursor=1&screen_name=twitterapi"},
          json_response(
            429,
            [
              {"x-rate-limit-reset",
               DateTime.utc_now() |> DateTime.add(1, :second) |> DateTime.to_unix(:second) |> to_string()}
            ],
            """
            { "errors": [ { "code": 88, "message": "Rate limit exceeded" } ] }
            """
          )
        },
        {
          {:get, "https://api.twitter.com/1.1/followers/ids.json?cursor=1&screen_name=twitterapi"},
          json_response(200, """
          {
            "ids": [2],
            "next_cursor": 0,
            "next_cursor_str": "0",
            "previous_cursor": -1,
            "previous_cursor_str": "-1"
          }
          """)
        }
      ])

    assert CursoredResult.persevering_stream!(client, &User.follower_ids/2, %{screen_name: "twitterapi"}, :ids)
           |> Enum.to_list() ==
             [1, 2]
  end
end
