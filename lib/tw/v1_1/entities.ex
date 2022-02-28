defmodule Tw.V1_1.Entities do
  @moduledoc """
  Entities data structure and related functions.
  https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/entities
  """

  alias Tw.V1_1.Hashtag
  alias Tw.V1_1.Media
  alias Tw.V1_1.Poll
  alias Tw.V1_1.Schema
  alias Tw.V1_1.Symbol
  alias Tw.V1_1.URL
  alias Tw.V1_1.UserMention

  @enforce_keys []
  defstruct([:hashtags, :media, :urls, :user_mentions, :symbols, :polls])

  @typedoc """
  > | field | description |
  > | - | - |
  > | `hashtags` | Represents hashtags which have been parsed out of the Tweet text.  |
  > | `media` | Represents media elements uploaded with the Tweet.  |
  > | `urls` | Represents URLs included in the text of a Tweet. |
  > | `user_mentions` | Represents other Twitter users mentioned in the text of the Tweet.  |
  > | `symbols` | Represents symbols, i.e. $cashtags, included in the text of the Tweet.  |
  > | `polls` | Represents Twitter Polls included in the Tweet.  |
  >
  """
  @type t :: %__MODULE__{
          hashtags: list(Hashtag.t()) | nil,
          media: list(Media.t()) | nil,
          urls: list(URL.t()) | nil,
          user_mentions: list(UserMention.t()) | nil,
          symbols: list(Symbol.t()) | nil,
          polls: list(Poll.t()) | nil
        }
  @spec decode!(map) :: t
  @doc """
  Decode JSON-decoded map into `t:t/0`
  """
  def decode!(json) do
    json =
      json
      |> Map.update(:hashtags, nil, Schema.nilable(fn v -> Enum.map(v, &Hashtag.decode!/1) end))
      |> Map.update(:media, nil, Schema.nilable(fn v -> Enum.map(v, &Media.decode!/1) end))
      |> Map.update(:urls, nil, Schema.nilable(fn v -> Enum.map(v, &URL.decode!/1) end))
      |> Map.update(:user_mentions, nil, Schema.nilable(fn v -> Enum.map(v, &UserMention.decode!/1) end))
      |> Map.update(:symbols, nil, Schema.nilable(fn v -> Enum.map(v, &Symbol.decode!/1) end))
      |> Map.update(:polls, nil, Schema.nilable(fn v -> Enum.map(v, &Poll.decode!/1) end))

    struct(__MODULE__, json)
  end
end
