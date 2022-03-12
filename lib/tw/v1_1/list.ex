defmodule Tw.V1_1.List do
  @moduledoc """
  Twitter's list data structure (unrelated to `List`) and related functions.

  > A list is a curated group of Twitter accounts. You can create your own lists or subscribe to lists created by others for the authenticated user. Viewing a list timeline will show you a stream of Tweets from only the accounts on that list.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/create-manage-lists/overview) for details.
  """

  alias Tw.V1_1.Client
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
end
