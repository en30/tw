defmodule Tw.V1_1.Friendship do
  @moduledoc """
  Module for `friendships/*` endpoints.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/follow-search-get-users/api-reference/get-friendships-show) for details.
  """

  alias Tw.V1_1.Client
  alias Tw.V1_1.CursoredResult
  alias Tw.V1_1.FriendshipLookupResult
  alias Tw.V1_1.FriendshipSource
  alias Tw.V1_1.FriendshipTarget
  alias Tw.V1_1.User

  @enforce_keys [:source, :target]
  defstruct([:source, :target])

  @type t :: %__MODULE__{source: FriendshipSource.t(), target: FriendshipTarget.t()}
  @spec decode!(map) :: t
  @doc """
  Decode JSON-decoded map into `t:t/0`
  """
  def decode!(json) do
    json =
      json
      |> Map.update!(:source, &FriendshipSource.decode!/1)
      |> Map.update!(:target, &FriendshipTarget.decode!/1)

    struct(__MODULE__, json)
  end

  ##################################
  # GET /friendships/incoming.json
  ##################################

  @typedoc """
  Parameters for `pending_incoming_requests/3`.

  > | name | description |
  > | - | - |
  > |cursor | Causes the list of connections to be broken into pages of no more than 5000 IDs at a time. The number of IDs returned is not guaranteed to be 5000 as suspended users are filtered out after connections are queried. If no cursor is provided, a value of -1 will be assumed, which is the first \"page.\"The response from the API will include a previous_cursor and next_cursor to allow paging back and forth. |
  > |stringify_ids | Many programming environments will not consume our Tweet ids due to their size. Provide this option to have ids returned as strings instead. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/follow-search-get-users/api-reference/get-friendships-incoming) for details.

  """
  @type pending_incoming_requests_params :: %{optional(:cursor) => integer, optional(:stringify_ids) => boolean}
  @spec pending_incoming_requests(Client.t(), pending_incoming_requests_params) ::
          {:ok, Tw.V1_1.CursoredResult.t(:ids, list(integer))} | {:error, Client.error()}
  @doc """
  Request `GET /friendships/incoming.json` and return decoded result.
  > Returns a collection of numeric IDs for every user who has a pending request to follow the authenticating user.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/follow-search-get-users/api-reference/get-friendships-incoming) for details.

  """
  def pending_incoming_requests(client, params) do
    Client.request(client, :get, "/friendships/incoming.json", params)
  end

  ##################################
  # GET /friendships/outgoing.json
  ##################################

  @typedoc """
  Parameters for `pending_outgoing_requests/3`.

  > | name | description |
  > | - | - |
  > |cursor | Causes the list of connections to be broken into pages of no more than 5000 IDs at a time. The number of IDs returned is not guaranteed to be 5000 as suspended users are filtered out after connections are queried. If no cursor is provided, a value of -1 will be assumed, which is the first \"page.\"The response from the API will include a previous_cursor and next_cursor to allow paging back and forth. See Using cursors to navigate collections for more information. |
  > |stringify_ids | Some programming environments will not consume Twitter IDs due to their size. Provide this option to have IDs returned as strings instead. More about Twitter IDs. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/follow-search-get-users/api-reference/get-friendships-outgoing) for details.

  """
  @type pending_outgoing_requests_params :: %{optional(:cursor) => integer, optional(:stringify_ids) => boolean}
  @spec pending_outgoing_requests(Client.t(), pending_outgoing_requests_params) ::
          {:ok, CursoredResult.t(:ids, list(integer))} | {:error, Client.error()}
  @doc """
  Request `GET /friendships/outgoing.json` and return decoded result.
  > Returns a collection of numeric IDs for every protected user for whom the authenticating user has a pending follow request.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/follow-search-get-users/api-reference/get-friendships-outgoing) for details.

  """
  def pending_outgoing_requests(client, params) do
    Client.request(client, :get, "/friendships/outgoing.json", params)
  end

  ##################################
  # GET /friendships/no_retweets/ids.json
  ##################################

  @typedoc """
  Parameters for `no_retweet_ids/3`.

  > | name | description |
  > | - | - |
  > |stringify_ids | Some programming environments will not consume Twitter IDs due to their size. Provide this option to have IDs returned as strings instead. Read more about Twitter IDs. This parameter is important to use in Javascript environments. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/follow-search-get-users/api-reference/get-friendships-no_retweets-ids) for details.

  """
  @type no_retweet_ids_params :: %{optional(:stringify_ids) => boolean}
  @spec no_retweet_ids(Client.t(), no_retweet_ids_params) :: {:ok, list(integer)} | {:error, Client.error()}
  @doc """
  Request `GET /friendships/no_retweets/ids.json` and return decoded result.
  > Returns a collection of user_ids that the currently authenticated user does not want to receive retweets from.
  >
  > Use POST friendships / update to set the \"no retweets\" status for a given user account on behalf of the current user.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/follow-search-get-users/api-reference/get-friendships-no_retweets-ids) for details.

  """
  def no_retweet_ids(client, params) do
    Client.request(client, :get, "/friendships/no_retweets/ids.json", params)
  end

  ##################################
  # GET /friendships/lookup.json
  ##################################

  @typedoc """
  Parameters for `list/3`.

  > | name | description |
  > | - | - |
  > |screen_name | A comma separated list of screen names, up to 100 are allowed in a single request. |
  > |user_id | A comma separated list of user IDs, up to 100 are allowed in a single request. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/follow-search-get-users/api-reference/get-friendships-lookup) for details.

  """
  @type list_params :: %{optional(:screen_name) => list(binary), optional(:user_id) => list(integer)}
  @spec list(Client.t(), list_params) :: {:ok, list(FriendshipLookupResult.t())} | {:error, Client.error()}
  @doc """
  Request `GET /friendships/lookup.json` and return decoded result.
  > Returns the relationships of the authenticating user to the comma-separated list of up to 100 screen_names or user_ids provided. Values for connections can be: following, following_requested, followed_by, none, blocking, muting.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/follow-search-get-users/api-reference/get-friendships-lookup) for details.

  """
  def list(client, params) do
    with {:ok, json} <- Client.request(client, :get, "/friendships/lookup.json", params) do
      res = json |> Enum.map(fn e -> e |> FriendshipLookupResult.decode!() end)
      {:ok, res}
    end
  end

  ##################################
  # GET /friendships/show.json
  ##################################

  @typedoc """
  Parameters for `find/3`.

  > | name | description |
  > | - | - |
  > |source_id | The user_id of the subject user. |
  > |source_screen_name | The screen_name of the subject user. |
  > |target_id | The user_id of the target user. |
  > |target_screen_name | The screen_name of the target user. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/follow-search-get-users/api-reference/get-friendships-show) for details.

  """
  @type find_params :: %{
          optional(:source_id) => integer,
          optional(:source_screen_name) => binary,
          optional(:target_id) => integer,
          optional(:target_screen_name) => binary
        }
  @spec find(Client.t(), find_params) ::
          {:ok, %{relationship: %{source: FriendshipSource.t(), target: FriendshipTarget.t()}}}
          | {:error, Client.error()}
  @doc """
  Request `GET /friendships/show.json` and return decoded result.
  > Returns detailed information about the relationship between two arbitrary users.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/follow-search-get-users/api-reference/get-friendships-show) for details.

  """
  def find(client, params) do
    with {:ok, json} <- Client.request(client, :get, "/friendships/show.json", params) do
      res = json |> Map.update!(:relationship, &decode!/1)
      {:ok, res}
    end
  end

  ##################################
  # POST /friendships/create.json
  ##################################

  @typedoc """
  Parameters for `create/3`.

  > | name | description |
  > | - | - |
  > |screen_name | The screen name of the user to follow. |
  > |user_id | The ID of the user to follow. |
  > |follow | Enable notifications for the target user. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/follow-search-get-users/api-reference/post-friendships-create) for details.

  """
  @type create_params :: %{
          optional(:screen_name) => binary,
          optional(:user_id) => integer,
          optional(:follow) => boolean
        }
  @spec create(Client.t(), create_params) :: {:ok, User.t()} | {:error, Client.error()}
  @doc """
  Request `POST /friendships/create.json` and return decoded result.
  > Allows the authenticating user to follow (friend) the user specified in the ID parameter.
  >
  > Returns the followed user when successful. Returns a string describing the failure condition when unsuccessful. If the user is already friends with the user a HTTP 403 may be returned, though for performance reasons this method may also return a HTTP 200 OK message even if the follow relationship already exists.
  >
  > Actions taken in this method are asynchronous. Changes will be eventually consistent.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/follow-search-get-users/api-reference/post-friendships-create) for details.

  """
  def create(client, params) do
    with {:ok, json} <- Client.request(client, :post, "/friendships/create.json", params) do
      res = json |> User.decode!()
      {:ok, res}
    end
  end

  ##################################
  # POST /friendships/destroy.json
  ##################################

  @typedoc """
  Parameters for `destroy/3`.

  > | name | description |
  > | - | - |
  > |screen_name | The screen name of the user to unfollow. |
  > |user_id | The ID of the user to unfollow. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/follow-search-get-users/api-reference/post-friendships-destroy) for details.

  """
  @type destroy_params :: %{optional(:screen_name) => binary, optional(:user_id) => integer}
  @spec destroy(Client.t(), destroy_params) :: {:ok, User.t()} | {:error, Client.error()}
  @doc """
  Request `POST /friendships/destroy.json` and return decoded result.
  > Allows the authenticating user to unfollow the user specified in the ID parameter.
  >
  > Returns the unfollowed user when successful. Returns a string describing the failure condition when unsuccessful.
  >
  > Actions taken in this method are asynchronous. Changes will be eventually consistent.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/follow-search-get-users/api-reference/post-friendships-destroy) for details.

  """
  def destroy(client, params) do
    with {:ok, json} <- Client.request(client, :post, "/friendships/destroy.json", params) do
      res = json |> User.decode!()
      {:ok, res}
    end
  end

  ##################################
  # POST /friendships/update.json
  ##################################

  @typedoc """
  Parameters for `update/3`.

  > | name | description |
  > | - | - |
  > |screen_name | The screen name of the user being followed. |
  > |user_id | The ID of the user being followed. |
  > |device | Turn on/off device notifications from the target user. |
  > |retweets | Turn on/off Retweets from the target user. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/follow-search-get-users/api-reference/post-friendships-update) for details.

  """
  @type update_params :: %{
          optional(:screen_name) => binary,
          optional(:user_id) => integer,
          optional(:device) => boolean,
          optional(:retweets) => boolean
        }
  @spec update(Client.t(), update_params) ::
          {:ok, %{relationship: %{source: FriendshipSource.t(), target: FriendshipTarget.t()}}}
          | {:error, Client.error()}
  @doc """
  Request `POST /friendships/update.json` and return decoded result.
  > Turn on/off Retweets and device notifications from the specified user.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/follow-search-get-users/api-reference/post-friendships-update) for details.

  """
  def update(client, params) do
    with {:ok, json} <- Client.request(client, :post, "/friendships/update.json", params) do
      res = json |> Map.update!(:relationship, &decode!/1)
      {:ok, res}
    end
  end
end
