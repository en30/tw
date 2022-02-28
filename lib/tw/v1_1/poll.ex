defmodule Tw.V1_1.Poll do
  @moduledoc """
  Poll data structure and related functions.
  https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/entities
  """

  @enforce_keys [:options, :end_datetime, :duration_minutes]
  defstruct([:options, :end_datetime, :duration_minutes])

  @typedoc """
  > | field | description |
  > | - | - |
  > | `options` | An array of options, each having a poll position, and the text for that position. Example: `{[           {             \"position\": 1,             \"text\": \"I read documentation once.\"           }       ] } `.  |
  > | `end_datetime` | Time stamp (UTC) of when poll ends. Example: `\"Thu May 25 22:20:27 +0000 2017\" `.  |
  > | `duration_minutes` | Duration of poll in minutes. Example: `60 `.  |
  >
  """
  @type t :: %__MODULE__{options: list(map), end_datetime: binary, duration_minutes: binary}
  @spec decode!(map) :: t
  @doc """
  Decode JSON-decoded map into `t:t/0`
  """
  def decode!(json), do: struct(__MODULE__, json)
end
