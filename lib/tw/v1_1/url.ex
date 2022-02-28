defmodule Tw.V1_1.URL do
  @moduledoc """
  URL data structure and related functions.
  https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/entities
  """

  @enforce_keys [:display_url, :expanded_url, :indices, :url]
  defstruct([:display_url, :expanded_url, :indices, :url])

  @typedoc """
  > | field | description |
  > | - | - |
  > | `display_url` | URL pasted/typed into Tweet. Example: `\"bit.ly/2so49n2\" `.  |
  > | `expanded_url` | Expanded version of `` display_url`` . Example: `\"http://bit.ly/2so49n2\" `.  |
  > | `indices` | An array of integers representing offsets within the Tweet text where the URL begins and ends. The first integer represents the location of the first character of the URL in the Tweet text. The second integer represents the location of the first non-URL character after the end of the URL. Example: `[30,53] `.  |
  > | `url` | Wrapped URL, corresponding to the value embedded directly into the raw Tweet text, and the values for the indices parameter. Example: `\"https://t.co/yzocNFvJuL\" `.  |
  >
  """
  @type t :: %__MODULE__{display_url: binary, expanded_url: binary, indices: list(integer), url: binary}
  @spec decode!(map) :: t
  @doc """
  Decode JSON-decoded map into `t:t/0`
  """
  def decode!(json), do: struct(__MODULE__, json)
end
