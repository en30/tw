defmodule Tw.V1_1.TrendLocation do
  @moduledoc """
  Struct for result of `GET /trends/available.json` or `GET /trends/closes.json`.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/trends/locations-with-trending-topics/api-reference/get-trends-available) for details.
  """

  import Tw.V1_1.Schema, only: :macros

  defobject("priv/schema/model/trend_location.json")
end
