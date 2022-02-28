defmodule Tw.V1_1.Tweet do
  @moduledoc """
  Tweet data structure and related functions.
  https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/tweet
  """

  import Tw.V1_1.Schema, only: :macros

  alias Tw.V1_1.Coordinates
  alias Tw.V1_1.Entities
  alias Tw.V1_1.ExtendedEntities
  alias Tw.V1_1.Place
  alias Tw.V1_1.Schema
  alias Tw.V1_1.User

  @enforce_keys [
    :created_at,
    :id,
    :id_str,
    :text,
    :source,
    :truncated,
    :in_reply_to_status_id,
    :in_reply_to_status_id_str,
    :in_reply_to_user_id,
    :in_reply_to_user_id_str,
    :in_reply_to_screen_name,
    :user,
    :coordinates,
    :place,
    :is_quote_status,
    :retweet_count,
    :favorite_count,
    :entities,
    :favorited,
    :retweeted,
    :possibly_sensitive,
    :lang
  ]
  defstruct([
    :created_at,
    :id,
    :id_str,
    :text,
    :source,
    :truncated,
    :in_reply_to_status_id,
    :in_reply_to_status_id_str,
    :in_reply_to_user_id,
    :in_reply_to_user_id_str,
    :in_reply_to_screen_name,
    :user,
    :coordinates,
    :place,
    :quoted_status_id,
    :quoted_status_id_str,
    :is_quote_status,
    :quoted_status,
    :retweeted_status,
    :quote_count,
    :reply_count,
    :retweet_count,
    :favorite_count,
    :entities,
    :extended_entities,
    :favorited,
    :retweeted,
    :possibly_sensitive,
    :filter_level,
    :lang,
    :matching_rules,
    :current_user_retweet,
    :scopes,
    :withheld_copyright,
    :withheld_in_countries,
    :withheld_scope,
    :contributors,
    :display_text_range,
    :full_text,
    :possibly_sensitive_appealable,
    :quoted_status_permalink
  ])

  @typedoc """
  > | field | description |
  > | - | - |
  > | `created_at` | UTC time when this Tweet was created. Example: `\"Wed Oct 10 20:19:24 +0000 2018\" `.  |
  > | `id` | The integer representation of the unique identifier for this Tweet. This number is greater than 53 bits and some programming languages may have difficulty/silent defects in interpreting it. Using a signed 64 bit integer for storing this identifier is safe. Use id_str to fetch the identifier to be safe. See Twitter IDs for more information. Example: `1050118621198921728 `.  |
  > | `id_str` | The string representation of the unique identifier for this Tweet. Implementations should use this rather than the large integer in id. Example: `\"1050118621198921728\" `.  |
  > | `text` | The actual UTF-8 text of the status update. See twitter-text for details on what characters are currently considered valid. Example: `\"To make room for more expression, we will now count all emojis as equal—including those with gender‍‍‍ ‍‍and skin t… https://t.co/MkGjXf9aXm\" `.  |
  > | `source` | Utility used to post the Tweet, as an HTML-formatted string. Tweets from the Twitter website have a source value of web.Example: `\"Twitter Web Client\" `.  |
  > | `truncated` | Indicates whether the value of the text parameter was truncated, for example, as a result of a retweet exceeding the original Tweet text length limit of 140 characters. Truncated text will end in ellipsis, like this ... Since Twitter now rejects long Tweets vs truncating them, the large majority of Tweets will have this set to false . Note that while native retweets may have their toplevel text property shortened, the original text will be available under the retweeted_status object and the truncated parameter will be set to the value of the original status (in most cases, false ). Example: `true `.  |
  > | `in_reply_to_status_id` | Nullable. If the represented Tweet is a reply, this field will contain the integer representation of the original Tweet’s ID. Example: `1051222721923756032 `.  |
  > | `in_reply_to_status_id_str` | Nullable. If the represented Tweet is a reply, this field will contain the string representation of the original Tweet’s ID. Example: `\"1051222721923756032\" `.  |
  > | `in_reply_to_user_id` | Nullable. If the represented Tweet is a reply, this field will contain the integer representation of the original Tweet’s author ID. This will not necessarily always be the user directly mentioned in the Tweet. Example: `6253282 `.  |
  > | `in_reply_to_user_id_str` | Nullable. If the represented Tweet is a reply, this field will contain the string representation of the original Tweet’s author ID. This will not necessarily always be the user directly mentioned in the Tweet. Example: `\"6253282\" `.  |
  > | `in_reply_to_screen_name` | Nullable. If the represented Tweet is a reply, this field will contain the screen name of the original Tweet’s author. Example: `\"twitterapi\" `.  |
  > | `user` | The user who posted this Tweet. See User data dictionary for complete list of attributes. |
  > | `coordinates` | Nullable. Represents the geographic location of this Tweet as reported by the user or client application. The inner coordinates array is formatted as geoJSON (longitude first, then latitude).  |
  > | `place` | Nullable When present, indicates that the tweet is associated (but not necessarily originating from) a Place .  |
  > | `quoted_status_id` | This field only surfaces when the Tweet is a quote Tweet. This field contains the integer value Tweet ID of the quoted Tweet. Example: `1050119905717055488 `.  |
  > | `quoted_status_id_str` | This field only surfaces when the Tweet is a quote Tweet. This is the string representation Tweet ID of the quoted Tweet. Example: `\"1050119905717055488\" `.  |
  > | `is_quote_status` | Indicates whether this is a Quoted Tweet. Example: `false `.  |
  > | `quoted_status` | This field only surfaces when the Tweet is a quote Tweet. This attribute contains the Tweet object of the original Tweet that was quoted. |
  > | `retweeted_status` | Users can amplify the broadcast of Tweets authored by other users by retweeting . Retweets can be distinguished from typical Tweets by the existence of a retweeted_status attribute. This attribute contains a representation of the original Tweet that was retweeted. Note that retweets of retweets do not show representations of the intermediary retweet, but only the original Tweet. (Users can also unretweet a retweet they created by deleting their retweet.) |
  > | `quote_count` | Nullable. Indicates approximately how many times this Tweet has been quoted by Twitter users. Example: `33 `. Note: This object is only available with the Premium and Enterprise tier products. |
  > | `reply_count` | Number of times this Tweet has been replied to. Example: `30 `. Note: This object is only available with the Premium and Enterprise tier products. |
  > | `retweet_count` | Number of times this Tweet has been retweeted. Example: `160 `.  |
  > | `favorite_count` | Nullable. Indicates approximately how many times this Tweet has been liked by Twitter users. Example: `295 `.  |
  > | `entities` | Entities which have been parsed out of the text of the Tweet. Additionally see Entities in Twitter Objects .  |
  > | `extended_entities` | When between one and four native photos or one video or one animated GIF are in Tweet, contains an array 'media' metadata. This is also available in Quote Tweets. Additionally see Entities in Twitter Objects .  |
  > | `favorited` | Nullable. Indicates whether this Tweet has been liked by the authenticating user. Example: `true `.  |
  > | `retweeted` | Indicates whether this Tweet has been Retweeted by the authenticating user. Example: `false `.  |
  > | `possibly_sensitive` | Nullable. This field only surfaces when a Tweet contains a link. The meaning of the field doesn’t pertain to the Tweet content itself, but instead it is an indicator that the URL contained in the Tweet may contain content or media identified as sensitive content. Example: `false `.  |
  > | `filter_level` | Indicates the maximum value of the filter_level parameter which may be used and still stream this Tweet. So a value of medium will be streamed on none, low, and medium streams.Example: `\"low\" `.  |
  > | `lang` | Nullable. When present, indicates a BCP 47 language identifier corresponding to the machine-detected language of the Tweet text, or und if no language could be detected. See more documentation HERE. Example: `\"en\" `.  |
  > | `matching_rules` | Present in filtered products such as Twitter Search and PowerTrack. Provides the id and tag associated with the rule that matched the Tweet. With PowerTrack, more than one rule can match a Tweet. See more documentation HERE. Example: `\" [{         \"tag\": \"twitterapi emojis\",         \"id\": 1050118621198921728,         \"id_str\": \"1050118621198921728\"     }]\" `.  |
  > | `current_user_retweet` | Perspectival Only surfaces on methods supporting the include_my_retweet parameter, when set to true. Details the Tweet ID of the user’s own retweet (if existent) of this Tweet. Example: `{   \"id\": 6253282,   \"id_str\": \"6253282\" } `.  |
  > | `scopes` | A set of key-value pairs indicating the intended contextual delivery of the containing Tweet. Currently used by Twitter’s Promoted Products. Example: `{\"followers\":false} `.  |
  > | `withheld_copyright` | When present and set to “true”, it indicates that this piece of content has been withheld due to a DMCA complaint . Example: `true `.  |
  > | `withheld_in_countries` | When present, indicates a list of uppercase two-letter country codes this content is withheld from. Twitter supports the following non-country values for this field:“XX” - Content is withheld in all countries “XY” - Content is withheld due to a DMCA request.Example: `[\"GR\", \"HK\", \"MY\"] `.  |
  > | `withheld_scope` | When present, indicates whether the content being withheld is the “status” or a “user.”Example: `\"status\" `.  |
  > | `contributors` |  -  |
  > | `display_text_range` |  -  |
  > | `full_text` |  -  |
  > | `possibly_sensitive_appealable` |  -  |
  > | `quoted_status_permalink` |  -  |
  >
  """
  @type t :: %__MODULE__{
          created_at: DateTime.t(),
          id: integer,
          id_str: binary,
          text: binary,
          source: binary,
          truncated: boolean,
          in_reply_to_status_id: integer | nil,
          in_reply_to_status_id_str: binary | nil,
          in_reply_to_user_id: integer | nil,
          in_reply_to_user_id_str: binary | nil,
          in_reply_to_screen_name: binary | nil,
          user: Tw.V1_1.User.t(),
          coordinates: Tw.V1_1.Coordinates.t() | nil,
          place: Tw.V1_1.Place.t() | nil,
          quoted_status_id: integer | nil,
          quoted_status_id_str: binary | nil,
          is_quote_status: boolean,
          quoted_status: Tw.V1_1.Tweet.t() | nil,
          retweeted_status: Tw.V1_1.Tweet.t() | nil,
          quote_count: integer | nil,
          reply_count: integer | nil,
          retweet_count: integer,
          favorite_count: integer | nil,
          entities: Tw.V1_1.Entities.t(),
          extended_entities: Tw.V1_1.ExtendedEntities.t() | nil,
          favorited: boolean | nil,
          retweeted: boolean,
          possibly_sensitive: boolean | nil,
          filter_level: binary | nil,
          lang: binary | nil,
          matching_rules: list(map) | nil,
          current_user_retweet: map | nil,
          scopes: map | nil,
          withheld_copyright: boolean | nil,
          withheld_in_countries: list(binary) | nil,
          withheld_scope: binary | nil,
          contributors: list(integer) | nil,
          display_text_range: list(integer) | nil,
          full_text: binary | nil,
          possibly_sensitive_appealable: boolean | nil,
          quoted_status_permalink: map | nil
        }
  @spec decode!(map) :: t
  @doc """
  Decode JSON-decoded map into `t:t/0`
  """
  def decode!(json) do
    json =
      json
      |> Map.update!(:created_at, &Schema.decode_twitter_datetime!/1)
      |> Map.update!(:user, &User.decode!/1)
      |> Map.update!(:coordinates, Schema.nilable(&Coordinates.decode!/1))
      |> Map.update!(:place, Schema.nilable(&Place.decode!/1))
      |> Map.update(:quoted_status, nil, Schema.nilable(&decode!/1))
      |> Map.update(:retweeted_status, nil, Schema.nilable(&decode!/1))
      |> Map.update!(:entities, &Entities.decode!/1)
      |> Map.update(:extended_entities, nil, Schema.nilable(&ExtendedEntities.decode!/1))

    struct(__MODULE__, json)
  end

  map_endpoint(:get, "/statuses/home_timeline.json", to: home_timeline)
  map_endpoint(:get, "/statuses/user_timeline.json", to: user_timeline)
  map_endpoint(:get, "/statuses/mentions_timeline.json", to: mentions_timeline)
  map_endpoint(:get, "/search/tweets.json", to: search)
  map_endpoint(:get, "/favorites/list.json", to: favorites)
  map_endpoint(:get, "/lists/statuses.json", to: of_list)
  map_endpoint(:get, "/statuses/lookup.json", to: list)
  map_endpoint(:get, "/statuses/retweets_of_me.json", to: retweets_of_me)
  map_endpoint(:get, "/statuses/retweets/:id.json", to: retweets)
  map_endpoint(:get, "/statuses/show/:id.json", to: find)
  map_endpoint(:get, "/statuses/oembed.json", to: oembed)
  map_endpoint(:post, "/statuses/update.json", to: create)
  map_endpoint(:post, "/statuses/destroy/:id.json", to: delete)
  map_endpoint(:post, "/statuses/retweet/:id.json", to: retweet)
  map_endpoint(:post, "/statuses/unretweet/:id.json", to: unretweet)
  map_endpoint(:post, "/favorites/create.json", to: favorite)
  map_endpoint(:post, "/favorites/destroy.json", to: unfavorite)
end
