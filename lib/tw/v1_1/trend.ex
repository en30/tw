defmodule Tw.V1_1.Trend do
  @moduledoc """
  Struct for result of `GET /trends/place.json` and trend related functions.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/trends/trends-for-location/api-reference/get-trends-place) for details.
  """

  alias Tw.V1_1.Client
  alias Tw.V1_1.TrendLocation

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

  ##################################
  # GET /trends/place.json
  ##################################

  @typedoc """
  Parameters for `at/3`.

  > | name | description |
  > | - | - |
  > |id | The numeric value that represents the location from where to return trending information for from. Formerly linked to the Yahoo! Where On Earth ID Global information is available by using 1 as the WOEID . |
  > |exclude | Setting this equal to hashtags will remove all hashtags from the trends list. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/trends/trends-for-location/api-reference/get-trends-place) for details.

  """
  @type at_params :: %{required(:id) => integer, optional(:exclude) => binary}
  @spec at(Client.t(), at_params) ::
          {:ok,
           list(%{
             trends: list(t()),
             as_of: DateTime.t(),
             created_at: DateTime.t(),
             locations: list(%{name: binary, woeid: non_neg_integer()})
           })}
          | {:error, Client.error()}
  @doc """
  Request `GET /trends/place.json` and return decoded result.
  > Returns the top 50 trending topics for a specific id, if trending information is available for it.
  >
  > Note: The id parameter for this endpoint is the \"where on earth identifier\" or WOEID, which is a legacy identifier created by Yahoo and has been deprecated. Twitter API v1.1 still uses the numeric value to identify town and country trend locations. Reference our legacy blog post, or archived data
  >
  > Example WOEID locations include: Worldwide: 1 UK: 23424975 Brazil: 23424768 Germany: 23424829 Mexico: 23424900 Canada: 23424775 United States: 23424977 New York: 2459115
  >
  > To identify other ids, please use the GET trends/available endpoint.
  >
  > The response is an array of trend objects that encode the name of the trending topic, the query parameter that can be used to search for the topic on Twitter Search, and the Twitter Search URL.
  >
  > The most up to date info available is returned on request. The created_at field will show when the oldest trend started trending. The as_of field contains the timestamp when the list of trends was created.
  >
  > The tweet_volume for the last 24 hours is also returned for many trends if this is available.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/trends/trends-for-location/api-reference/get-trends-place) for details.

  """
  def at(client, params) do
    with {:ok, json} <- Client.request(client, :get, "/trends/place.json", params) do
      res =
        json
        |> Enum.map(fn e ->
          e
          |> Map.update!(:trends, &decode!/1)
          |> Map.update!(:as_of, &DateTime.from_iso8601/1)
          |> Map.update!(:created_at, &DateTime.from_iso8601/1)
        end)

      {:ok, res}
    end
  end

  ##################################
  # GET /trends/available.json
  ##################################

  @typedoc """
  Parameters for `available_locations/3`.

  > | name | description |
  > | - | - |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/trends/locations-with-trending-topics/api-reference/get-trends-available) for details.

  """
  @type available_locations_params :: %{}
  @spec available_locations(Client.t(), available_locations_params) ::
          {:ok, list(TrendLocation.t())} | {:error, Client.error()}
  @doc """
  Request `GET /trends/available.json` and return decoded result.
  > Returns the locations that Twitter has trending topic information for.
  >
  > The response is an array of \"locations\" that encode the location's WOEID and some other human-readable information such as a canonical name and country the location belongs in.
  >
  > Note: This endpoint uses the \"where on earth identifier\" or WOEID, which is a legacy identifier created by Yahoo and has been deprecated. Twitter API v1.1 still uses the numeric value to identify town and country trend locations. Reference our legacy blog post for more details. The url returned in the response, where.yahooapis.com is no longer valid.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/trends/locations-with-trending-topics/api-reference/get-trends-available) for details.

  """
  def available_locations(client, params) do
    with {:ok, json} <- Client.request(client, :get, "/trends/available.json", params) do
      res = json |> Enum.map(fn e -> e |> TrendLocation.decode!() end)
      {:ok, res}
    end
  end

  ##################################
  # GET /trends/closest.json
  ##################################

  @typedoc """
  Parameters for `closest_locations/3`.

  > | name | description |
  > | - | - |
  > |lat | If provided with a long parameter the available trend locations will be sorted by distance, nearest to furthest, to the co-ordinate pair. The valid ranges for longitude is -180.0 to +180.0 (West is negative, East is positive) inclusive. |
  > |long | If provided with a lat parameter the available trend locations will be sorted by distance, nearest to furthest, to the co-ordinate pair. The valid ranges for longitude is -180.0 to +180.0 (West is negative, East is positive) inclusive. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/trends/locations-with-trending-topics/api-reference/get-trends-closest) for details.

  """
  @type closest_locations_params :: %{required(:lat) => binary, required(:long) => binary}
  @spec closest_locations(Client.t(), closest_locations_params) ::
          {:ok, list(TrendLocation.t())} | {:error, Client.error()}
  @doc """
  Request `GET /trends/closest.json` and return decoded result.
  > Returns the locations that Twitter has trending topic information for, closest to a specified location.
  >
  > The response is an array of \"locations\" that encode the location's WOEID and some other human-readable information such as a canonical name and country the location belongs in.
  >
  > Note: The \"where on earth identifier\" or WOEID, is a legacy identifier created by Yahoo and has been deprecated. Twitter API v1.1 still uses the numeric value to identify town and country trend locations. Reference our legacy blog post, or archived data. The url returned in the response, where.yahooapis.com is no longer valid.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/trends/locations-with-trending-topics/api-reference/get-trends-closest) for details.

  """
  def closest_locations(client, params) do
    with {:ok, json} <- Client.request(client, :get, "/trends/closest.json", params) do
      res = json |> Enum.map(fn e -> e |> TrendLocation.decode!() end)
      {:ok, res}
    end
  end
end
