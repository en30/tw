defmodule Tw.HTTP.MultipartFormDataTest do
  use ExUnit.Case, async: true

  alias Tw.HTTP.MultipartFormData

  @boundary "boundary"
  @multipart_form_data MultipartFormData.new(
                         boundary: @boundary,
                         parts: [
                           {"hoge_id", "42"},
                           {"content",
                            """
                            a
                            b
                            c
                            """}
                         ]
                       )

  test "content_type/1 returns content type header value" do
    assert MultipartFormData.content_type(@multipart_form_data) == "multipart/form-data; boundary=boundary"
  end

  test "contede/1 returns encoded binary" do
    expected =
      [
        "--boundary\r\n",
        "Content-Disposition: form-data; name=\"content\"\r\n\r\n",
        "a\nb\nc\n\r\n",
        "--boundary\r\n",
        "Content-Disposition: form-data; name=\"hoge_id\"\r\n\r\n",
        "42\r\n",
        "--boundary--\r\n\r\n"
      ]
      |> IO.iodata_to_binary()

    assert MultipartFormData.encode(@multipart_form_data) == expected
  end
end
