defmodule Tw.V1_1.Place do
  @moduledoc """
  Place data structure and related functions.
  https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/geo
  """

  alias Tw.V1_1.BoundingBox

  @type id :: binary()

  @enforce_keys [:id, :url, :place_type, :name, :full_name, :country_code, :country, :bounding_box, :attributes]
  defstruct([:id, :url, :place_type, :name, :full_name, :country_code, :country, :bounding_box, :attributes])

  @typedoc """
  > | field | description |
  > | - | - |
  > | `id` | ID representing this place. Note that this is represented as a string, not an integer. Example: `\"01a9a39529b27f36\" `.  |
  > | `url` | URL representing the location of additional place metadata for this place. Example: `\"https://api.twitter.com/1.1/geo/id/01a9a39529b27f36.json\" `.  |
  > | `place_type` | The type of location represented by this place. Example: `\"city\" `.  |
  > | `name` | Short human-readable representation of the place’s name. Example: `\"Manhattan\" `.  |
  > | `full_name` | Full human-readable representation of the place’s name. Example: `\"Manhattan, NY\" `.  |
  > | `country_code` | Shortened country code representing the country containing this place. Example: `\"US\" `.  |
  > | `country` | Name of the country containing this place. Example: `\"United States\" `.  |
  > | `bounding_box` | A bounding box of coordinates which encloses this place.  |
  > | `attributes` | When using PowerTrack, 30-Day and Full-Archive Search APIs, and Volume Streams this hash is null. Example: `{} `.  |
  >
  """
  @type t :: %__MODULE__{
          id: id(),
          url: binary,
          place_type: binary,
          name: binary,
          full_name: binary,
          country_code: binary,
          country: binary,
          bounding_box: BoundingBox.t(),
          attributes: map
        }
  @spec decode!(map) :: t
  @doc """
  Decode JSON-decoded map into `t:t/0`
  """
  def decode!(json) do
    json =
      json
      |> Map.update!(:bounding_box, &BoundingBox.decode!/1)

    struct(__MODULE__, json)
  end
end
