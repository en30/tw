defmodule Tw.V1_1.MediaTest do
  alias Tw.V1_1.Media

  use ExUnit.Case, async: true

  import Tw.V1_1.EndpointHelper

  describe "upload/2" do
    @media_id 710_511_363_345_354_753
    @bin File.read!("test/support/fixtures/1x1.png")

    @valid_stubs [
      {
        {:post, "https://upload.twitter.com/1.1/media/upload.json",
         ~r"""
         --.*?\r
         Content-Disposition: form-data; name="command"\r
         \r
         INIT\r
         --.*?\r
         Content-Disposition: form-data; name="media_category"\r
         \r
         tweet_image\r
         --.*?\r
         Content-Disposition: form-data; name="media_type"\r
         \r
         image/png\r
         --.*?\r
         Content-Disposition: form-data; name="total_bytes"\r
         \r
         68\r
         --.*?--\r
         """m},
        json_response(200, """
        {
          "media_id": #{@media_id},
          "media_id_string": "#{@media_id}",
          "size": 68,
          "expires_after_secs": 86400,
          "image": {
            "image_type": "image/png",
            "w": 1,
            "h": 1
          }
        }
        """)
      },
      {
        {:post, "https://upload.twitter.com/1.1/media/upload.json",
         ~r"""
         --.*?\r
         Content-Disposition: form-data; name="command"\r
         \r
         APPEND\r
         --.*?\r
         Content-Disposition: form-data; name="media"\r
         \r
         #{@bin}\r
         --.*?\r
         Content-Disposition: form-data; name="media_id"\r
         \r
         #{@media_id}\r
         --.*?\r
         Content-Disposition: form-data; name="segment_index"\r
         \r
         0\r
         --.*?--\r
         """m},
        html_response(200, "")
      },
      {
        {:post, "https://upload.twitter.com/1.1/media/upload.json",
         ~r"""
         --.*?\r
         Content-Disposition: form-data; name="command"\r
         \r
         FINALIZE\r
         --.*?\r
         Content-Disposition: form-data; name="media_id"\r
         \r
         #{@media_id}\r
         --.*?--\r
         """m},
        json_response(200, """
        {
          "media_id": #{@media_id},
          "media_id_string": "#{@media_id}",
          "size": 68,
          "expires_after_secs": 86400
        }
        """)
      }
    ]

    test "uploads a png file by path" do
      client = stub_client(@valid_stubs)

      assert {:ok, %{media_id: @media_id}} = Media.upload(client, %{path: "test/support/fixtures/1x1.png"})
    end

    test "uploads a png io device" do
      client = stub_client(@valid_stubs)

      File.open("test/support/fixtures/1x1.png", fn device ->
        assert {:ok, %{media_id: @media_id}} =
                 Media.upload(client, %{device: device, media_type: "image/png", total_bytes: 68})
      end)
    end

    test "uploads png binary data" do
      client = stub_client(@valid_stubs)

      assert {:ok, %{media_id: @media_id}} = Media.upload(client, %{data: @bin, media_type: "image/png"})
    end

    test "splits a large file into chunks" do
      size = 1024 * 1024 + 100
      data = for _ <- 1..size, into: "", do: <<0>>

      client =
        stub_client([
          {
            {:post, "https://upload.twitter.com/1.1/media/upload.json",
             ~r"""
             --.*?\r
             Content-Disposition: form-data; name="command"\r
             \r
             INIT\r
             --.*?\r
             Content-Disposition: form-data; name="media_category"\r
             \r
             tweet_video\r
             --.*?\r
             Content-Disposition: form-data; name="media_type"\r
             \r
             video/mp4\r
             --.*?\r
             Content-Disposition: form-data; name="total_bytes"\r
             \r
             #{size}\r
             --.*?--\r
             """m},
            json_response(200, """
            {
              "media_id": #{@media_id},
              "media_id_string": "#{@media_id}",
              "size": 68,
              "expires_after_secs": 86400,
              "image": {
                "image_type": "image/png",
                "w": 1,
                "h": 1
              }
            }
            """)
          },
          {
            {:post, "https://upload.twitter.com/1.1/media/upload.json",
             ~r"""
             --.*?\r
             Content-Disposition: form-data; name="command"\r
             \r
             APPEND\r
             --.*?\r
             Content-Disposition: form-data; name="media"\r
             \r
             #{for _ <- 1..(1024 * 1024), into: "", do: <<0>>}\r
             --.*?\r
             Content-Disposition: form-data; name="media_id"\r
             \r
             #{@media_id}\r
             --.*?\r
             Content-Disposition: form-data; name="segment_index"\r
             \r
             0\r
             --.*?--\r
             """m},
            html_response(200, "")
          },
          {
            {:post, "https://upload.twitter.com/1.1/media/upload.json",
             ~r"""
             --.*?\r
             Content-Disposition: form-data; name="command"\r
             \r
             APPEND\r
             --.*?\r
             Content-Disposition: form-data; name="media"\r
             \r
             #{for _ <- 1..100, into: "", do: <<0>>}\r
             --.*?\r
             Content-Disposition: form-data; name="media_id"\r
             \r
             #{@media_id}\r
             --.*?\r
             Content-Disposition: form-data; name="segment_index"\r
             \r
             1\r
             --.*?--\r
             """m},
            html_response(200, "")
          },
          {
            {:post, "https://upload.twitter.com/1.1/media/upload.json",
             ~r"""
             --.*?\r
             Content-Disposition: form-data; name="command"\r
             \r
             FINALIZE\r
             --.*?\r
             Content-Disposition: form-data; name="media_id"\r
             \r
             #{@media_id}\r
             --.*?--\r
             """m},
            json_response(200, """
            {
              "media_id": #{@media_id},
              "media_id_string": "#{@media_id}",
              "size": 68,
              "expires_after_secs": 86400
            }
            """)
          }
        ])

      assert {:ok, %{media_id: @media_id}} = Media.upload(client, %{data: data, media_type: "video/mp4"})
    end

    test "waits for processing if necessary" do
      client =
        stub_client([
          {
            {:post, "https://upload.twitter.com/1.1/media/upload.json",
             ~r"""
             --.*?\r
             Content-Disposition: form-data; name="command"\r
             \r
             INIT\r
             --.*?\r
             Content-Disposition: form-data; name="media_category"\r
             \r
             tweet_image\r
             --.*?\r
             Content-Disposition: form-data; name="media_type"\r
             \r
             image/png\r
             --.*?\r
             Content-Disposition: form-data; name="total_bytes"\r
             \r
             68\r
             --.*?--\r
             """m},
            json_response(200, """
            {
              "media_id": #{@media_id},
              "media_id_string": "#{@media_id}",
              "size": 68,
              "expires_after_secs": 86400,
              "image": {
                "image_type": "image/png",
                "w": 1,
                "h": 1
              }
            }
            """)
          },
          {
            {:post, "https://upload.twitter.com/1.1/media/upload.json",
             ~r"""
             --.*?\r
             Content-Disposition: form-data; name="command"\r
             \r
             APPEND\r
             --.*?\r
             Content-Disposition: form-data; name="media"\r
             \r
             #{@bin}\r
             --.*?\r
             Content-Disposition: form-data; name="media_id"\r
             \r
             #{@media_id}\r
             --.*?\r
             Content-Disposition: form-data; name="segment_index"\r
             \r
             0\r
             --.*?--\r
             """m},
            html_response(200, "")
          },
          {
            {:post, "https://upload.twitter.com/1.1/media/upload.json",
             ~r"""
             --.*?\r
             Content-Disposition: form-data; name="command"\r
             \r
             FINALIZE\r
             --.*?\r
             Content-Disposition: form-data; name="media_id"\r
             \r
             #{@media_id}\r
             --.*?--\r
             """m},
            json_response(200, """
            {
              "media_id": #{@media_id},
              "media_id_string": "#{@media_id}",
              "size": 68,
              "expires_after_secs": 86400,
              "processing_info": {
                "state": "pending",
                "check_after_secs": 0
              }
            }
            """)
          },
          {
            {:get, "https://upload.twitter.com/1.1/media/upload.json?command=STATUS&media_id=#{@media_id}"},
            json_response(200, """
            {
              "media_id": #{@media_id},
              "media_id_string": "#{@media_id}",
              "size": 68,
              "expires_after_secs": 86400,
              "processing_info": {
                "state": "in_progress",
                "check_after_secs": 0
              }
            }
            """)
          },
          {
            {:get, "https://upload.twitter.com/1.1/media/upload.json?command=STATUS&media_id=#{@media_id}"},
            json_response(200, """
            {
              "media_id": #{@media_id},
              "media_id_string": "#{@media_id}",
              "size": 68,
              "expires_after_secs": 86400,
              "processing_info": {
                "state": "succeeded",
                "progress_percent": 100
              }
            }
            """)
          }
        ])

      assert {:ok, %{media_id: @media_id}} = Media.upload(client, %{data: @bin, media_type: "image/png"})
    end
  end
end
