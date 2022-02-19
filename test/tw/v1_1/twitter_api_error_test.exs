defmodule Tw.V1_1.TwitterAPIErrorTest do
  use ExUnit.Case, async: true

  alias Tw.V1_1.TwitterAPIError

  @not_found_response %{
    status: 404,
    headers: [],
    body: """
    {"errors":[{"message":"Sorry, that page does not exist","code":34}]}
    """
  }

  @rate_limite_exceeded_response %{
    status: 429,
    headers: [
      {"x-rate-limit-limit", "180"},
      {"x-rate-limit-remaining", "0"},
      {"x-rate-limit-reset", "1645095195"}
    ],
    body: """
    { "errors": [ { "code": 88, "message": "Rate limit exceeded" } ] }
    """
  }

  describe "from_response/1" do
    @invalid_response %{
      status: 500,
      headers: [],
      body: ""
    }

    test "decodes valid error json and returns TwitterAPIError" do
      error = TwitterAPIError.from_response(@not_found_response)
      assert %TwitterAPIError{} = error

      assert error.message == "Sorry, that page does not exist"
      assert error.errors == [%{message: "Sorry, that page does not exist", code: 34}]
      assert error.response == @not_found_response
    end

    test "returns TwitterAPIError even if an invalid response is given" do
      error = TwitterAPIError.from_response(@invalid_response)
      assert %TwitterAPIError{} = error

      assert error.message == "Unknown Twitter API Error"
      assert error.errors == []
      assert error.response == @invalid_response
    end
  end

  describe "rate_limit_exceeded?/1" do
    test "returns false if an irrelevant error is given" do
      error = TwitterAPIError.from_response(@not_found_response)
      refute TwitterAPIError.rate_limit_exceeded?(error)
    end

    test "returns true if a rate limit exceeded error is given" do
      error = TwitterAPIError.from_response(@rate_limite_exceeded_response)
      assert TwitterAPIError.rate_limit_exceeded?(error)
    end
  end

  describe "rate_limit_reset_at/1" do
    test "returns nil if an irrelevant error is given" do
      error = TwitterAPIError.from_response(@not_found_response)
      assert TwitterAPIError.rate_limit_reset_at(error) == nil
    end

    test "returns DateTime if a rate limit exceeded error is given" do
      error = TwitterAPIError.from_response(@rate_limite_exceeded_response)
      assert ~U[2022-02-17 10:53:15Z] = TwitterAPIError.rate_limit_reset_at(error)
    end
  end
end
