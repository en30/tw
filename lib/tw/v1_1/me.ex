defmodule Tw.V1_1.Me do
  @moduledoc """
  Extended `Tw.V1_1.User` returned by `GET account/verify_credentials`.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/manage-account-settings/api-reference/get-account-verify_credentials) for details.
  """

  alias Tw.V1_1.Client
  alias Tw.V1_1.Schema
  alias Tw.V1_1.TrendLocation
  alias Tw.V1_1.Tweet
  alias Tw.V1_1.TwitterDateTime
  alias Tw.V1_1.UserEntities

  @enforce_keys [
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
    :entities,
    :show_all_inline_media,
    :status
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
    :entities,
    :show_all_inline_media,
    :status,
    :email
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
  > | `show_all_inline_media` |  -  |
  > | `status` |  -  |
  > | `email` |  -  |
  >
  """
  @type t :: %__MODULE__{
          id: integer,
          id_str: binary,
          name: binary,
          screen_name: binary,
          location: binary | nil,
          derived: list(map),
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
          profile_banner_url: binary,
          profile_image_url_https: binary,
          default_profile: boolean,
          default_profile_image: boolean,
          withheld_in_countries: list(binary),
          withheld_scope: binary,
          entities: UserEntities.t() | nil,
          show_all_inline_media: boolean,
          status: Tweet.t() | nil,
          email: binary | nil
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
      |> Map.update(:status, nil, Schema.nilable(&Tweet.decode!/1))

    struct(__MODULE__, json)
  end

  ##################################
  # GET /account/verify_credentials.json
  ##################################

  @typedoc """
  Parameters for `get/2`.

  > | name | description |
  > | - | - |
  > |include_entities | The entities node will not be included when set to false . |
  > |skip_status | When set to either true , t or 1 statuses will not be included in the returned user object. |
  > |include_email | When set to true email will be returned in the user objects as a string. If the user does not have an email address on their account, or if the email address is not verified, null will be returned. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/manage-account-settings/api-reference/get-account-verify_credentials) for details.

  """
  @type get_params :: %{
          optional(:include_entities) => boolean,
          optional(:skip_status) => boolean,
          optional(:include_email) => boolean
        }
  @spec get(Client.t(), get_params) :: {:ok, t()} | {:error, Client.error()}
  @doc """
  Request `GET /account/verify_credentials.json` and return decoded result.
  > Returns an HTTP 200 OK response code and a representation of the requesting user if authentication was successful; returns a 401 status code and an error message if not. Use this method to test if supplied user credentials are valid.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/manage-account-settings/api-reference/get-account-verify_credentials) for details.

  """
  def get(client, params \\ %{}) do
    with {:ok, json} <- Client.request(client, :get, "/account/verify_credentials.json", params) do
      res = json |> decode!()
      {:ok, res}
    end
  end

  @type setting :: %{
          allow_contributor_request: binary(),
          allow_dm_groups_from: binary(),
          allow_dms_from: binary(),
          always_use_https: boolean(),
          discoverable_by_email: boolean(),
          discoverable_by_mobile_phone: boolean(),
          display_sensitive_media: boolean(),
          geo_enabled: boolean(),
          language: binary(),
          protected: boolean(),
          screen_name: binary(),
          sleep_time: %{enabled: boolean(), end_time: non_neg_integer() | nil, start_time: non_neg_integer() | nil},
          time_zone: %{name: binary(), tzinfo_name: binary(), utc_offset: integer()},
          translator_type: binary(),
          trend_location: nil | list(TrendLocation.t()),
          use_cookie_personalization: boolean()
        }

  ##################################
  # GET /account/settings.json
  ##################################

  @spec get_setting(Client.t()) ::
          {:ok, setting()}
          | {:error, Client.error()}
  @doc """
  Request `GET /account/settings.json` and return decoded result.
  > Returns settings (including current trend, geo and sleep time information) for the authenticating user.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/manage-account-settings/api-reference/get-account-settings) for details.

  """
  def get_setting(client) do
    with {:ok, json} <- Client.request(client, :get, "/account/settings.json") do
      res = json |> decode_setting!()
      {:ok, res}
    end
  end

  ##################################
  # POST /account/settings.json
  ##################################

  @typedoc """
  Parameters for `update_setting/3`.

  > | name | description |
  > | - | - |
  > |sleep_time_enabled | When set to true , t or 1 , will enable sleep time for the user. Sleep time is the time when push or SMS notifications should not be sent to the user. |
  > |start_sleep_time | The hour that sleep time should begin if it is enabled. The value for this parameter should be provided in ISO 8601 format (i.e. 00-23). The time is considered to be in the same timezone as the user's time_zone setting. |
  > |end_sleep_time | The hour that sleep time should end if it is enabled. The value for this parameter should be provided in ISO 8601 format (i.e. 00-23). The time is considered to be in the same timezone as the user's time_zone setting. |
  > |time_zone | The timezone dates and times should be displayed in for the user. The timezone must be one of the Rails TimeZone names. |
  > |trend_location_woeid | The Yahoo! Where On Earth ID to use as the user's default trend location. Global information is available by using 1 as the WOEID. The WOEID must be one of the locations returned by GET trends/available . |
  > |lang | The language which Twitter should render in for this user. The language must be specified by the appropriate two letter ISO 639-1 representation. Currently supported languages are provided by this endpoint . |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/manage-account-settings/api-reference/post-account-settings) for details.

  """
  @type update_setting_params :: %{
          optional(:sleep_time_enabled) => boolean(),
          optional(:start_sleep_time) => integer(),
          optional(:end_sleep_time) => integer(),
          optional(:time_zone) => binary(),
          optional(:trend_location_woeid) => integer(),
          optional(:lang) => binary()
        }
  @spec update_setting(Client.t(), update_setting_params) ::
          {:ok, setting()}
          | {:error, Client.error()}
  @doc """
  Request `POST /account/settings.json` and return decoded result.
  > Updates the authenticating user's settings.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/manage-account-settings/api-reference/post-account-settings) for details.

  """
  def update_setting(client, params) do
    with {:ok, json} <- Client.request(client, :post, "/account/settings.json", params) do
      res = json |> decode_setting!()
      {:ok, res}
    end
  end

  defp decode_setting!(json) do
    json |> Map.update(:trend_location, nil, fn v -> v |> Enum.map(&TrendLocation.decode!/1) end)
  end

  ##################################
  # POST /account/update_profile_banner.json
  ##################################

  @typedoc """
  Parameters for `update_profile_banner/3`.

  > | name | description |
  > | - | - |
  > |banner | The Base64-encoded or raw image data being uploaded as the user's new profile banner. |
  > |width | The width of the preferred section of the image being uploaded in pixels. Use with height , offset_left , and offset_top to select the desired region of the image to use. |
  > |height | The height of the preferred section of the image being uploaded in pixels. Use with width , offset_left , and offset_top to select the desired region of the image to use. |
  > |offset_left | The number of pixels by which to offset the uploaded image from the left. Use with height , width , and offset_top to select the desired region of the image to use. |
  > |offset_top | The number of pixels by which to offset the uploaded image from the top. Use with height , width , and offset_left to select the desired region of the image to use. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/manage-account-settings/api-reference/post-account-update_profile_banner) for details.

  """
  @type update_profile_banner_params :: %{
          required(:banner) => binary(),
          optional(:width) => binary(),
          optional(:height) => binary(),
          optional(:offset_left) => binary(),
          optional(:offset_top) => binary()
        }
  @spec update_profile_banner(Client.t(), update_profile_banner_params) :: {:ok, binary()} | {:error, Client.error()}
  @doc """
  Request `POST /account/update_profile_banner.json` and return decoded result.
  > Uploads a profile banner on behalf of the authenticating user. More information about sizing variations can be found in User Profile Images and Banners and GET users / profile_banner.
  >
  > Profile banner images are processed asynchronously. The profile_banner_url and its variant sizes will not necessary be available directly after upload.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/manage-account-settings/api-reference/post-account-update_profile_banner) for details.

  ## Examples
      iex> banner = File.read!("/tmp/new_banner.png") |> Base.encode64()
      iex> Tw.V1_1.Me.update_profile_banner(client, %{banner: banner})
      {:ok, ""}

  """
  def update_profile_banner(client, params) do
    Client.request(client, :post, "/account/update_profile_banner.json", params)
  end

  ##################################
  # POST /account/remove_profile_banner.json
  ##################################

  @spec delete_profile_banner(Client.t()) :: {:ok, binary()} | {:error, Client.error()}
  @doc """
  Request `POST /account/remove_profile_banner.json` and return decoded result.
  > Removes the uploaded profile banner for the authenticating user. Returns HTTP 200 upon success.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/manage-account-settings/api-reference/post-account-remove_profile_banner) for details.

  """
  def delete_profile_banner(client) do
    Client.request(client, :post, "/account/remove_profile_banner.json")
  end

  ##################################
  # POST /account/update_profile_image.json
  ##################################

  @typedoc """
  Parameters for `update_profile_image/3`.

  > | name | description |
  > | - | - |
  > |image | The avatar image for the profile, base64-encoded. Must be a valid GIF, JPG, or PNG image of less than 700 kilobytes in size. Images with width larger than 400 pixels will be scaled down. Animated GIFs will be converted to a static GIF of the first frame, removing the animation. |
  > |include_entities | The entities node will not be included when set to false . |
  > |skip_status | When set to either true , t or 1 statuses will not be included in the returned user objects. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/manage-account-settings/api-reference/post-account-update_profile_image) for details.

  """
  @type update_profile_image_params :: %{
          required(:image) => binary(),
          optional(:include_entities) => boolean(),
          optional(:skip_status) => binary()
        }
  @spec update_profile_image(Client.t(), update_profile_image_params) :: {:ok, t()} | {:error, Client.error()}
  @doc """
  Request `POST /account/update_profile_image.json` and return decoded result.
  > Updates the authenticating user's profile image. Note that this method expects raw multipart data, not a URL to an image.
  >
  > This method asynchronously processes the uploaded file before updating the user's profile image URL. You can either update your local cache the next time you request the user's information, or, at least 5 seconds after uploading the image, ask for the updated URL using GET users / show.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/manage-account-settings/api-reference/post-account-update_profile_image) for details.

  ## Examples
      iex> image = File.read!("/tmp/new_profile_image.png") |> Base.encode64()
      iex> Tw.V1_1.Me.update_profile_image(client, %{image: image})
      {:ok, %Tw.V1_1.Me{}}

  """
  def update_profile_image(client, params) do
    with {:ok, json} <- Client.request(client, :post, "/account/update_profile_image.json", params) do
      res = json |> decode!()
      {:ok, res}
    end
  end
end
