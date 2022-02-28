defmodule Tw.V1_1.TrendLocation do
  @moduledoc """
  Struct for result of `GET /trends/available.json` or `GET /trends/closes.json`.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/trends/locations-with-trending-topics/api-reference/get-trends-available) for details.
  """

  @enforce_keys [:country, :countryCode, :name, :parentid, :placeType, :url, :woeid]
  defstruct([:country, :countryCode, :name, :parentid, :placeType, :url, :woeid])

  @type t :: %__MODULE__{
          country: binary,
          countryCode: binary,
          name: binary,
          parentid: integer,
          placeType: %{code: non_neg_integer, name: binary},
          url: binary,
          woeid: integer
        }
  @spec decode!(map) :: t
  @doc """
  Decode JSON-decoded map into `t:t/0`
  """
  def decode!(json), do: struct(__MODULE__, json)
end
