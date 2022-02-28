defmodule Tw.V1_1.Sizes do
  @moduledoc """
  Sizes data structure and related functions.
  https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/entities
  """

  alias Tw.V1_1.Size

  @enforce_keys [:thumb, :large, :medium, :small]
  defstruct([:thumb, :large, :medium, :small])

  @typedoc """
  > | field | description |
  > | - | - |
  > | `thumb` | Information for a thumbnail-sized version of the media.  |
  > | `large` | Information for a large-sized version of the media.  |
  > | `medium` | Information for a medium-sized version of the media.  |
  > | `small` | Information for a small-sized version of the media.  |
  >
  """
  @type t :: %__MODULE__{
          thumb: Size.t(),
          large: Size.t(),
          medium: Size.t(),
          small: Size.t()
        }
  @spec decode!(map) :: t
  @doc """
  Decode JSON-decoded map into `t:t/0`
  """
  def decode!(json) do
    json =
      json
      |> Map.update!(:thumb, &Size.decode!/1)
      |> Map.update!(:large, &Size.decode!/1)
      |> Map.update!(:medium, &Size.decode!/1)
      |> Map.update!(:small, &Size.decode!/1)

    struct(__MODULE__, json)
  end
end
