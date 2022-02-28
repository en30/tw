defmodule Tw.V1_1.User do
  @moduledoc """
  User data structure and related functions.
  https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/user
  """

  import Tw.V1_1.Schema, only: :macros

  alias Tw.V1_1.Schema
  alias Tw.V1_1.UserEntities

  @type id :: pos_integer()

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
          entities: UserEntities.t()
        }
  @spec decode!(map) :: t
  @doc """
  Decode JSON-decoded map into `t:t/0`
  """
  def decode!(json) do
    json =
      json
      |> Map.update!(:created_at, &Schema.decode_twitter_datetime!/1)
      |> Map.update!(:entities, &UserEntities.decode!/1)

    struct(__MODULE__, json)
  end

  map_endpoint(:get, "/account/verify_credentials.json", to: me)
  map_endpoint(:get, "/users/show.json", to: find)
  map_endpoint(:get, "/users/lookup.json", to: list)
  map_endpoint(:get, "/users/search.json", to: search)
  map_endpoint(:get, "/followers/ids.json", to: follower_ids)
  map_endpoint(:get, "/friends/ids.json", to: friend_ids)
  map_endpoint(:get, "/followers/list.json", to: followers)
  map_endpoint(:get, "/friends/list.json", to: friends)
  map_endpoint(:get, "/blocks/ids.json", to: blocking_ids)
  map_endpoint(:get, "/blocks/list.json", to: blocking_users)
  map_endpoint(:get, "/mutes/users/ids.json", to: muting_ids)
  map_endpoint(:get, "/mutes/users/list.json", to: muting_users)
  map_endpoint(:get, "/statuses/retweeters/ids.json", to: retweeter_ids)
  map_endpoint(:get, "/lists/members.json", to: list_members)
  map_endpoint(:get, "/lists/subscribers.json", to: list_subscribers)
  map_endpoint(:post, "/blocks/create.json", to: block)
  map_endpoint(:post, "/blocks/destroy.json", to: unblock)
  map_endpoint(:post, "/mutes/users/create.json", to: mute)
  map_endpoint(:post, "/mutes/users/destroy.json", to: unmute)
  map_endpoint(:post, "/users/report_spam.json", to: report_spam)
  map_endpoint(:post, "/friendships/create.json", to: follow)
  map_endpoint(:post, "/friendships/destroy.json", to: unfollow)
end
