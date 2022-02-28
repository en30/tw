defmodule Tw.V1_1.FriendshipTarget do
  @moduledoc """
  Struct for result from GET /friendships/show.json.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/follow-search-get-users/api-reference/get-friendships-show) for details.
  """

  @enforce_keys [:id, :id_str, :screen_name, :following, :followed_by, :following_received, :following_requested]
  defstruct([:id, :id_str, :screen_name, :following, :followed_by, :following_received, :following_requested])

  @type t :: %__MODULE__{
          id: integer,
          id_str: binary,
          screen_name: binary,
          following: boolean,
          followed_by: boolean,
          following_received: boolean | nil,
          following_requested: boolean | nil
        }
  @spec decode!(map) :: t
  @doc """
  Decode JSON-decoded map into `t:t/0`
  """
  def decode!(json), do: struct(__MODULE__, json)
end
