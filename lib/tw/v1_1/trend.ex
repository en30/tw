defmodule Tw.V1_1.Trend do
  @moduledoc """
  Struct for result of `GET /trends/place.json` and trend related functions.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/trends/trends-for-location/api-reference/get-trends-place) for details.
  """

  import Tw.V1_1.Schema, only: :macros

  @enforce_keys [:name, :url, :promoted_content, :query, :tweet_volume]
  defstruct([:name, :url, :promoted_content, :query, :tweet_volume])

  @type t :: %__MODULE__{
          name: binary,
          url: binary,
          promoted_content: boolean | nil,
          query: binary,
          tweet_volume: integer | nil
        }
  @spec decode!(map) :: t
  @doc """
  Decode JSON-decoded map into `t:t/0`
  """
  def decode!(json), do: struct(__MODULE__, json)

  map_endpoint(:get, "/trends/place.json", to: at)
  map_endpoint(:get, "/trends/available.json", to: available_locations)
  map_endpoint(:get, "/trends/closest.json", to: closest_locations)
end
