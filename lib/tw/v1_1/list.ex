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

  import Tw.V1_1.Endpoint

  @type mode :: :private | :public

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
          mode: mode(),
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
      |> Map.update!(:mode, &String.to_atom/1)

    struct(__MODULE__, json)
  end

  ##################################
  # GET /lists/show.json
  ##################################

  @typedoc """
  Parameters for `get/2`.

  > | name | description |
  > | - | - |
  > |list_id | The numerical id of the list. |
  > |slug | You can identify a list by its slug instead of its numerical id. If you decide to do so, note that you'll also have to specify the list owner using the owner_id or owner_screen_name parameters. |
  > |owner_screen_name | The screen name of the user who owns the list being requested by a slug . |
  > |owner_id | The user ID of the user who owns the list being requested by a slug . |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/create-manage-lists/api-reference/get-lists-show) for details.

  """
  @type get_params :: Tw.V1_1.Endpoint.list_params()
  @spec get(Client.t(), get_params) :: {:ok, t()} | {:error, Client.error()}
  @doc """
  Request `GET /lists/show.json` and return decoded result.
  > Returns the specified list. Private lists will only be shown if the authenticated user owns the specified list.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/create-manage-lists/api-reference/get-lists-show) for details.

  """
  def get(client, params) do
    params = params |> preprocess_list_params()

    with {:ok, json} <- Client.request(client, :get, "/lists/show.json", params) do
      res = json |> decode!()
      {:ok, res}
    end
  end

  ##################################
  # POST /lists/create.json
  ##################################

  @typedoc """
  Parameters for `create/2`.

  > | name | description |
  > | - | - |
  > |name | The name for the list. A list's name must start with a letter and can consist only of 25 or fewer letters, numbers, \"-\", or \"_\" characters. |
  > |mode | Whether your list is public or private. Values can be public or private . If no mode is specified the list will be public. |
  > |description | The description to give the list. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/create-manage-lists/api-reference/post-lists-create) for details.

  """
  @type create_params :: %{
          required(:name) => binary(),
          optional(:mode) => mode(),
          optional(:description) => binary()
        }

  @spec create(Client.t(), create_params) :: {:ok, t()} | {:error, Client.error()}
  @doc """
  Request `POST /lists/create.json` and return decoded result.
  > Creates a new list for the authenticated user. Note that you can create up to 1000 lists per account.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/create-manage-lists/api-reference/post-lists-create) for details.

  """
  def create(client, params) do
    params = params |> Map.update(:mode, :public, &to_string/1)

    with {:ok, json} <- Client.request(client, :post, "/lists/create.json", params) do
      res = json |> decode!()
      {:ok, res}
    end
  end

  ##################################
  # POST /lists/update.json
  ##################################

  deftype_cross_merge(update_params, list_params(), %{
    optional(:name) => binary(),
    optional(:mode) => mode(),
    optional(:description) => binary()
  })

  @spec update(Client.t(), update_params()) :: {:ok, t()} | {:error, Client.error()}
  @doc """
  Request `POST /lists/update.json` and return decoded result.
  > Updates the specified list. The authenticated user must own the list to be able to update it.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/create-manage-lists/api-reference/post-lists-update) for details.

  ## Examples
      iex> {:ok, list} = Tw.V1_1.List.get(client, %{list_id: 574})
      iex> {:ok, list} = Tw.V1_1.List.update(client, %{list: list, name: "updated"})
      {:ok, %Tw.V1_1.List{name: "updated"}}

      iex> {:ok, list} = Tw.V1_1.List.update(client, %{list_id: 574}, %{name: "updated"})
      {:ok, %Tw.V1_1.List{name: "updated"}}
  """
  def update(client, params) do
    params = params |> preprocess_list_params() |> Map.update(:mode, :public, &to_string/1)

    with {:ok, json} <- Client.request(client, :post, "/lists/update.json", params) do
      res = json |> decode!()
      {:ok, res}
    end
  end

  ##################################
  # POST /lists/destroy.json
  ##################################

  @typedoc """
  Parameters for `delete/2`.

  > | name | description |
  > | - | - |
  > |owner_screen_name | The screen name of the user who owns the list being requested by a slug . |
  > |owner_id | The user ID of the user who owns the list being requested by a slug . |
  > |list_id | The numerical id of the list. |
  > |slug | You can identify a list by its slug instead of its numerical id. If you decide to do so, note that you'll also have to specify the list owner using the owner_id or owner_screen_name parameters. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/create-manage-lists/api-reference/post-lists-destroy) for details.

  """
  @type delete_params :: Tw.V1_1.Endpoint.list_params()
  @spec delete(Client.t(), delete_params) :: {:ok, t()} | {:error, Client.error()}
  @doc """
  Request `POST /lists/destroy.json` and return decoded result.
  > Deletes the specified list. The authenticated user must own the list to be able to destroy it.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/create-manage-lists/api-reference/post-lists-destroy) for details.

  ## Examples
      iex> {:ok, list} = Tw.V1_1.List.get(client, %{list_id: 574})
      iex> {:ok, list} = Tw.V1_1.List.delete(client, %{list: list})
      {:ok, %Tw.V1_1.List{}}

      iex> {:ok, list} = Tw.V1_1.List.delete(client, %{list_id: 574})
      {:ok, %Tw.V1_1.List{}}

  """
  def delete(client, params) do
    params = params |> preprocess_list_params()

    with {:ok, json} <- Client.request(client, :post, "/lists/destroy.json", params) do
      res = json |> decode!()
      {:ok, res}
    end
  end

  ##################################
  # POST /lists/members/create.json
  ##################################

  deftype_cross_merge(put_member_params, list_params(), user_params())

  @spec put_member(Client.t(), put_member_params) :: {:ok, t()} | {:error, Client.error()}
  @doc """
  Request `POST /lists/members/create.json` and return decoded result.
  > Add a member to a list. The authenticated user must own the list to be able to add members to it. Note that lists cannot have more than 5,000 members.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/create-manage-lists/api-reference/post-lists-members-create) for details.

  """
  def put_member(client, params) do
    params = params |> preprocess_list_params() |> preprocess_user_params()

    with {:ok, json} <- Client.request(client, :post, "/lists/members/create.json", params) do
      res = json |> decode!()
      {:ok, res}
    end
  end

  ##################################
  # POST /lists/members/create_all.json
  ##################################

  deftype_cross_merge(put_members_params, list_params(), user_list_params())

  @spec put_members(Client.t(), put_members_params) :: {:ok, t()} | {:error, Client.error()}
  @doc """
  Request `POST /lists/members/create_all.json` and return decoded result.
  > Adds multiple members to a list, by specifying a comma-separated list of member ids or screen names. The authenticated user must own the list to be able to add members to it. Note that lists can't have more than 5,000 members, and you are limited to adding up to 100 members to a list at a time with this method.
  >
  > Please note that there can be issues with lists that rapidly remove and add memberships. Take care when using these methods such that you are not too rapidly switching between removals and adds on the same list.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/create-manage-lists/api-reference/post-lists-members-create_all) for details.

  """
  def put_members(client, params) do
    params = params |> preprocess_list_params() |> preprocess_user_list_params()

    with {:ok, json} <- Client.request(client, :post, "/lists/members/create_all.json", params) do
      res = json |> decode!()
      {:ok, res}
    end
  end

  ##################################
  # POST /lists/members/destroy.json
  ##################################

  deftype_cross_merge(delete_member_params, list_params(), user_params())

  @spec delete_member(Client.t(), delete_member_params()) :: {:ok, t()} | {:error, Client.error()}
  @doc """
  Request `POST /lists/members/destroy.json` and return decoded result.
  > Removes the specified member from the list. The authenticated user must be the list's owner to remove members from the list.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/create-manage-lists/api-reference/post-lists-members-destroy) for details.

  """
  def delete_member(client, params) do
    params = params |> preprocess_list_params() |> preprocess_user_params()

    with {:ok, json} <- Client.request(client, :post, "/lists/members/destroy.json", params) do
      res = json |> decode!()
      {:ok, res}
    end
  end

  ##################################
  # POST /lists/members/destroy_all.json
  ##################################

  deftype_cross_merge(delete_members_params, list_params(), user_list_params())
  @spec delete_members(Client.t(), delete_members_params()) :: {:ok, t()} | {:error, Client.error()}
  @doc """
  Request `POST /lists/members/destroy_all.json` and return decoded result.
  > Removes multiple members from a list, by specifying a comma-separated list of member ids or screen names. The authenticated user must own the list to be able to remove members from it. Note that lists can't have more than 500 members, and you are limited to removing up to 100 members to a list at a time with this method.
  >
  > Please note that there can be issues with lists that rapidly remove and add memberships. Take care when using these methods such that you are not too rapidly switching between removals and adds on the same list.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/create-manage-lists/api-reference/post-lists-members-destroy_all) for details.

  """
  def delete_members(client, params) do
    params = params |> preprocess_list_params() |> preprocess_user_list_params()

    with {:ok, json} <- Client.request(client, :post, "/lists/members/destroy_all.json", params) do
      res = json |> decode!()
      {:ok, res}
    end
  end

  ##################################
  # GET /lists/list.json
  ##################################

  @typedoc """
  Parameters for `list/2`.

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
  deftype_cross_merge(owned_by_params, optional_user_params(), %{
    optional(:count) => pos_integer(),
    optional(:cursor) => CursoredResult.cursor()
  })

  @spec owned_by(Client.t(), owned_by_params) ::
          {:ok, CursoredResult.t(:lists, list(t()))} | {:error, Client.error()}
  @doc """
  Request `GET /lists/ownerships.json` and return decoded result.
  > Returns the lists owned by the specified Twitter user. Private lists will only be shown if the authenticated user is also the owner of the lists.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/create-manage-lists/api-reference/get-lists-ownerships) for details.

  """
  def owned_by(client, params \\ %{}) do
    params = params |> preprocess_optional_user_params()

    with {:ok, json} <- Client.request(client, :get, "/lists/ownerships.json", params) do
      res = json |> Map.update!(:lists, fn v -> v |> Enum.map(&decode!/1) end)
      {:ok, res}
    end
  end

  ##################################
  # GET /lists/subscriptions.json
  ##################################

  @typedoc """
  Parameters for `subscribed_by/2`.

  > | name | description |
  > | - | - |
  > |user_id | The ID of the user for whom to return results. Helpful for disambiguating when a valid user ID is also a valid screen name. |
  > |screen_name | The screen name of the user for whom to return results. Helpful for disambiguating when a valid screen name is also a user ID. |
  > |count | The amount of results to return per page. Defaults to 20. No more than 1000 results will ever be returned in a single page. |
  > |cursor | Breaks the results into pages. Provide a value of -1 to begin paging. Provide values as returned in the response body's next_cursor and previous_cursor attributes to page back and forth in the list. It is recommended to always use cursors when the method supports them. See Cursoring for more information. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/create-manage-lists/api-reference/get-lists-subscriptions) for details.

  """
  deftype_cross_merge(subscribed_by_params, optional_user_params(), %{
    optional(:count) => pos_integer(),
    optional(:cursor) => CursoredResult.cursor()
  })

  @spec subscribed_by(Client.t(), subscribed_by_params) ::
          {:ok, CursoredResult.t(:lists, list(t()))} | {:error, Client.error()}
  @doc """
  Request `GET /lists/subscriptions.json` and return decoded result.
  > Obtain a collection of the lists the specified user is subscribed to, 20 lists per page by default. Does not include the user's own lists.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/create-manage-lists/api-reference/get-lists-subscriptions) for details.

  """
  def subscribed_by(client, params \\ %{}) do
    params = params |> preprocess_optional_user_params()

    with {:ok, json} <- Client.request(client, :get, "/lists/subscriptions.json", params) do
      res = json |> Map.update!(:lists, fn v -> v |> Enum.map(&decode!/1) end)
      {:ok, res}
    end
  end

  ##################################
  # GET /lists/memberships.json
  ##################################

  @typedoc """
  Parameters for `containing/2`.

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
  deftype_cross_merge(containing_params, optional_user_params(), %{
    optional(:count) => pos_integer(),
    optional(:cursor) => CursoredResult.cursor(),
    optional(:filter_to_owned_lists) => boolean()
  })

  @spec containing(Client.t(), containing_params) ::
          {:ok, CursoredResult.t(:lists, list(t()))} | {:error, Client.error()}
  @doc """
  Request `GET /lists/memberships.json` and return decoded result.
  > Returns the lists the specified user has been added to. If user_id or screen_name are not provided, the memberships for the authenticating user are returned.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/create-manage-lists/api-reference/get-lists-memberships) for details.

  """
  def containing(client, params \\ %{}) do
    params = params |> preprocess_optional_user_params()

    with {:ok, json} <- Client.request(client, :get, "/lists/memberships.json", params) do
      res = json |> Map.update!(:lists, fn v -> v |> Enum.map(&decode!/1) end)
      {:ok, res}
    end
  end

  ##################################
  # POST /lists/subscribers/create.json
  ##################################

  @typedoc """
  Parameters for `subscribe/2`.

  > | name | description |
  > | - | - |
  > |owner_screen_name | The screen name of the user who owns the list being requested by a slug . |
  > |owner_id | The user ID of the user who owns the list being requested by a slug . |
  > |list_id | The numerical id of the list. |
  > |slug | You can identify a list by its slug instead of its numerical id. If you decide to do so, note that you'll also have to specify the list owner using the owner_id or owner_screen_name parameters. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/create-manage-lists/api-reference/post-lists-subscribers-create) for details.

  """
  @type subscribe_params :: Tw.V1_1.Endpoint.list_params()
  @spec subscribe(Client.t(), subscribe_params) :: {:ok, t()} | {:error, Client.error()}
  @doc """
  Request `POST /lists/subscribers/create.json` and return decoded result.
  > Subscribes the authenticated user to the specified list.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/create-manage-lists/api-reference/post-lists-subscribers-create) for details.

  ## Examples
      iex> {:ok, list} = Tw.V1_1.List.get(client, %{list_id: 574})
      iex> {:ok, list} = Tw.V1_1.List.subscribe(client, %{list: list})
      {:ok, %Tw.V1_1.List{}}

      iex> {:ok, list} = Tw.V1_1.List.subscribe(client, %{list_id: 574})
      {:ok, %Tw.V1_1.List{}}


  """

  def subscribe(client, params) do
    params = params |> preprocess_list_params()

    with {:ok, json} <- Client.request(client, :post, "/lists/subscribers/create.json", params) do
      res = json |> decode!()
      {:ok, res}
    end
  end

  ##################################
  # POST /lists/subscribers/destroy.json
  ##################################

  @typedoc """
  Parameters for `unsubscribe/2`.

  > | name | description |
  > | - | - |
  > |list_id | The numerical id of the list. |
  > |slug | You can identify a list by its slug instead of its numerical id. If you decide to do so, note that you'll also have to specify the list owner using the owner_id or owner_screen_name parameters. |
  > |owner_screen_name | The screen name of the user who owns the list being requested by a slug . |
  > |owner_id | The user ID of the user who owns the list being requested by a slug . |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/create-manage-lists/api-reference/post-lists-subscribers-destroy) for details.

  """
  @type unsubscribe_params :: Tw.V1_1.Endpoint.list_params()
  @spec unsubscribe(Client.t(), unsubscribe_params) :: {:ok, t()} | {:error, Client.error()}
  @doc """
  Request `POST /lists/subscribers/destroy.json` and return decoded result.
  > Unsubscribes the authenticated user from the specified list.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/create-manage-lists/api-reference/post-lists-subscribers-destroy) for details.

  ## Examples
      iex> {:ok, list} = Tw.V1_1.List.get(client, %{list_id: 574})
      iex> {:ok, list} = Tw.V1_1.List.unsubscribe(client, %{list: list})
      {:ok, %Tw.V1_1.List{}}

      iex> {:ok, list} = Tw.V1_1.List.unsubscribe(client, %{list_id: 574})
      {:ok, %Tw.V1_1.List{}}
  """

  def unsubscribe(client, params) do
    params = params |> preprocess_list_params()

    with {:ok, json} <- Client.request(client, :post, "/lists/subscribers/destroy.json", params) do
      res = json |> decode!()
      {:ok, res}
    end
  end

  defdelegate get_member(client, paramas), to: User, as: :list_member
  defdelegate get_subscriber(client, paramas), to: User, as: :list_subscriber
end
