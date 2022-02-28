defmodule Tw.V1_1.Hashtag do
  @moduledoc """
  Hashtag data structure and related functions.
  https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/entities
  """

  @enforce_keys [:indices, :text]
  defstruct([:indices, :text])

  @typedoc """
  > | field | description |
  > | - | - |
  > | `indices` | An array of integers indicating the offsets within the Tweet text where the hashtag begins and ends. The first integer represents the location of the # character in the Tweet text string. The second integer represents the location of the first character after the hashtag. Therefore the difference between the two numbers will be the length of the hashtag name plus one (for the ‘#’ character). Example: `[32,38] `.  |
  > | `text` | Name of the hashtag, minus the leading ‘#’ character. Example: `\"nodejs\" `.  |
  >
  """
  @type t :: %__MODULE__{indices: list(integer), text: binary}
  @spec decode!(map) :: t
  @doc """
  Decode JSON-decoded map into `t:t/0`
  """
  def decode!(json), do: struct(__MODULE__, json)
end
