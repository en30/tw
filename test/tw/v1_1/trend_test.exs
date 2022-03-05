defmodule Tw.V1_1.TrendTest do
  alias Tw.V1_1.Trend
  alias Tw.V1_1.TrendLocation

  use ExUnit.Case, async: true

  import Tw.V1_1.EndpointHelper

  test "at/2 requests /trends/place.json and returns decoded resutls" do
    client =
      stub_client([
        {
          {:get, "https://api.twitter.com/1.1/trends/place.json?id=1"},
          json_response(200, File.read!("test/support/fixtures/v1_1/trends/place.json"))
        }
      ])

    assert {:ok, [trend | _]} = Trend.at(client, %{id: 1})
    assert [%Trend{} | _] = trend.trends
    assert trend.as_of == ~U[2020-11-20 19:37:52Z]
    assert trend.created_at == ~U[2020-11-19 14:15:43Z]
    assert trend.locations == [%{name: "Worldwide", woeid: 1}]
  end

  test "available_locations/1 requests /trends/available.json and returns decoded resutls" do
    client =
      stub_client([
        {
          {:get, "https://api.twitter.com/1.1/trends/available.json?"},
          json_response(200, File.read!("test/support/fixtures/v1_1/trends/available.json"))
        }
      ])

    assert {:ok,
            [
              %TrendLocation{
                country: "Sweden",
                country_code: "SE",
                name: "Sweden",
                parentid: 1,
                place_type: %{code: 12, name: "Country"},
                url: "http://where.yahooapis.com/v1/place/23424954",
                woeid: 23_424_954
              }
              | _
            ]} = Trend.available_locations(client)
  end

  test "closest_locations/2 requests /trends/closest.json and returns decoded resutls" do
    client =
      stub_client([
        {
          {:get, "https://api.twitter.com/1.1/trends/closest.json?lat=37.781157&long=-122.400612831116"},
          json_response(200, File.read!("test/support/fixtures/v1_1/trends/closest.json"))
        }
      ])

    assert {:ok,
            [
              %TrendLocation{
                country: "Australia",
                country_code: "AU",
                name: "Australia",
                parentid: 1,
                place_type: %{code: 12, name: "Country"},
                url: "http://where.yahooapis.com/v1/place/23424748",
                woeid: 23_424_748
              }
              | _
            ]} = Trend.closest_locations(client, %{lat: "37.781157", long: "-122.400612831116"})
  end
end
