defmodule Tw.V1_1.Trend do
  @moduledoc """
  Struct for result of `GET /trends/place.json` and trend related functions.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/trends/trends-for-location/api-reference/get-trends-place) for details.
  """

  import Tw.V1_1.Schema, only: :macros

  defobject("priv/schema/model/trend.json")

  map_endpoint(:get, "/trends/place.json", to: at)
  map_endpoint(:get, "/trends/available.json", to: available_locations)
  map_endpoint(:get, "/trends/closest.json", to: closest_locations)
end
