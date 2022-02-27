defmodule Tw.V1_1.TwitterAPIErrorTest do
  use ExUnit.Case, async: true

  alias Tw.HTTP.Response
  alias Tw.V1_1.TwitterAPIError

  @not_found_response Response.new(
                        status: 404,
                        headers: [],
                        body: """
                        {"errors":[{"message":"Sorry, that page does not exist","code":34}]}
                        """
                      )

  @rate_limite_exceeded_response Response.new(
                                   status: 429,
                                   headers: [
                                     {"x-rate-limit-limit", "180"},
                                     {"x-rate-limit-remaining", "0"},
                                     {"x-rate-limit-reset", "1645095195"}
                                   ],
                                   body: """
                                   { "errors": [ { "code": 88, "message": "Rate limit exceeded" } ] }
                                   """
                                 )

  describe "from_response/2" do
    @invalid_response Response.new(
                        status: 500,
                        headers: [],
                        body: ""
                      )

    test "decodes valid error json and returns TwitterAPIError" do
      error = TwitterAPIError.from_response(@not_found_response, Jason.decode!(@not_found_response.body))
      assert %TwitterAPIError{} = error

      assert error.message == "Sorry, that page does not exist"
      assert error.errors == [%{message: "Sorry, that page does not exist", code: 34}]
      assert error.response == @not_found_response
    end

    test "returns TwitterAPIError even if an invalid response is given" do
      error = TwitterAPIError.from_response(@invalid_response, nil)
      assert %TwitterAPIError{} = error

      assert error.message == "Unknown Twitter API Error"
      assert error.errors == []
      assert error.response == @invalid_response
    end
  end

  describe "rate_limit_exceeded?/1" do
    test "returns false if an irrelevant error is given" do
      error = TwitterAPIError.from_response(@not_found_response, Jason.decode!(@not_found_response.body))
      refute TwitterAPIError.rate_limit_exceeded?(error)
    end

    test "returns true if a rate limit exceeded error is given" do
      error =
        TwitterAPIError.from_response(
          @rate_limite_exceeded_response,
          Jason.decode!(@rate_limite_exceeded_response.body)
        )

      assert TwitterAPIError.rate_limit_exceeded?(error)
    end
  end

  describe "rate_limit_reset_at/1" do
    test "returns nil if an irrelevant error is given" do
      error = TwitterAPIError.from_response(@not_found_response, Jason.decode!(@not_found_response.body))
      assert TwitterAPIError.rate_limit_reset_at(error) == nil
    end

    test "returns DateTime if a rate limit exceeded error is given" do
      error =
        TwitterAPIError.from_response(
          @rate_limite_exceeded_response,
          Jason.decode!(@rate_limite_exceeded_response.body)
        )

      assert ~U[2022-02-17 10:53:15Z] = TwitterAPIError.rate_limit_reset_at(error)
    end
  end
end
