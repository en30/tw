defmodule Tw.V1_1.User do
  @moduledoc """
  User data structure and related functions.
  https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/user
  """

  alias Tw.V1_1.Client
  alias Tw.V1_1.CursoredResult
  alias Tw.V1_1.Me
  alias Tw.V1_1.TwitterDateTime
  alias Tw.V1_1.UserEntities

  import Tw.V1_1.Endpoint

  @type id :: pos_integer()
  @type screen_name :: binary()

  @enforce_keys [
    :id,
    :id_str,
    :name,
    :screen_name,
    :location,
    :url,
    :description,
    :protected,
    :verified,
    :followers_count,
    :friends_count,
    :listed_count,
    :favourites_count,
    :statuses_count,
    :created_at,
    :profile_image_url_https,
    :default_profile,
    :default_profile_image,
    :entities
  ]
  defstruct([
    :id,
    :id_str,
    :name,
    :screen_name,
    :location,
    :derived,
    :url,
    :description,
    :protected,
    :verified,
    :followers_count,
    :friends_count,
    :listed_count,
    :favourites_count,
    :statuses_count,
    :created_at,
    :profile_banner_url,
    :profile_image_url_https,
    :default_profile,
    :default_profile_image,
    :withheld_in_countries,
    :withheld_scope,
    :entities
  ])

  @typedoc """
  > | field | description |
  > | - | - |
  > | `id` | The integer representation of the unique identifier for this User. This number is greater than 53 bits and some programming languages may have difficulty/silent defects in interpreting it. Using a signed 64 bit integer for storing this identifier is safe. Use id_str to fetch the identifier to be safe. See Twitter IDs for more information. Example: `6253282 `.  |
  > | `id_str` | The string representation of the unique identifier for this User. Implementations should use this rather than the large, possibly un-consumable integer in id. Example: `\"6253282\" `.  |
  > | `name` | The name of the user, as they’ve defined it. Not necessarily a person’s name. Typically capped at 50 characters, but subject to change. Example: `\"Twitter API\" `.  |
  > | `screen_name` | The screen name, handle, or alias that this user identifies themselves with. screen_names are unique but subject to change. Use id_str as a user identifier whenever possible. Typically a maximum of 15 characters long, but some historical accounts may exist with longer names. Example: `\"twitterapi\" `.  |
  > | `location` | Nullable . The user-defined location for this account’s profile. Not necessarily a location, nor machine-parseable. This field will occasionally be fuzzily interpreted by the Search service. Example: `\"San Francisco, CA\" `.  |
  > | `derived` | Enterprise APIs only Collection of Enrichment metadata derived for user. Provides the Profile Geo Enrichment metadata. See referenced documentation for more information, including JSON data dictionaries. Example: `{\"locations\": [{\"country\":\"United States\",\"country_code\":\"US\",\"locality\":\"Denver\"}]} `.  |
  > | `url` | Nullable . A URL provided by the user in association with their profile. Example: `\"https://developer.twitter.com\" `.  |
  > | `description` | Nullable . The user-defined UTF-8 string describing their account. Example: `\"The Real Twitter API.\" `.  |
  > | `protected` | When true, indicates that this user has chosen to protect their Tweets. See About Public and Protected Tweets . Example: `true `.  |
  > | `verified` | When true, indicates that the user has a verified account. See Verified Accounts . Example: `false `.  |
  > | `followers_count` | The number of followers this account currently has. Under certain conditions of duress, this field will temporarily indicate “0”. Example: `21 `.  |
  > | `friends_count` | The number of users this account is following (AKA their “followings”). Under certain conditions of duress, this field will temporarily indicate “0”. Example: `32 `.  |
  > | `listed_count` | The number of public lists that this user is a member of. Example: `9274 `.  |
  > | `favourites_count` | The number of Tweets this user has liked in the account’s lifetime. British spelling used in the field name for historical reasons. Example: `13 `.  |
  > | `statuses_count` | The number of Tweets (including retweets) issued by the user. Example: `42 `.  |
  > | `created_at` | The UTC datetime that the user account was created on Twitter. Example: `\"Mon Nov 29 21:18:15 +0000 2010\" `.  |
  > | `profile_banner_url` | The HTTPS-based URL pointing to the standard web representation of the user’s uploaded profile banner. By adding a final path element of the URL, it is possible to obtain different image sizes optimized for specific displays. For size variants, please see User Profile Images and Banners .Example: `\"https://si0.twimg.com/profile_banners/819797/1348102824\" `.  |
  > | `profile_image_url_https` | A HTTPS-based URL pointing to the user’s profile image. Example: `\"https://abs.twimg.com/sticky/default_profile_images/default_profile_normal.png\" `.  |
  > | `default_profile` | When true, indicates that the user has not altered the theme or background of their user profile. Example: `false `.  |
  > | `default_profile_image` | When true, indicates that the user has not uploaded their own profile image and a default image is used instead. Example: `false `.  |
  > | `withheld_in_countries` | When present, indicates a list of uppercase two-letter country codes this content is withheld from. Twitter supports the following non-country values for this field:“XX” - Content is withheld in all countries “XY” - Content is withheld due to a DMCA request.Example: `[\"GR\", \"HK\", \"MY\"] `.  |
  > | `withheld_scope` | When present, indicates that the content being withheld is a “user.”Example: `\"user\" `.  |
  > | `entities` |  -  |
  >
  """
  @type t :: %__MODULE__{
          id: integer,
          id_str: binary,
          name: binary,
          screen_name: binary,
          location: binary | nil,
          derived: list(map) | nil,
          url: binary | nil,
          description: binary | nil,
          protected: boolean,
          verified: boolean,
          followers_count: integer,
          friends_count: integer,
          listed_count: integer,
          favourites_count: integer,
          statuses_count: integer,
          created_at: DateTime.t(),
          profile_banner_url: binary | nil,
          profile_image_url_https: binary,
          default_profile: boolean,
          default_profile_image: boolean,
          withheld_in_countries: list(binary) | nil,
          withheld_scope: binary | nil,
          entities: UserEntities.t() | nil
        }
  @spec decode!(map) :: t
  @doc """
  Decode JSON-decoded map into `t:t/0`
  """
  def decode!(json) do
    json =
      json
      |> Map.update!(:created_at, &TwitterDateTime.decode!/1)
      |> Map.update(:entities, nil, &UserEntities.decode!/1)

    struct(__MODULE__, json)
  end

  defdelegate me(client, params \\ %{}), to: Me, as: :get

  ##################################
  # GET /users/show.json
  ##################################

  @typedoc """
  Parameters for `find/3`.

  > | name | description |
  > | - | - |
  > |user_id | The ID of the user for whom to return results. Either an id or screen_name is required for this method. |
  > |screen_name | The screen name of the user for whom to return results. Either a id or screen_name is required for this method. |
  > |include_entities | The entities node will not be included when set to false. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/follow-search-get-users/api-reference/get-users-show) for details.

  """
  @type find_params :: %{
          required(:user_id) => integer,
          required(:screen_name) => binary,
          optional(:include_entities) => boolean
        }
  @spec find(Client.t(), find_params) :: {:ok, t()} | {:error, Client.error()}
  @doc """
  Request `GET /users/show.json` and return decoded result.
  > Returns a variety of information about the user specified by the required user_id or screen_name parameter. The author's most recent Tweet will be returned inline when possible.
  >
  > GET users / lookup is used to retrieve a bulk collection of user objects.
  >
  > You must be following a protected user to be able to see their most recent Tweet. If you don't follow a protected user, the user's Tweet will be removed. A Tweet will not always be returned in the current_status field.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/follow-search-get-users/api-reference/get-users-show) for details.

  """
  def find(client, params) do
    with {:ok, json} <- Client.request(client, :get, "/users/show.json", params) do
      res = json |> decode!()
      {:ok, res}
    end
  end

  ##################################
  # GET /users/lookup.json
  ##################################

  @typedoc """
  Parameters for `list/3`.

  > | name | description |
  > | - | - |
  > |screen_name | A comma separated list of screen names, up to 100 are allowed in a single request. You are strongly encouraged to use a POST for larger (up to 100 screen names) requests. |
  > |user_id | A comma separated list of user IDs, up to 100 are allowed in a single request. You are strongly encouraged to use a POST for larger requests. |
  > |include_entities | The entities node that may appear within embedded statuses will not be included when set to false. |
  > |tweet_mode | Valid request values are compat and extended, which give compatibility mode and extended mode, respectively for Tweets that contain over 140 characters |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/follow-search-get-users/api-reference/get-users-lookup) for details.

  """
  @type list_params :: %{
          optional(:screen_name) => list(binary),
          optional(:user_id) => list(integer),
          optional(:include_entities) => boolean,
          optional(:tweet_mode) => boolean
        }
  @spec list(Client.t(), list_params) :: {:ok, list(t())} | {:error, Client.error()}
  @doc """
  Request `GET /users/lookup.json` and return decoded result.
  > Returns fully-hydrated user objects for up to 100 users per request, as specified by comma-separated values passed to the user_id and/or screen_name parameters.
  >
  > This method is especially useful when used in conjunction with collections of user IDs returned from GET friends / ids and GET followers / ids.
  >
  > GET users / show is used to retrieve a single user object.
  >
  > There are a few things to note when using this method.
  >
  > You must be following a protected user to be able to see their most recent status update. If you don't follow a protected user their status will be removed.The order of user IDs or screen names may not match the order of users in the returned array.If a requested user is unknown, suspended, or deleted, then that user will not be returned in the results list.If none of your lookup criteria can be satisfied by returning a user object, a HTTP 404 will be thrown.You are strongly encouraged to use a POST for larger requests.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/follow-search-get-users/api-reference/get-users-lookup) for details.

  """
  def list(client, params) do
    with {:ok, json} <- Client.request(client, :get, "/users/lookup.json", params) do
      res = json |> Enum.map(&decode!/1)
      {:ok, res}
    end
  end

  ##################################
  # GET /users/search.json
  ##################################

  @typedoc """
  Parameters for `search/3`.

  > | name | description |
  > | - | - |
  > |q | The search query to run against people search. |
  > |page | Specifies the page of results to retrieve. |
  > |count | The number of potential user results to retrieve per page. This value has a maximum of 20. |
  > |include_entities | The entities node will not be included in embedded Tweet objects when set to false . |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/follow-search-get-users/api-reference/get-users-search) for details.

  """
  @type search_params :: %{
          required(:q) => binary,
          optional(:page) => integer,
          optional(:count) => integer,
          optional(:include_entities) => boolean
        }
  @spec search(Client.t(), search_params) :: {:ok, list(t())} | {:error, Client.error()}
  @doc """
  Request `GET /users/search.json` and return decoded result.
  > Provides a simple, relevance-based search interface to public user accounts on Twitter. Try querying by topical interest, full name, company name, location, or other criteria. Exact match searches are not supported.
  >
  > Only the first 1,000 matching results are available.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/follow-search-get-users/api-reference/get-users-search) for details.

  """
  def search(client, params) do
    with {:ok, json} <- Client.request(client, :get, "/users/search.json", params) do
      res = json |> Enum.map(&decode!/1)
      {:ok, res}
    end
  end

  ##################################
  # GET /followers/ids.json
  ##################################

  @typedoc """
  Parameters for `follower_ids/3`.

  > | name | description |
  > | - | - |
  > |user_id | The ID of the user for whom to return results. |
  > |screen_name | The screen name of the user for whom to return results. |
  > |cursor | Causes the list of connections to be broken into pages of no more than 5000 IDs at a time. The number of IDs returned is not guaranteed to be 5000 as suspended users are filtered out after connections are queried. If no cursor is provided, a value of -1 will be assumed, which is the first \"page.\"The response from the API will include a previous_cursor and next_cursor to allow paging back and forth. See Using cursors to navigate collections for more information. |
  > |stringify_ids | Some programming environments will not consume Twitter IDs due to their size. Provide this option to have IDs returned as strings instead. More about Twitter IDs. |
  > |count | Specifies the number of IDs attempt retrieval of, up to a maximum of 5,000 per distinct request. The value of count is best thought of as a limit to the number of results to return. When using the count parameter with this method, it is wise to use a consistent count value across all requests to the same user's collection. Usage of this parameter is encouraged in environments where all 5,000 IDs constitutes too large of a response. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/follow-search-get-users/api-reference/get-followers-ids) for details.

  """
  @type follower_ids_params :: %{
          optional(:user_id) => integer,
          optional(:screen_name) => binary,
          optional(:cursor) => integer,
          optional(:stringify_ids) => boolean,
          optional(:count) => integer
        }
  @spec follower_ids(Client.t(), follower_ids_params) ::
          {:ok, CursoredResult.t(:ids, list(integer))} | {:error, Client.error()}
  @doc """
  Request `GET /followers/ids.json` and return decoded result.
  > Returns a cursored collection of user IDs for every user following the specified user.
  >
  > At this time, results are ordered with the most recent following first — however, this ordering is subject to unannounced change and eventual consistency issues. Results are given in groups of 5,000 user IDs and multiple \"pages\" of results can be navigated through using the next_cursor value in subsequent requests. See Using cursors to navigate collections for more information.
  >
  > This method is especially powerful when used in conjunction with GET users / lookup, a method that allows you to convert user IDs into full user objects in bulk.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/follow-search-get-users/api-reference/get-followers-ids) for details.

  """
  def follower_ids(client, params) do
    Client.request(client, :get, "/followers/ids.json", params)
  end

  ##################################
  # GET /friends/ids.json
  ##################################

  @typedoc """
  Parameters for `friend_ids/3`.

  > | name | description |
  > | - | - |
  > |user_id | The ID of the user for whom to return results. |
  > |screen_name | The screen name of the user for whom to return results. |
  > |cursor | Causes the list of connections to be broken into pages of no more than 5000 IDs at a time. The number of IDs returned is not guaranteed to be 5000 as suspended users are filtered out after connections are queried. If no cursor is provided, a value of -1 will be assumed, which is the first \"page.\"The response from the API will include a previous_cursor and next_cursor to allow paging back and forth. See Using cursors to navigate collections for more information. |
  > |stringify_ids | Some programming environments will not consume Twitter IDs due to their size. Provide this option to have IDs returned as strings instead. More about Twitter IDs. |
  > |count | Specifies the number of IDs attempt retrieval of, up to a maximum of 5,000 per distinct request. The value of count is best thought of as a limit to the number of results to return. When using the count parameter with this method, it is wise to use a consistent count value across all requests to the same user's collection. Usage of this parameter is encouraged in environments where all 5,000 IDs constitutes too large of a response. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/follow-search-get-users/api-reference/get-friends-ids) for details.

  """
  @type friend_ids_params :: %{
          optional(:user_id) => integer,
          optional(:screen_name) => binary,
          optional(:cursor) => integer,
          optional(:stringify_ids) => boolean,
          optional(:count) => integer
        }
  @spec friend_ids(Client.t(), friend_ids_params) ::
          {:ok, CursoredResult.t(:ids, list(integer))} | {:error, Client.error()}
  @doc """
  Request `GET /friends/ids.json` and return decoded result.
  > Returns a cursored collection of user IDs for every user the specified user is following (otherwise known as their \"friends\").
  >
  > At this time, results are ordered with the most recent following first — however, this ordering is subject to unannounced change and eventual consistency issues. Results are given in groups of 5,000 user IDs and multiple \"pages\" of results can be navigated through using the next_cursor value in subsequent requests. See Using cursors to navigate collections for more information.
  >
  > This method is especially powerful when used in conjunction with GET users / lookup, a method that allows you to convert user IDs into full user objects in bulk.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/follow-search-get-users/api-reference/get-friends-ids) for details.

  """
  def friend_ids(client, params) do
    Client.request(client, :get, "/friends/ids.json", params)
  end

  ##################################
  # GET /followers/list.json
  ##################################

  @typedoc """
  Parameters for `followers/3`.

  > | name | description |
  > | - | - |
  > |user_id | The ID of the user for whom to return results. |
  > |screen_name | The screen name of the user for whom to return results. |
  > |cursor | Causes the results to be broken into pages. If no cursor is provided, a value of -1 will be assumed, which is the first \"page.\"The response from the API will include a previous_cursor and next_cursor to allow paging back and forth. See Using cursors to navigate collections for more information. |
  > |count | The number of users to return per page, up to a maximum of 200. Defaults to 20. |
  > |skip_status | When set to either true, t or 1, statuses will not be included in the returned user objects. If set to any other value, statuses will be included. |
  > |include_user_entities | The user object entities node will not be included when set to false. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/follow-search-get-users/api-reference/get-followers-list) for details.

  """
  @type followers_params :: %{
          optional(:user_id) => integer,
          optional(:screen_name) => binary,
          optional(:cursor) => integer,
          optional(:count) => integer,
          optional(:skip_status) => boolean,
          optional(:include_user_entities) => boolean
        }
  @spec followers(Client.t(), followers_params) ::
          {:ok, CursoredResult.t(:users, list(t()))} | {:error, Client.error()}
  @doc """
  Request `GET /followers/list.json` and return decoded result.
  > Returns a cursored collection of user objects for users following the specified user.
  >
  > At this time, results are ordered with the most recent following first — however, this ordering is subject to unannounced change and eventual consistency issues. Results are given in groups of 20 users and multiple \"pages\" of results can be navigated through using the next_cursor value in subsequent requests. See Using cursors to navigate collections for more information.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/follow-search-get-users/api-reference/get-followers-list) for details.

  """
  def followers(client, params) do
    with {:ok, json} <- Client.request(client, :get, "/followers/list.json", params) do
      res = json |> Map.update!(:users, fn v -> Enum.map(v, &decode!/1) end)
      {:ok, res}
    end
  end

  ##################################
  # GET /friends/list.json
  ##################################

  @typedoc """
  Parameters for `friends/3`.

  > | name | description |
  > | - | - |
  > |user_id | The ID of the user for whom to return results. |
  > |screen_name | The screen name of the user for whom to return results. |
  > |cursor | Causes the results to be broken into pages. If no cursor is provided, a value of -1 will be assumed, which is the first \"page.\"The response from the API will include a previous_cursor and next_cursor to allow paging back and forth. See Using cursors to navigate collections for more information. |
  > |count | The number of users to return per page, up to a maximum of 200. |
  > |skip_status | When set to either true, t or 1 statuses will not be included in the returned user objects. |
  > |include_user_entities | The user object entities node will not be included when set to false. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/follow-search-get-users/api-reference/get-friends-list) for details.

  """
  @type friends_params :: %{
          optional(:user_id) => integer,
          optional(:screen_name) => binary,
          optional(:cursor) => integer,
          optional(:count) => integer,
          optional(:skip_status) => boolean,
          optional(:include_user_entities) => boolean
        }
  @spec friends(Client.t(), friends_params) ::
          {:ok, CursoredResult.t(:users, list(t()))} | {:error, Client.error()}
  @doc """
  Request `GET /friends/list.json` and return decoded result.
  > Returns a cursored collection of user objects for every user the specified user is following (otherwise known as their \"friends\").
  >
  > At this time, results are ordered with the most recent following first — however, this ordering is subject to unannounced change and eventual consistency issues. Results are given in groups of 20 users and multiple \"pages\" of results can be navigated through using the next_cursor value in subsequent requests. See Using cursors to navigate collections for more information.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/follow-search-get-users/api-reference/get-friends-list) for details.

  """
  def friends(client, params) do
    with {:ok, json} <- Client.request(client, :get, "/friends/list.json", params) do
      res = json |> Map.update!(:users, fn v -> Enum.map(v, &decode!/1) end)
      {:ok, res}
    end
  end

  ##################################
  # GET /blocks/ids.json
  ##################################

  @typedoc """
  Parameters for `blocking_ids/3`.

  > | name | description |
  > | - | - |
  > |stringify_ids | Many programming environments will not consume Twitter IDs due to their size. Provide this option to have IDs returned as strings instead. Read more about Twitter IDs . |
  > |cursor | Causes the list of IDs to be broken into pages of no more than 5000 IDs at a time. The number of IDs returned is not guaranteed to be 5000 as suspended users are filtered out after connections are queried. If no cursor is provided, a value of -1 will be assumed, which is the first \"page.\"The response from the API will include a previous_cursor and next_cursor to allow paging back and forth. See Using cursors to navigate collections for more information. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/mute-block-report-users/api-reference/get-blocks-ids) for details.

  """
  @type blocking_ids_params :: %{optional(:stringify_ids) => boolean, optional(:cursor) => integer}
  @spec blocking_ids(Client.t(), blocking_ids_params) ::
          {:ok, CursoredResult.t(:ids, list(integer))} | {:error, Client.error()}
  @doc """
  Request `GET /blocks/ids.json` and return decoded result.
  > Returns an array of numeric user ids the authenticating user is blocking.
  >
  > Important This method is cursored, meaning your app must make multiple requests in order to receive all blocks correctly. See Using cursors to navigate collections for more details on how cursoring works.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/mute-block-report-users/api-reference/get-blocks-ids) for details.

  """
  def blocking_ids(client, params) do
    Client.request(client, :get, "/blocks/ids.json", params)
  end

  ##################################
  # GET /blocks/list.json
  ##################################

  @typedoc """
  Parameters for `blocking_users/3`.

  > | name | description |
  > | - | - |
  > |include_entities | The entities node will not be included when set to false . |
  > |skip_status | When set to either true , t or 1 statuses will not be included in the returned user objects. |
  > |cursor | Causes the list of blocked users to be broken into pages of no more than 5000 IDs at a time. The number of IDs returned is not guaranteed to be 5000 as suspended users are filtered out after connections are queried. If no cursor is provided, a value of -1 will be assumed, which is the first \"page.\"The response from the API will include a previous_cursor and next_cursor to allow paging back and forth. See Using cursors to navigate collections for more information. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/mute-block-report-users/api-reference/get-blocks-list) for details.

  """
  @type blocking_users_params :: %{
          optional(:include_entities) => boolean,
          optional(:skip_status) => boolean,
          optional(:cursor) => integer
        }
  @spec blocking_users(Client.t(), blocking_users_params) ::
          {:ok, CursoredResult.t(:users, list(t()))} | {:error, Client.error()}
  @doc """
  Request `GET /blocks/list.json` and return decoded result.
  > Returns a collection of user objects that the authenticating user is blocking.
  >
  > Important This method is cursored, meaning your app must make multiple requests in order to receive all blocks correctly. See Using cursors to navigate collections for more details on how cursoring works.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/mute-block-report-users/api-reference/get-blocks-list) for details.

  """
  def blocking_users(client, params) do
    with {:ok, json} <- Client.request(client, :get, "/blocks/list.json", params) do
      res = json |> Map.update!(:users, fn v -> Enum.map(v, &decode!/1) end)
      {:ok, res}
    end
  end

  ##################################
  # GET /mutes/users/ids.json
  ##################################

  @typedoc """
  Parameters for `muting_ids/3`.

  > | name | description |
  > | - | - |
  > |stringify_ids | Many programming environments will not consume Twitter IDs due to their size. Provide this option to have IDs returned as strings instead. Read more about Twitter IDs . |
  > |cursor | Causes the list of IDs to be broken into pages of no more than 5000 IDs at a time. The number of IDs returned is not guaranteed to be 5000 as suspended users are filtered out. If no cursor is provided, a value of -1 will be assumed, which is the first \"page.\"The response from the API will include a previous_cursor and next_cursor to allow paging back and forth. See Using cursors to navigate collections for more information. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/mute-block-report-users/api-reference/get-mutes-users-ids) for details.

  """
  @type muting_ids_params :: %{optional(:stringify_ids) => boolean, optional(:cursor) => integer}
  @spec muting_ids(Client.t(), muting_ids_params) ::
          {:ok, CursoredResult.t(:ids, list(integer))} | {:error, Client.error()}
  @doc """
  Request `GET /mutes/users/ids.json` and return decoded result.
  > Returns an array of numeric user ids the authenticating user has muted.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/mute-block-report-users/api-reference/get-mutes-users-ids) for details.

  """
  def muting_ids(client, params) do
    Client.request(client, :get, "/mutes/users/ids.json", params)
  end

  ##################################
  # GET /mutes/users/list.json
  ##################################

  @typedoc """
  Parameters for `muting_users/3`.

  > | name | description |
  > | - | - |
  > |cursor | Causes the list of IDs to be broken into pages of no more than 5000 IDs at a time. The number of IDs returned is not guaranteed to be 5000 as suspended users are filtered out. If no cursor is provided, a value of -1 will be assumed, which is the first \"page.\"The response from the API will include a previous_cursor and next_cursor to allow paging back and forth. See Using cursors to navigate collections for more information. |
  > |include_entities | The entities node will not be included when set to false . |
  > |skip_status | When set to either true , t or 1 statuses will not be included in the returned user objects. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/mute-block-report-users/api-reference/get-mutes-users-list) for details.

  """
  @type muting_users_params :: %{
          optional(:cursor) => integer,
          optional(:include_entities) => boolean,
          optional(:skip_status) => boolean
        }
  @spec muting_users(Client.t(), muting_users_params) ::
          {:ok, CursoredResult.t(:users, list(t()))} | {:error, Client.error()}
  @doc """
  Request `GET /mutes/users/list.json` and return decoded result.
  > Returns an array of user objects the authenticating user has muted.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/mute-block-report-users/api-reference/get-mutes-users-list) for details.

  """
  def muting_users(client, params) do
    with {:ok, json} <- Client.request(client, :get, "/mutes/users/list.json", params) do
      res = json |> Map.update!(:users, fn v -> Enum.map(v, &decode!/1) end)
      {:ok, res}
    end
  end

  ##################################
  # GET /statuses/retweeters/ids.json
  ##################################

  @typedoc """
  Parameters for `retweeter_ids/3`.

  > | name | description |
  > | - | - |
  > |id | The numerical ID of the desired status. |
  > |count | Specifies the number of records to retrieve. Must be less than or equal to 100. |
  > |cursor | Causes the list of IDs to be broken into pages of no more than 100 IDs at a time. The number of IDs returned is not guaranteed to be 100 as suspended users are filtered out after connections are queried. If no cursor is provided, a value of -1 will be assumed, which is the first \"page.\"The response from the API will include a previous_cursor and next_cursor to allow paging back and forth. See our cursor docs for more information.While this method supports the cursor parameter, the entire result set can be returned in a single cursored collection. Using the count parameter with this method will not provide segmented cursors for use with this parameter. |
  > |stringify_ids | Many programming environments will not consume Tweet ids due to their size. Provide this option to have ids returned as strings instead. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/tweets/post-and-engage/api-reference/get-statuses-retweeters-ids) for details.

  """
  @type retweeter_ids_params :: %{
          required(:id) => integer,
          optional(:count) => integer,
          optional(:cursor) => integer,
          optional(:stringify_ids) => boolean
        }
  @spec retweeter_ids(Client.t(), retweeter_ids_params) ::
          {:ok, CursoredResult.t(:ids, list(integer))} | {:error, Client.error()}
  @doc """
  Request `GET /statuses/retweeters/ids.json` and return decoded result.
  > Returns a collection of up to 100 user IDs belonging to users who have retweeted the Tweet specified by the id parameter.
  >
  > This method offers similar data to GET statuses / retweets / :id.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/tweets/post-and-engage/api-reference/get-statuses-retweeters-ids) for details.

  """
  def retweeter_ids(client, params) do
    Client.request(client, :get, "/statuses/retweeters/ids.json", params)
  end

  ##################################
  # GET /lists/members/show.json
  ##################################

  @typedoc """
  Parameters for `get_list_member/2`.

  > | name | description |
  > | - | - |
  > |list_id | The numerical id of the list. |
  > |slug | You can identify a list by its slug instead of its numerical id. If you decide to do so, note that you'll also have to specify the list owner using the owner_id or owner_screen_name parameters. |
  > |user_id | The ID of the user for whom to return results. Helpful for disambiguating when a valid user ID is also a valid screen name. |
  > |screen_name | The screen name of the user for whom to return results. Helpful for disambiguating when a valid screen name is also a user ID. |
  > |owner_screen_name | The screen name of the user who owns the list being requested by a slug. |
  > |owner_id | The user ID of the user who owns the list being requested by a slug. |
  > |include_entities | When set to either true, t or 1, each tweet will include a node called \"entities\". This node offers a variety of metadata about the tweet in a discreet structure, including: user_mentions, urls, and hashtags. While entities are opt-in on timelines at present, they will be made a default component of output in the future. See Tweet Entities for more details. |
  > |skip_status | When set to either true, t or 1 statuses will not be included in the returned user objects. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/create-manage-lists/api-reference/get-lists-members-show) for details.

  """

  deftype_cross_merge(get_list_member_params, list_params(), user_params(), %{
    optional(:include_entities) => binary(),
    optional(:skip_status) => boolean()
  })

  @spec get_list_member(Client.t(), get_list_member_params) :: {:ok, t() | nil} | {:error, Client.error()}
  @doc """
  Check if the specified user is a member of the specified list.

  Request `GET /lists/members/show.json` and return decoded result.

  - If the list is not found, return `{:error, error}` which satfisfies `Tw.V1_1.TwitterAPIError.resource_not_found?(error)`.
  - If the user is not member of the list, return `{:error, error}` which satfisfies `Tw.V1_1.TwitterAPIError.member_not_found?(error)`.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/create-manage-lists/api-reference/get-lists-members-show) for details.

  """
  def get_list_member(client, params) do
    params = params |> preprocess_list_params() |> preprocess_user_params()

    with {:ok, json} <- Client.request(client, :get, "/lists/members/show.json", params) do
      res = json |> decode!()
      {:ok, res}
    end
  end

  ##################################
  # GET /lists/subscribers/show.json
  ##################################

  @typedoc """
  Parameters for `get_list_subscriber/2`.

  > | name | description |
  > | - | - |
  > |owner_screen_name | The screen name of the user who owns the list being requested by a slug. |
  > |owner_id | The user ID of the user who owns the list being requested by a slug. |
  > |list_id | The numerical id of the list. |
  > |slug | You can identify a list by its slug instead of its numerical id. If you decide to do so, note that you'll also have to specify the list owner using the owner_id or owner_screen_name parameters. |
  > |user_id | The ID of the user for whom to return results. Helpful for disambiguating when a valid user ID is also a valid screen name. |
  > |screen_name | The screen name of the user for whom to return results. Helpful for disambiguating when a valid screen name is also a user ID. |
  > |include_entities | When set to either true, t or 1, each Tweet will include a node called \"entities\". This node offers a variety of metadata about the tweet in a discreet structure, including: user_mentions, urls, and hashtags. While entities are opt-in on timelines at present, they will be made a default component of output in the future. See Tweet Entities for more details. |
  > |skip_status | When set to either true , t or 1 statuses will not be included in the returned user objects. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/create-manage-lists/api-reference/get-lists-subscribers-show) for details.

  """
  deftype_cross_merge(get_list_subscriber_params, list_params(), user_params(), %{
    optional(:include_entities) => binary(),
    optional(:skip_status) => boolean()
  })

  @spec get_list_subscriber(Client.t(), get_list_subscriber_params) :: {:ok, t()} | {:error, Client.error()}
  @doc """
  Check if the specified user is a subscriber of the specified list. Returns the user if they are a subscriber.

  Request `GET /lists/subscribers/show.json` and return decoded result.

  - If the list is not found, return `{:error, error}` which satfisfies `Tw.V1_1.TwitterAPIError.resource_not_found?(error)`.
  - If the user is not subscriber of the list, return `{:error, error}` which satfisfies `Tw.V1_1.TwitterAPIError.subscriber_not_found?(error)`.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/create-manage-lists/api-reference/get-lists-subscribers-show) for details.

  """
  def get_list_subscriber(client, params) do
    params = params |> preprocess_list_params() |> preprocess_user_params()

    with {:ok, json} <- Client.request(client, :get, "/lists/subscribers/show.json", params) do
      res = json |> decode!()
      {:ok, res}
    end
  end

  ##################################
  # GET /lists/members.json
  ##################################

  @typedoc """
  Parameters for `list_members/3`.

  > | name | description |
  > | - | - |
  > |list_id | The numerical id of the list. |
  > |slug | You can identify a list by its slug instead of its numerical id. If you decide to do so, note that you'll also have to specify the list owner using the owner_id or owner_screen_name parameters. |
  > |owner_screen_name | The screen name of the user who owns the list being requested by a slug. |
  > |owner_id | The user ID of the user who owns the list being requested by a slug. |
  > |count | Specifies the number of results to return per page (see cursor below). The default is 20, with a maximum of 5,000. |
  > |cursor | Causes the collection of list members to be broken into \"pages\" of consistent sizes (specified by the count parameter). If no cursor is provided, a value of -1 will be assumed, which is the first \"page.\" |
  > |The response from the API will include a previous_cursor and next_cursor to allow paging back and forth. See Using cursors to navigate collections for more information. | 12893764510938 |
  > |include_entities | The entities node will not be included when set to false. |
  > |skip_status | When set to either true, t or 1 statuses will not be included in the returned user objects. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/create-manage-lists/api-reference/get-lists-members) for details.

  """
  @type list_members_params :: %{
          required(:list_id) => binary,
          required(:slug) => binary,
          optional(:owner_screen_name) => binary,
          optional(:owner_id) => binary,
          optional(:count) => integer,
          optional(:cursor) => binary,
          optional(
            :"The response from the API will include a previous_cursor and next_cursor to allow paging back and forth. See Using cursors to navigate collections for more information."
          ) => binary,
          optional(:include_entities) => boolean,
          optional(:skip_status) => boolean
        }
  @spec list_members(Client.t(), list_members_params) ::
          {:ok, CursoredResult.t(:users, list(t()))} | {:error, Client.error()}
  @doc """
  Request `GET /lists/members.json` and return decoded result.
  > members/*
  >
  > Returns the members of the specified list. Private list members will only be shown if the authenticated user owns the specified list.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/create-manage-lists/api-reference/get-lists-members) for details.

  """
  def list_members(client, params) do
    with {:ok, json} <- Client.request(client, :get, "/lists/members.json", params) do
      res = json |> Map.update!(:users, fn v -> Enum.map(v, &decode!/1) end)
      {:ok, res}
    end
  end

  ##################################
  # GET /lists/subscribers.json
  ##################################

  @typedoc """
  Parameters for `list_subscribers/3`.

  > | name | description |
  > | - | - |
  > |list_id | The numerical id of the list. |
  > |slug | You can identify a list by its slug instead of its numerical id. If you decide to do so, note that you'll also have to specify the list owner using the owner_id or owner_screen_name parameters. |
  > |owner_screen_name | The screen name of the user who owns the list being requested by a slug . |
  > |owner_id | The user ID of the user who owns the list being requested by a slug . |
  > |count | Specifies the number of results to return per page (see cursor below). The default is 20, with a maximum of 5,000. |
  > |cursor | Breaks the results into pages. A single page contains 20 lists. Provide a value of -1 to begin paging. Provide values as returned in the response body's next_cursor and previous_cursor attributes to page back and forth in the list. See Using cursors to navigate collections for more information. |
  > |include_entities | When set to either true , t or 1 , each tweet will include a node called \"entities\". This node offers a variety of metadata about the tweet in a discreet structure, including: user_mentions, urls, and hashtags. While entities are opt-in on timelines at present, they will be made a default component of output in the future. See Tweet Entities for more details. |
  > |skip_status | When set to either true , t or 1 statuses will not be included in the returned user objects. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/create-manage-lists/api-reference/get-lists-subscribers) for details.

  """
  @type list_subscribers_params :: %{
          required(:list_id) => binary,
          required(:slug) => binary,
          optional(:owner_screen_name) => binary,
          optional(:owner_id) => binary,
          optional(:count) => integer,
          optional(:cursor) => binary,
          optional(:include_entities) => binary,
          optional(:skip_status) => boolean
        }
  @spec list_subscribers(Client.t(), list_subscribers_params) ::
          {:ok, CursoredResult.t(:users, list(t()))} | {:error, Client.error()}
  @doc """
  Request `GET /lists/subscribers.json` and return decoded result.
  > subscribers/*
  >
  > Returns the subscribers of the specified list. Private list subscribers will only be shown if the authenticated user owns the specified list.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/create-manage-lists/api-reference/get-lists-subscribers) for details.

  """
  def list_subscribers(client, params) do
    with {:ok, json} <- Client.request(client, :get, "/lists/subscribers.json", params) do
      res = json |> Map.update!(:users, fn v -> Enum.map(v, &decode!/1) end)
      {:ok, res}
    end
  end

  ##################################
  # POST /blocks/create.json
  ##################################

  @typedoc """
  Parameters for `block/3`.

  > | name | description |
  > | - | - |
  > |screen_name | The screen name of the potentially blocked user. Helpful for disambiguating when a valid screen name is also a user ID. |
  > |user_id | The ID of the potentially blocked user. Helpful for disambiguating when a valid user ID is also a valid screen name. |
  > |include_entities | The entities node will not be included when set to false . |
  > |skip_status | When set to either true , t or 1 statuses will not be included in the returned user objects. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/mute-block-report-users/api-reference/post-blocks-create) for details.

  """
  @type block_params :: %{
          optional(:screen_name) => binary,
          optional(:user_id) => integer,
          optional(:include_entities) => boolean,
          optional(:skip_status) => boolean
        }
  @spec block(Client.t(), block_params) :: {:ok, t()} | {:error, Client.error()}
  @doc """
  Request `POST /blocks/create.json` and return decoded result.
  > Blocks the specified user from following the authenticating user. In addition the blocked user will not show in the authenticating users mentions or timeline (unless retweeted by another user). If a follow or friend relationship exists it is destroyed.
  >
  > The URL pattern /version/block/create/:screen_name_or_user_id.format is still accepted but not recommended. As a sequence of numbers is a valid screen name we recommend using the screen_name or user_id parameter instead.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/mute-block-report-users/api-reference/post-blocks-create) for details.

  """
  def block(client, params) do
    with {:ok, json} <- Client.request(client, :post, "/blocks/create.json", params) do
      res = json |> decode!()
      {:ok, res}
    end
  end

  ##################################
  # POST /blocks/destroy.json
  ##################################

  @typedoc """
  Parameters for `unblock/3`.

  > | name | description |
  > | - | - |
  > |screen_name | The screen name of the potentially blocked user. Helpful for disambiguating when a valid screen name is also a user ID. |
  > |user_id | The ID of the potentially blocked user. Helpful for disambiguating when a valid user ID is also a valid screen name. |
  > |include_entities | The entities node will not be included when set to false . |
  > |skip_status | When set to either true , t or 1 statuses will not be included in the returned user objects. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/mute-block-report-users/api-reference/post-blocks-destroy) for details.

  """
  @type unblock_params :: %{
          optional(:screen_name) => binary,
          optional(:user_id) => integer,
          optional(:include_entities) => boolean,
          optional(:skip_status) => boolean
        }
  @spec unblock(Client.t(), unblock_params) :: {:ok, t()} | {:error, Client.error()}
  @doc """
  Request `POST /blocks/destroy.json` and return decoded result.
  > Un-blocks the user specified in the ID parameter for the authenticating user. Returns the un-blocked user when successful. If relationships existed before the block was instantiated, they will not be restored.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/mute-block-report-users/api-reference/post-blocks-destroy) for details.

  """
  def unblock(client, params) do
    with {:ok, json} <- Client.request(client, :post, "/blocks/destroy.json", params) do
      res = json |> decode!()
      {:ok, res}
    end
  end

  ##################################
  # POST /mutes/users/create.json
  ##################################

  @typedoc """
  Parameters for `mute/3`.

  > | name | description |
  > | - | - |
  > |screen_name | The screen name of the potentially muted user. Helpful for disambiguating when a valid screen name is also a user ID. |
  > |user_id | The ID of the potentially muted user. Helpful for disambiguating when a valid user ID is also a valid screen name. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/mute-block-report-users/api-reference/post-mutes-users-create) for details.

  """
  @type mute_params :: %{optional(:screen_name) => binary, optional(:user_id) => integer}
  @spec mute(Client.t(), mute_params) :: {:ok, t()} | {:error, Client.error()}
  @doc """
  Request `POST /mutes/users/create.json` and return decoded result.
  > Mutes the user specified in the ID parameter for the authenticating user.
  >
  > Returns the muted user when successful. Returns a string describing the failure condition when unsuccessful.
  >
  > Actions taken in this method are asynchronous. Changes will be eventually consistent.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/mute-block-report-users/api-reference/post-mutes-users-create) for details.

  """
  def mute(client, params) do
    with {:ok, json} <- Client.request(client, :post, "/mutes/users/create.json", params) do
      res = json |> decode!()
      {:ok, res}
    end
  end

  ##################################
  # POST /mutes/users/destroy.json
  ##################################

  @typedoc """
  Parameters for `unmute/3`.

  > | name | description |
  > | - | - |
  > |screen_name | The screen name of the potentially muted user. Helpful for disambiguating when a valid screen name is also a user ID. |
  > |user_id | The ID of the potentially muted user. Helpful for disambiguating when a valid user ID is also a valid screen name. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/mute-block-report-users/api-reference/post-mutes-users-destroy) for details.

  """
  @type unmute_params :: %{optional(:screen_name) => binary, optional(:user_id) => integer}
  @spec unmute(Client.t(), unmute_params) :: {:ok, t()} | {:error, Client.error()}
  @doc """
  Request `POST /mutes/users/destroy.json` and return decoded result.
  > Un-mutes the user specified in the ID parameter for the authenticating user.
  >
  > Returns the unmuted user when successful. Returns a string describing the failure condition when unsuccessful.
  >
  > Actions taken in this method are asynchronous. Changes will be eventually consistent.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/mute-block-report-users/api-reference/post-mutes-users-destroy) for details.

  """
  def unmute(client, params) do
    with {:ok, json} <- Client.request(client, :post, "/mutes/users/destroy.json", params) do
      res = json |> decode!()
      {:ok, res}
    end
  end

  ##################################
  # POST /users/report_spam.json
  ##################################

  @typedoc """
  Parameters for `report_spam/3`.

  > | name | description |
  > | - | - |
  > |screen_name | The screen_name of the user to report as a spammer. Helpful for disambiguating when a valid screen name is also a user ID. |
  > |user_id | The ID of the user to report as a spammer. Helpful for disambiguating when a valid user ID is also a valid screen name. |
  > |perform_block | Whether the account should be blocked by the authenticated user, as well as being reported for spam. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/mute-block-report-users/api-reference/post-users-report_spam) for details.

  """
  @type report_spam_params :: %{
          optional(:screen_name) => binary,
          optional(:user_id) => integer,
          optional(:perform_block) => boolean
        }
  @spec report_spam(Client.t(), report_spam_params) :: {:ok, t()} | {:error, Client.error()}
  @doc """
  Request `POST /users/report_spam.json` and return decoded result.
  > Report the specified user as a spam account to Twitter. Additionally, optionally performs the equivalent of POST blocks / create on behalf of the authenticated user.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/mute-block-report-users/api-reference/post-users-report_spam) for details.

  """
  def report_spam(client, params) do
    with {:ok, json} <- Client.request(client, :post, "/users/report_spam.json", params) do
      res = json |> decode!()
      {:ok, res}
    end
  end

  ##################################
  # POST /friendships/create.json
  ##################################

  @typedoc """
  Parameters for `follow/3`.

  > | name | description |
  > | - | - |
  > |screen_name | The screen name of the user to follow. |
  > |user_id | The ID of the user to follow. |
  > |follow | Enable notifications for the target user. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/follow-search-get-users/api-reference/post-friendships-create) for details.

  """
  @type follow_params :: %{
          optional(:screen_name) => binary,
          optional(:user_id) => integer,
          optional(:follow) => boolean
        }
  @spec follow(Client.t(), follow_params) :: {:ok, t()} | {:error, Client.error()}
  @doc """
  Request `POST /friendships/create.json` and return decoded result.
  > Allows the authenticating user to follow (friend) the user specified in the ID parameter.
  >
  > Returns the followed user when successful. Returns a string describing the failure condition when unsuccessful. If the user is already friends with the user a HTTP 403 may be returned, though for performance reasons this method may also return a HTTP 200 OK message even if the follow relationship already exists.
  >
  > Actions taken in this method are asynchronous. Changes will be eventually consistent.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/follow-search-get-users/api-reference/post-friendships-create) for details.

  """
  def follow(client, params) do
    with {:ok, json} <- Client.request(client, :post, "/friendships/create.json", params) do
      res = json |> decode!()
      {:ok, res}
    end
  end

  ##################################
  # POST /friendships/destroy.json
  ##################################

  @typedoc """
  Parameters for `unfollow/3`.

  > | name | description |
  > | - | - |
  > |screen_name | The screen name of the user to unfollow. |
  > |user_id | The ID of the user to unfollow. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/follow-search-get-users/api-reference/post-friendships-destroy) for details.

  """
  @type unfollow_params :: %{optional(:screen_name) => binary, optional(:user_id) => integer}
  @spec unfollow(Client.t(), unfollow_params) :: {:ok, t()} | {:error, Client.error()}
  @doc """
  Request `POST /friendships/destroy.json` and return decoded result.
  > Allows the authenticating user to unfollow the user specified in the ID parameter.
  >
  > Returns the unfollowed user when successful. Returns a string describing the failure condition when unsuccessful.
  >
  > Actions taken in this method are asynchronous. Changes will be eventually consistent.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/follow-search-get-users/api-reference/post-friendships-destroy) for details.

  """
  def unfollow(client, params) do
    with {:ok, json} <- Client.request(client, :post, "/friendships/destroy.json", params) do
      res = json |> decode!()
      {:ok, res}
    end
  end

  ##################################
  # GET /users/profile_banner.json
  ##################################

  @type profile_banner_image :: %{w: non_neg_integer(), h: non_neg_integer(), url: binary()}
  @typedoc """
  Parameters for `get_profile_banner/3`.

  > | name | description |
  > | - | - |
  > |user_id | The ID of the user for whom to return results. Helpful for disambiguating when a valid user ID is also a valid screen name. |
  > |screen_name | The screen name of the user for whom to return results. Helpful for disambiguating when a valid screen name is also a user ID. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/manage-account-settings/api-reference/get-users-profile_banner) for details.

  """
  @type get_profile_banner_params :: %{optional(:user_id) => integer(), optional(:screen_name) => binary()}
  @spec get_profile_banner(Client.t(), get_profile_banner_params) ::
          {:ok,
           %{
             sizes: %{
               ipad: profile_banner_image(),
               ipad_retina: profile_banner_image(),
               web: profile_banner_image(),
               web_retina: profile_banner_image(),
               mobile: profile_banner_image(),
               mobile_retina: profile_banner_image(),
               "300x100": profile_banner_image(),
               "600x200": profile_banner_image(),
               "1500x500": profile_banner_image()
             }
           }}
          | {:error, Client.error()}
  @doc """
  Request `GET /users/profile_banner.json` and return decoded result.
  > Returns a map of the available size variations of the specified user's profile banner. If the user has not uploaded a profile banner, a HTTP 404 will be served instead. This method can be used instead of string manipulation on the profile_banner_url returned in user objects as described in Profile Images and Banners.
  >
  > The profile banner data available at each size variant's URL is in PNG format.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/manage-account-settings/api-reference/get-users-profile_banner) for details.

  """
  def get_profile_banner(client, params) do
    Client.request(client, :get, "/users/profile_banner.json", params)
  end
end
