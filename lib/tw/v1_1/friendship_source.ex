defmodule Tw.V1_1.FriendshipSource do
  @moduledoc """
  Struct for result from GET /friendships/show.json.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/follow-search-get-users/api-reference/get-friendships-show) for details.
  """

  @enforce_keys [
    :id,
    :id_str,
    :screen_name,
    :following,
    :followed_by,
    :live_following,
    :following_received,
    :following_requested,
    :notifications_enabled,
    :can_dm,
    :blocking,
    :blocked_by,
    :muting,
    :want_retweets,
    :all_replies,
    :marked_spam
  ]
  defstruct([
    :id,
    :id_str,
    :screen_name,
    :following,
    :followed_by,
    :live_following,
    :following_received,
    :following_requested,
    :notifications_enabled,
    :can_dm,
    :blocking,
    :blocked_by,
    :muting,
    :want_retweets,
    :all_replies,
    :marked_spam
  ])

  @type t :: %__MODULE__{
          id: integer,
          id_str: binary,
          screen_name: binary,
          following: boolean,
          followed_by: boolean,
          live_following: boolean,
          following_received: boolean | nil,
          following_requested: boolean | nil,
          notifications_enabled: boolean | nil,
          can_dm: boolean,
          blocking: boolean | nil,
          blocked_by: boolean | nil,
          muting: boolean | nil,
          want_retweets: boolean | nil,
          all_replies: boolean | nil,
          marked_spam: boolean | nil
        }
  @spec decode!(map) :: t
  @doc """
  Decode JSON-decoded map into `t:t/0`
  """
  def decode!(json), do: struct(__MODULE__, json)
end
