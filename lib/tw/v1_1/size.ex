defmodule Tw.V1_1.Size do
  @moduledoc """
  Size data structure and related functions.
  https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/entities
  """

  @enforce_keys [:w, :h, :resize]
  defstruct([:w, :h, :resize])

  @typedoc """
  > | field | description |
  > | - | - |
  > | `w` | Width in pixels of this size. Example: `  150  `.  |
  > | `h` | Height in pixels of this size. Example: `  150  `.  |
  > | `resize` | Resizing method used to obtain this size. A value of fit means that the media was resized to fit one dimension, keeping its native aspect ratio. A value of crop means that the media was cropped in order to fit a specific resolution. Example: `  \"crop\"   `.  |
  >
  """
  @type t :: %__MODULE__{w: integer, h: integer, resize: binary}
  @spec decode!(map) :: t
  @doc """
  Decode JSON-decoded map into `t:t/0`
  """
  def decode!(json), do: struct(__MODULE__, json)
end
