defmodule Tw.V1_1.FriendshipLookupResult do
  @moduledoc """
  Struct for search result from GET /friendships/lookup.json.
  https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/follow-search-get-users/api-reference/get-friendships-lookup
  """

  alias Tw.V1_1.FriendshipLookupResult

  @enforce_keys [:name, :screen_name, :id, :id_str, :connections]
  defstruct([:name, :screen_name, :id, :id_str, :connections])

  @type connections :: list(:following | :following_requested | :followed_by | :none | :blocking | :muting)
  @type t :: %__MODULE__{
          name: binary,
          screen_name: binary,
          id: integer,
          id_str: binary,
          connections: connections()
        }
  @spec decode!(map) :: t
  @doc """
  Decode JSON-decoded map into `t:t/0`
  """
  def decode!(json) do
    json =
      json
      |> Map.update!(:connections, fn v -> Enum.map(v, &FriendshipLookupResult.decode_connection!/1) end)

    struct(__MODULE__, json)
  end

  @connections ~W[following following_requested followed_by none blocking muting]
  def decode_connection!(str) do
    if Enum.member?(@connections, str) do
      String.to_atom(str)
    else
      :unknown
    end
  end
end
