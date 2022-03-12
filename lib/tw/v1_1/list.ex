defmodule Tw.V1_1.List do
  @moduledoc """
  Twitter's list data structure (unrelated to `List`) and related functions.

  > A list is a curated group of Twitter accounts. You can create your own lists or subscribe to lists created by others for the authenticated user. Viewing a list timeline will show you a stream of Tweets from only the accounts on that list.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/create-manage-lists/overview) for details.
  """

  alias Tw.V1_1.Client
  alias Tw.V1_1.CursoredResult
  alias Tw.V1_1.TwitterDateTime
  alias Tw.V1_1.User

  @enforce_keys [
    :created_at,
    :description,
    :following,
    :full_name,
    :id_str,
    :id,
    :member_count,
    :mode,
    :name,
    :slug,
    :subscriber_count,
    :uri,
    :user
  ]

  defstruct([
    :created_at,
    :description,
    :following,
    :full_name,
    :id_str,
    :id,
    :member_count,
    :mode,
    :name,
    :slug,
    :subscriber_count,
    :uri,
    :user
  ])

  @type t :: %__MODULE__{
          created_at: DateTime.t(),
          description: binary(),
          following: boolean(),
          full_name: binary(),
          id: pos_integer(),
          id_str: binary(),
          member_count: non_neg_integer(),
          mode: binary(),
          name: binary(),
          slug: binary(),
          subscriber_count: non_neg_integer(),
          uri: binary(),
          user: User.t()
        }

  @spec decode!(map) :: t
  @doc """
  Decode JSON-decoded map into `t:t/0`
  """
  def decode!(json) do
    json =
      json
      |> Map.update!(:created_at, &TwitterDateTime.decode!/1)
      |> Map.update!(:user, &User.decode!/1)

    struct(__MODULE__, json)
  end

  ##################################
  # GET /lists/show.json
  ##################################

  @typedoc """
  Parameters for `get/3`.

  > | name | description |
  > | - | - |
  > |list_id | The numerical id of the list. |
  > |slug | You can identify a list by its slug instead of its numerical id. If you decide to do so, note that you'll also have to specify the list owner using the owner_id or owner_screen_name parameters. |
  > |owner_screen_name | The screen name of the user who owns the list being requested by a slug . |
  > |owner_id | The user ID of the user who owns the list being requested by a slug . |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/create-manage-lists/api-reference/get-lists-show) for details.

  """
  @type get_params ::
          %{list_id: binary()}
          | %{slug: binary(), owner_screen_name: User.screen_name()}
          | %{slug: binary(), owner_id: User.id()}
  @spec get(Client.t(), get_params) :: {:ok, t()} | {:error, Client.error()}
  @doc """
  Request `GET /lists/show.json` and return decoded result.
  > Returns the specified list. Private lists will only be shown if the authenticated user owns the specified list.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/create-manage-lists/api-reference/get-lists-show) for details.

  """
  def get(client, params) do
    with {:ok, json} <- Client.request(client, :get, "/lists/show.json", params) do
      res = json |> decode!()
      {:ok, res}
    end
  end

  ##################################
  # GET /lists/list.json
  ##################################

  @typedoc """
  Parameters for `list/3`.

  > | name | description |
  > | - | - |
  > |user_id | The ID of the user for whom to return results. Helpful for disambiguating when a valid user ID is also a valid screen name. Note: : Specifies the ID of the user to get lists from. Helpful for disambiguating when a valid user ID is also a valid screen name. |
  > |screen_name | The screen name of the user for whom to return results. Helpful for disambiguating when a valid screen name is also a user ID. |
  > |reverse | Set this to true if you would like owned lists to be returned first. See description above for information on how this parameter works. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/create-manage-lists/api-reference/get-lists-list) for details.

  """
  @type list_params ::
          %{optional(:reverse) => boolean()}
          | %{required(:user_id) => User.id(), optional(:reverse) => boolean()}
          | %{required(:screen_name) => User.screen_name(), optional(:reverse) => boolean()}
  @spec list(Client.t(), list_params) :: {:ok, list(t())} | {:error, Client.error()}
  @doc """
  Request `GET /lists/list.json` and return decoded result.
  > Returns all lists the authenticating or specified user subscribes to, including their own. The user is specified using the user_id or screen_name parameters. If no user is given, the authenticating user is used.
  >
  > A maximum of 100 results will be returned by this call. Subscribed lists are returned first, followed by owned lists. This means that if a user subscribes to 90 lists and owns 20 lists, this method returns 90 subscriptions and 10 owned lists. The reverse method returns owned lists first, so with reverse=true, 20 owned lists and 80 subscriptions would be returned. If your goal is to obtain every list a user owns or subscribes to, use GET lists / ownerships and/or GET lists / subscriptions instead.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/create-manage-lists/api-reference/get-lists-list) for details.

  """
  def list(client, params \\ %{}) do
    with {:ok, json} <- Client.request(client, :get, "/lists/list.json", params) do
      res = json |> Enum.map(&decode!/1)
      {:ok, res}
    end
  end

  ##################################
  # GET /lists/ownerships.json
  ##################################

  @typedoc """
  Parameters for `owned_by/3`.

  > | name | description |
  > | - | - |
  > |user_id | The ID of the user for whom to return results. Helpful for disambiguating when a valid user ID is also a valid screen name. |
  > |screen_name | The screen name of the user for whom to return results. Helpful for disambiguating when a valid screen name is also a user ID. |
  > |count | The amount of results to return per page. Defaults to 20. No more than 1000 results will ever be returned in a single page. |
  > |cursor | Breaks the results into pages. Provide a value of -1 to begin paging. Provide values as returned in the response body's next_cursor and previous_cursor attributes to page back and forth in the list. It is recommended to always use cursors when the method supports them. See Cursoring for more information. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/create-manage-lists/api-reference/get-lists-ownerships) for details.

  """
  @type owned_by_params :: %{
          optional(:user_id) => User.id(),
          optional(:screen_name) => User.screen_name(),
          optional(:count) => pos_integer(),
          optional(:cursor) => CursoredResult.cursor()
        }
  @spec owned_by(Client.t(), owned_by_params) :: {:ok, CursoredResult.t(:lists, list(t()))} | {:error, Client.error()}
  @doc """
  Request `GET /lists/ownerships.json` and return decoded result.
  > Returns the lists owned by the specified Twitter user. Private lists will only be shown if the authenticated user is also the owner of the lists.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/create-manage-lists/api-reference/get-lists-ownerships) for details.

  """
  def owned_by(client, params) do
    with {:ok, json} <- Client.request(client, :get, "/lists/ownerships.json", params) do
      res = json |> Map.update!(:lists, fn v -> v |> Enum.map(&decode!/1) end)
      {:ok, res}
    end
  end

  ##################################
  # GET /lists/subscriptions.json
  ##################################

  @typedoc """
  Parameters for `subscribed_by/3`.

  > | name | description |
  > | - | - |
  > |user_id | The ID of the user for whom to return results. Helpful for disambiguating when a valid user ID is also a valid screen name. |
  > |screen_name | The screen name of the user for whom to return results. Helpful for disambiguating when a valid screen name is also a user ID. |
  > |count | The amount of results to return per page. Defaults to 20. No more than 1000 results will ever be returned in a single page. |
  > |cursor | Breaks the results into pages. Provide a value of -1 to begin paging. Provide values as returned in the response body's next_cursor and previous_cursor attributes to page back and forth in the list. It is recommended to always use cursors when the method supports them. See Cursoring for more information. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/create-manage-lists/api-reference/get-lists-subscriptions) for details.

  """
  @type subscribed_by_params :: %{
          optional(:user_id) => User.id(),
          optional(:screen_name) => User.screen_name(),
          optional(:count) => pos_integer(),
          optional(:cursor) => CursoredResult.cursor()
        }
  @spec subscribed_by(Client.t(), subscribed_by_params) ::
          {:ok, CursoredResult.t(:lists, list(t()))} | {:error, Client.error()}
  @doc """
  Request `GET /lists/subscriptions.json` and return decoded result.
  > Obtain a collection of the lists the specified user is subscribed to, 20 lists per page by default. Does not include the user's own lists.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/create-manage-lists/api-reference/get-lists-subscriptions) for details.

  """
  def subscribed_by(client, params) do
    with {:ok, json} <- Client.request(client, :get, "/lists/subscriptions.json", params) do
      res = json |> Map.update!(:lists, fn v -> v |> Enum.map(&decode!/1) end)
      {:ok, res}
    end
  end

  ##################################
  # GET /lists/memberships.json
  ##################################

  @typedoc """
  Parameters for `containing/3`.

  > | name | description |
  > | - | - |
  > |user_id | The ID of the user for whom to return results. Helpful for disambiguating when a valid user ID is also a valid screen name. |
  > |screen_name | The screen name of the user for whom to return results. Helpful for disambiguating when a valid screen name is also a user ID. |
  > |count | The amount of results to return per page. Defaults to 20. No more than 1000 results will ever be returned in a single page. |
  > |cursor | Breaks the results into pages. Provide a value of -1 to begin paging. Provide values as returned in the response body's next_cursor and previous_cursor attributes to page back and forth in the list. It is recommended to always use cursors when the method supports them. See Cursoring for more information. |
  > |filter_to_owned_lists | When set to true , t or 1 , will return just lists the authenticating user owns, and the user represented by user_id or screen_name is a member of. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/create-manage-lists/api-reference/get-lists-memberships) for details.

  """
  @type containing_params :: %{
          optional(:user_id) => User.id(),
          optional(:screen_name) => User.screen_name(),
          optional(:count) => pos_integer(),
          optional(:cursor) => CursoredResult.cursor(),
          optional(:filter_to_owned_lists) => boolean()
        }
  @spec containing(Client.t(), containing_params) ::
          {:ok, CursoredResult.t(:lists, list(t()))} | {:error, Client.error()}
  @doc """
  Request `GET /lists/memberships.json` and return decoded result.
  > Returns the lists the specified user has been added to. If user_id or screen_name are not provided, the memberships for the authenticating user are returned.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/create-manage-lists/api-reference/get-lists-memberships) for details.

  """
  def containing(client, params) do
    with {:ok, json} <- Client.request(client, :get, "/lists/memberships.json", params) do
      res = json |> Map.update!(:lists, fn v -> v |> Enum.map(&decode!/1) end)
      {:ok, res}
    end
  end
end
