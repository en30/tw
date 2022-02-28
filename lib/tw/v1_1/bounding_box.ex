defmodule Tw.V1_1.BoundingBox do
  @moduledoc """
  Bounding Box data structure and related functions.
  https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/geo
  """

  @enforce_keys [:coordinates, :type]
  defstruct([:coordinates, :type])

  @typedoc """
  > | field | description |
  > | - | - |
  > | `coordinates` | A series of longitude and latitude points, defining a box which will contain the Place entity this bounding box is related to. Each point is an array in the form of [longitude, latitude]. Points are grouped into an array per bounding box. Bounding box arrays are wrapped in one additional array to be compatible with the polygon notation. Example: `{[     [       [         -74.026675,         40.683935       ],       [         -74.026675,         40.877483       ],       [         -73.910408,         40.877483       ],       [         -73.910408,         40.3935       ]     ]   ] } `.  |
  > | `type` | The type of data encoded in the coordinates property. This will be “Polygon” for bounding boxes and “Point” for Tweets with exact coordinates. Example: `\"Polygon\" `.  |
  >
  """
  @type t :: %__MODULE__{coordinates: list(list(list(float))), type: binary}
  @spec decode!(map) :: t
  @doc """
  Decode JSON-decoded map into `t:t/0`
  """
  def decode!(json), do: struct(__MODULE__, json)
end
