defmodule Tw.V1_1.Symbol do
  @moduledoc """
  Symbol data structure and related functions.
  https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/entities
  """

  @enforce_keys [:indices, :text]
  defstruct([:indices, :text])

  @typedoc """
  > | field | description |
  > | - | - |
  > | `indices` | An array of integers indicating the offsets within the Tweet text where the symbol/cashtag begins and ends. The first integer represents the location of the $ character in the Tweet text string. The second integer represents the location of the first character after the cashtag. Therefore the difference between the two numbers will be the length of the hashtag name plus one (for the ‘$’ character). Example: `[12,17] `.  |
  > | `text` | Name of the cashhtag, minus the leading ‘$’ character. Example: `\"twtr\" `.  |
  >
  """
  @type t :: %__MODULE__{indices: list(integer), text: binary}
  @spec decode!(map) :: t
  @doc """
  Decode JSON-decoded map into `t:t/0`
  """
  def decode!(json), do: struct(__MODULE__, json)
end
