defmodule Tw.V1_1.UserMention do
  @moduledoc """
  UserMention data structure and related functions.
  https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/entities
  """

  @enforce_keys [:id, :id_str, :indices, :name, :screen_name]
  defstruct([:id, :id_str, :indices, :name, :screen_name])

  @typedoc """
  > | field | description |
  > | - | - |
  > | `id` | ID of the mentioned user, as an integer. Example: `6253282 `.  |
  > | `id_str` | If of the mentioned user, as a string. Example: `\"6253282\" `.  |
  > | `indices` | An array of integers representing the offsets within the Tweet text where the user reference begins and ends. The first integer represents the location of the ‘@’ character of the user mention. The second integer represents the location of the first non-screenname character following the user mention. Example: `[4,15] `.  |
  > | `name` | Display name of the referenced user. Example: `\"Twitter API\" `.  |
  > | `screen_name` | Screen name of the referenced user. Example: `\"twitterapi\" `.  |
  >
  """
  @type t :: %__MODULE__{id: integer, id_str: binary, indices: list(integer), name: binary, screen_name: binary}
  @spec decode!(map) :: t
  @doc """
  Decode JSON-decoded map into `t:t/0`
  """
  def decode!(json), do: struct(__MODULE__, json)
end
