defmodule Tw.HTTP.ResponseTest do
  use ExUnit.Case, async: true

  alias Tw.HTTP.Response

  describe "new/1" do
    test "makes header keys to downcase" do
      resp =
        Response.new(
          status: 200,
          headers: [{"X-Some-Key", "foo"}, {"X-Some-Key-2", "bar"}],
          body: ""
        )

      assert resp.headers == [{"x-some-key", "foo"}, {"x-some-key-2", "bar"}]
    end
  end

  describe "get_header/2" do
    test "returns empty list if there is no value" do
      resp =
        Response.new(
          status: 200,
          headers: [{"X-Some-Key", "foo"}, {"X-Some-Key-2", "bar"}],
          body: ""
        )

      assert Response.get_header(resp, "x-no-key") == []
    end

    test "returns values" do
      resp =
        Response.new(
          status: 200,
          headers: [{"X-Some-Key", "foo"}, {"X-Some-Key", "bar"}],
          body: ""
        )

      assert Response.get_header(resp, "x-some-key") == ["foo", "bar"]
    end
  end
end
