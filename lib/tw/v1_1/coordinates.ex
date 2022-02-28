defmodule Tw.V1_1.Coordinates do
  @moduledoc """
  Coordinates data structure and related functions.
  https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/geo
  """

  @enforce_keys [:coordinates, :type]
  defstruct([:coordinates, :type])

  @typedoc """
  > | field | description |
  > | - | - |
  > | `coordinates` | The longitude and latitude of the Tweet’s location, as a collection in the form [longitude, latitude]. Example: `[-97.51087576,35.46500176] `.  |
  > | `type` | The type of data encoded in the coordinates property. This will be “Point” for Tweet coordinates fields. Example: `\"Point\" `.  |
  >
  """
  @type t :: %__MODULE__{coordinates: list(float), type: binary}
  @spec decode!(map) :: t
  @doc """
  Decode JSON-decoded map into `t:t/0`
  """
  def decode!(json), do: struct(__MODULE__, json)
end
