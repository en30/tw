defmodule Tw.V1_1.TwitterAPIErrorTest do
  use ExUnit.Case, async: true

  alias Tw.V1_1.TwitterAPIError

  describe "from_response/1" do
    @valid_response %{
      status: 404,
      headers: [],
      body: """
      {"errors":[{"message":"Sorry, that page does not exist","code":34}]}
      """
    }

    @invalid_response %{
      status: 500,
      headers: [],
      body: ""
    }

    test "decodes valid error json and returns TwitterAPIError" do
      error = TwitterAPIError.from_response(@valid_response)
      assert %TwitterAPIError{} = error

      assert error.message == "Sorry, that page does not exist"
      assert error.errors == [%{message: "Sorry, that page does not exist", code: 34}]
      assert error.response == @valid_response
    end

    test "returns TwitterAPIError even if an invalid response is given" do
      error = TwitterAPIError.from_response(@invalid_response)
      assert %TwitterAPIError{} = error

      assert error.message == "Unknown Twitter API Error"
      assert error.errors == []
      assert error.response == @invalid_response
    end
  end
end
