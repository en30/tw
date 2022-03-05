defmodule Tw.V1_1.TrendLocation do
  @moduledoc """
  Struct for result of `GET /trends/available.json` or `GET /trends/closes.json`.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/trends/locations-with-trending-topics/api-reference/get-trends-available) for details.
  """

  @enforce_keys [:country, :country_code, :name, :parentid, :place_type, :url, :woeid]
  defstruct([:country, :country_code, :name, :parentid, :place_type, :url, :woeid])

  @type t :: %__MODULE__{
          country: binary,
          country_code: binary,
          name: binary,
          parentid: integer,
          place_type: %{code: non_neg_integer, name: binary},
          url: binary,
          woeid: integer
        }
  @spec decode!(map) :: t
  @doc """
  Decode JSON-decoded map into `t:t/0`
  """
  def decode!(json) do
    json =
      json
      |> Map.put(:country_code, json.countryCode)
      |> Map.put(:place_type, json.placeType)

    struct(__MODULE__, json)
  end
end
