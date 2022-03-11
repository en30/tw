defmodule Tw.V1_1.Tweet do
  @moduledoc """
  Tweet data structure and related functions.
  https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/tweet
  """

  alias Tw.V1_1.Client
  alias Tw.V1_1.Coordinates
  alias Tw.V1_1.Entities
  alias Tw.V1_1.ExtendedEntities
  alias Tw.V1_1.Place
  alias Tw.V1_1.Schema
  alias Tw.V1_1.SearchResult
  alias Tw.V1_1.TwitterDateTime
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
          user: User.t() | nil,
          coordinates: Coordinates.t() | nil,
          place: Place.t() | nil,
          quoted_status_id: integer | nil,
          quoted_status_id_str: binary | nil,
          is_quote_status: boolean,
          quoted_status: t() | nil,
          retweeted_status: t() | nil,
          quote_count: integer | nil,
          reply_count: integer | nil,
          retweet_count: integer,
          favorite_count: integer | nil,
          entities: Entities.t() | nil,
          extended_entities: ExtendedEntities.t() | nil,
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
      |> Map.update!(:created_at, &TwitterDateTime.decode!/1)
      |> Map.update(:user, nil, &User.decode!/1)
      |> Map.update!(:coordinates, Schema.nilable(&Coordinates.decode!/1))
      |> Map.update!(:place, Schema.nilable(&Place.decode!/1))
      |> Map.update(:quoted_status, nil, Schema.nilable(&decode!/1))
      |> Map.update(:retweeted_status, nil, Schema.nilable(&decode!/1))
      |> Map.update(:entities, nil, &Entities.decode!/1)
      |> Map.update(:extended_entities, nil, Schema.nilable(&ExtendedEntities.decode!/1))

    struct(__MODULE__, json)
  end

  ##################################
  # GET /statuses/home_timeline.json
  ##################################

  @typedoc """
  Parameters for `home_timeline/3`.

  > | name | description |
  > | - | - |
  > |count | Specifies the number of records to retrieve. Must be less than or equal to 200. Defaults to 20. The value of count is best thought of as a limit to the number of tweets to return because suspended or deleted content is removed after the count has been applied. |
  > |since_id | Returns results with an ID greater than (that is, more recent than) the specified ID. There are limits to the number of Tweets which can be accessed through the API. If the limit of Tweets has occured since the since_id, the since_id will be forced to the oldest ID available. |
  > |max_id | Returns results with an ID less than (that is, older than) or equal to the specified ID. |
  > |trim_user | When set to either true , t or 1 , each Tweet returned in a timeline will include a user object including only the status authors numerical ID. Omit this parameter to receive the complete user object. |
  > |exclude_replies | This parameter will prevent replies from appearing in the returned timeline. Using exclude_replies with the count parameter will mean you will receive up-to count Tweets — this is because the count parameter retrieves that many Tweets before filtering out retweets and replies. |
  > |include_entities | The entities node will not be included when set to false. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/tweets/timelines/api-reference/get-statuses-home_timeline) for details.

  """
  @type home_timeline_params :: %{
          optional(:count) => integer,
          optional(:since_id) => integer,
          optional(:max_id) => integer,
          optional(:trim_user) => boolean,
          optional(:exclude_replies) => boolean,
          optional(:include_entities) => boolean
        }
  @spec home_timeline(Client.t(), home_timeline_params) ::
          {:ok, list(t())} | {:error, Client.error()}
  @doc """
  Request `GET /statuses/home_timeline.json` and return decoded result.
  > Returns a collection of the most recent Tweets and Retweets posted by the authenticating user and the users they follow. The home timeline is central to how most users interact with the Twitter service.
  >
  > Up to 800 Tweets are obtainable on the home timeline. It is more volatile for users that follow many users or follow users who Tweet frequently.
  >
  > See Working with Timelines for instructions on traversing timelines efficiently.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/tweets/timelines/api-reference/get-statuses-home_timeline) for details.

  """
  def home_timeline(client, params) do
    with {:ok, json} <- Client.request(client, :get, "/statuses/home_timeline.json", params) do
      res = json |> Enum.map(&decode!/1)
      {:ok, res}
    end
  end

  ##################################
  # GET /statuses/user_timeline.json
  ##################################

  @typedoc """
  Parameters for `user_timeline/3`.

  > | name | description |
  > | - | - |
  > |user_id | The ID of the user for whom to return results. |
  > |screen_name | The screen name of the user for whom to return results. |
  > |since_id | Returns results with an ID greater than (that is, more recent than) the specified ID. There are limits to the number of Tweets that can be accessed through the API. If the limit of Tweets has occured since the since_id, the since_id will be forced to the oldest ID available. |
  > |count | Specifies the number of Tweets to try and retrieve, up to a maximum of 200 per distinct request. The value of count is best thought of as a limit to the number of Tweets to return because suspended or deleted content is removed after the count has been applied. We include retweets in the count, even if include_rts is not supplied. It is recommended you always send include_rts=1 when using this API method. |
  > |max_id | Returns results with an ID less than (that is, older than) or equal to the specified ID. |
  > |trim_user | When set to either true , t or 1 , each Tweet returned in a timeline will include a user object including only the status authors numerical ID. Omit this parameter to receive the complete user object. |
  > |exclude_replies | This parameter will prevent replies from appearing in the returned timeline. Using exclude_replies with the count parameter will mean you will receive up-to count tweets — this is because the count parameter retrieves that many Tweets before filtering out retweets and replies. |
  > |include_rts | When set to false , the timeline will strip any native retweets (though they will still count toward both the maximal length of the timeline and the slice selected by the count parameter). Note: If you're using the trim_user parameter in conjunction with include_rts, the retweets will still contain a full user object. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/tweets/timelines/api-reference/get-statuses-user_timeline) for details.

  """
  @type user_timeline_params :: %{
          optional(:user_id) => integer,
          optional(:screen_name) => binary,
          optional(:since_id) => integer,
          optional(:count) => integer,
          optional(:max_id) => integer,
          optional(:trim_user) => boolean,
          optional(:exclude_replies) => boolean,
          optional(:include_rts) => boolean
        }
  @spec user_timeline(Client.t(), user_timeline_params) ::
          {:ok, list(t())} | {:error, Client.error()}
  @doc """
  Request `GET /statuses/user_timeline.json` and return decoded result.
  > Important notice: On June 19, 2019, we began enforcing a limit of 100,000 requests per day to the /statuses/user_timeline endpoint, in addition to existing user-level and app-level rate limits. This limit is applied on a per-application basis, meaning that a single developer app can make up to 100,000 calls during any single 24-hour period.
  >
  > Returns a collection of the most recent Tweets posted by the user indicated by the screen_name or user_id parameters.
  >
  > User timelines belonging to protected users may only be requested when the authenticated user either \"owns\" the timeline or is an approved follower of the owner.
  >
  > The timeline returned is the equivalent of the one seen as a user's profile on Twitter.
  >
  > This method can only return up to 3,200 of a user's most recent Tweets. Native retweets of other statuses by the user is included in this total, regardless of whether include_rts is set to false when requesting this resource.
  >
  > See Working with Timelines for instructions on traversing timelines.
  >
  > See Embedded Timelines, Embedded Tweets, and GET statuses/oembed for tools to render Tweets according to Display Requirements.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/tweets/timelines/api-reference/get-statuses-user_timeline) for details.

  """
  def user_timeline(client, params) do
    with {:ok, json} <- Client.request(client, :get, "/statuses/user_timeline.json", params) do
      res = json |> Enum.map(&decode!/1)
      {:ok, res}
    end
  end

  ##################################
  # GET /statuses/mentions_timeline.json
  ##################################

  @typedoc """
  Parameters for `mentions_timeline/3`.

  > | name | description |
  > | - | - |
  > |count | Specifies the number of Tweets to try and retrieve, up to a maximum of 200. The value of count is best thought of as a limit to the number of tweets to return because suspended or deleted content is removed after the count has been applied. We include retweets in the count, even if include_rts is not supplied. It is recommended you always send include_rts=1 when using this API method. |
  > |since_id | Returns results with an ID greater than (that is, more recent than) the specified ID. There are limits to the number of Tweets which can be accessed through the API. If the limit of Tweets has occured since the since_id, the since_id will be forced to the oldest ID available. |
  > |max_id | Returns results with an ID less than (that is, older than) or equal to the specified ID. |
  > |trim_user | When set to either true , t or 1 , each tweet returned in a timeline will include a user object including only the status authors numerical ID. Omit this parameter to receive the complete user object. |
  > |include_entities | The entities node will not be included when set to false. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/tweets/timelines/api-reference/get-statuses-mentions_timeline) for details.

  """
  @type mentions_timeline_params :: %{
          optional(:count) => integer,
          optional(:since_id) => integer,
          optional(:max_id) => integer,
          optional(:trim_user) => boolean,
          optional(:include_entities) => boolean
        }
  @spec mentions_timeline(Client.t(), mentions_timeline_params) ::
          {:ok, list(t())} | {:error, Client.error()}
  @doc """
  Request `GET /statuses/mentions_timeline.json` and return decoded result.
  > Important notice: On June 19, 2019, we began enforcing a limit of 100,000 requests per day to the /statuses/mentions_timeline endpoint. This is in addition to existing user-level rate limits (75 requests / 15-minutes). This limit is enforced on a per-application basis, meaning that a single developer app can make up to 100,000 calls during any single 24-hour period.
  >
  > Returns the 20 most recent mentions (Tweets containing a users's @screen_name) for the authenticating user.
  >
  > The timeline returned is the equivalent of the one seen when you view your mentions on twitter.com.
  >
  > This method can only return up to 800 tweets.
  >
  > See Working with Timelines for instructions on traversing timelines.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/tweets/timelines/api-reference/get-statuses-mentions_timeline) for details.

  """
  def mentions_timeline(client, params) do
    with {:ok, json} <- Client.request(client, :get, "/statuses/mentions_timeline.json", params) do
      res = json |> Enum.map(&decode!/1)
      {:ok, res}
    end
  end

  ##################################
  # GET /search/tweets.json
  ##################################

  @typedoc """
  Parameters for `search/3`.

  > | name | description |
  > | - | - |
  > |q | A UTF-8, URL-encoded search query of 500 characters maximum, including operators. Queries may additionally be limited by complexity. |
  > |geocode | Returns tweets by users located within a given radius of the given latitude/longitude. The location is preferentially taking from the Geotagging API, but will fall back to their Twitter profile. The parameter value is specified by \" latitude,longitude,radius \", where radius units must be specified as either \" mi \" (miles) or \" km \" (kilometers). Note that you cannot use the near operator via the API to geocode arbitrary locations; however you can use this geocode parameter to search near geocodes directly. A maximum of 1,000 distinct \"sub-regions\" will be considered when using the radius modifier. |
  > |lang | Restricts tweets to the given language, given by an ISO 639-1 code. Language detection is best-effort. |
  > |locale | Specify the language of the query you are sending (only ja is currently effective). This is intended for language-specific consumers and the default should work in the majority of cases. |
  > |result_type | Optional. Specifies what type of search results you would prefer to receive. The current default is \"mixed.\" Valid values include:* mixed : Include both popular and real time results in the response.* recent : return only the most recent results in the response* popular : return only the most popular results in the response. |
  > |count | The number of tweets to return per page, up to a maximum of 100. Defaults to 15. This was formerly the \"rpp\" parameter in the old Search API. |
  > |until | Returns tweets created before the given date. Date should be formatted as YYYY-MM-DD. Keep in mind that the search index has a 7-day limit. In other words, no tweets will be found for a date older than one week. |
  > |since_id | Returns results with an ID greater than (that is, more recent than) the specified ID. There are limits to the number of Tweets which can be accessed through the API. If the limit of Tweets has occured since the since_id, the since_id will be forced to the oldest ID available. |
  > |max_id | Returns results with an ID less than (that is, older than) or equal to the specified ID. |
  > |include_entities | The entities node will not be included when set to false. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/tweets/search/api-reference/get-search-tweets) for details.

  """
  @type search_params :: %{
          required(:q) => binary,
          optional(:geocode) => integer,
          optional(:lang) => binary,
          optional(:locale) => binary,
          optional(:result_type) => binary,
          optional(:count) => integer,
          optional(:until) => integer,
          optional(:since_id) => integer,
          optional(:max_id) => integer,
          optional(:include_entities) => boolean
        }
  @spec search(Client.t(), search_params) :: {:ok, SearchResult.t()} | {:error, Client.error()}
  @doc """
  Request `GET /search/tweets.json` and return decoded result.
  > Returns a collection of relevant Tweets matching a specified query.
  >
  > Please note that Twitter's search service and, by extension, the Search API is not meant to be an exhaustive source of Tweets. Not all Tweets will be indexed or made available via the search interface.
  >
  > To learn how to use Twitter Search effectively, please see the Standard search operators page for a list of available filter operators. Also, see the Working with Timelines page to learn best practices for navigating results by since_id and max_id.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/tweets/search/api-reference/get-search-tweets) for details.

  """
  def search(client, params) do
    with {:ok, json} <- Client.request(client, :get, "/search/tweets.json", params) do
      res = json |> SearchResult.decode!()
      {:ok, res}
    end
  end

  ##################################
  # GET /favorites/list.json
  ##################################

  @typedoc """
  Parameters for `favorites/3`.

  > | name | description |
  > | - | - |
  > |user_id | The ID of the user for whom to return results. |
  > |screen_name | The screen name of the user for whom to return results. |
  > |count | Specifies the number of records to retrieve. Must be less than or equal to 200; defaults to 20. The value of count is best thought of as a limit to the number of Tweets to return because suspended or deleted content is removed after the count has been applied. |
  > |since_id | Returns results with an ID greater than (that is, more recent than) the specified ID. There are limits to the number of Tweets which can be accessed through the API. If the limit of Tweets has occured since the since_id, the since_id will be forced to the oldest ID available. |
  > |max_id | Returns results with an ID less than (that is, older than) or equal to the specified ID. |
  > |include_entities | The entities node will be omitted when set to false . |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/tweets/post-and-engage/api-reference/get-favorites-list) for details.

  """
  @type favorites_params :: %{
          optional(:user_id) => integer,
          optional(:screen_name) => binary,
          optional(:count) => integer,
          optional(:since_id) => integer,
          optional(:max_id) => integer,
          optional(:include_entities) => boolean
        }
  @spec favorites(Client.t(), favorites_params) :: {:ok, list(t())} | {:error, Client.error()}
  @doc """
  Request `GET /favorites/list.json` and return decoded result.
  > Note: favorites are now known as likes.
  >
  > Returns the 20 most recent Tweets liked by the authenticating or specified user.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/tweets/post-and-engage/api-reference/get-favorites-list) for details.

  """
  def favorites(client, params) do
    with {:ok, json} <- Client.request(client, :get, "/favorites/list.json", params) do
      res = json |> Enum.map(&decode!/1)
      {:ok, res}
    end
  end

  ##################################
  # GET /lists/statuses.json
  ##################################

  @typedoc """
  Parameters for `of_list/3`.

  > | name | description |
  > | - | - |
  > |list_id | The numerical id of the list. |
  > |slug | You can identify a list by its slug instead of its numerical id. If you decide to do so, note that you'll also have to specify the list owner using the owner_id or owner_screen_name parameters. |
  > |owner_screen_name | The screen name of the user who owns the list being requested by a slug . |
  > |owner_id | The user ID of the user who owns the list being requested by a slug . |
  > |since_id | Returns results with an ID greater than (that is, more recent than) the specified ID. There are limits to the number of Tweets which can be accessed through the API. If the limit of Tweets has occured since the since_id, the since_id will be forced to the oldest ID available. |
  > |max_id | Returns results with an ID less than (that is, older than) or equal to the specified ID. |
  > |count | Specifies the number of results to retrieve per \"page.\" |
  > |include_entities | Entities are ON by default in API 1.1, each tweet includes a node called \"entities\". This node offers a variety of metadata about the tweet in a discreet structure, including: user_mentions, urls, and hashtags. You can omit entities from the result by using include_entities=false |
  > |include_rts | When set to either true , t or 1 , the list timeline will contain native retweets (if they exist) in addition to the standard stream of tweets. The output format of retweeted tweets is identical to the representation you see in home_timeline. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/create-manage-lists/api-reference/get-lists-statuses) for details.

  """
  @type of_list_params :: %{
          required(:list_id) => binary,
          required(:slug) => binary,
          optional(:owner_screen_name) => binary,
          optional(:owner_id) => binary,
          optional(:since_id) => binary,
          optional(:max_id) => binary,
          optional(:count) => integer,
          optional(:include_entities) => binary,
          optional(:include_rts) => binary
        }
  @spec of_list(Client.t(), of_list_params) :: {:ok, list(t())} | {:error, Client.error()}
  @doc """
  Request `GET /lists/statuses.json` and return decoded result.
  > Returns a timeline of tweets authored by members of the specified list. Retweets are included by default. Use the include_rts=false parameter to omit retweets.
  >
  > Embedded Timelines is a great way to embed list timelines on your website.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/create-manage-lists/api-reference/get-lists-statuses) for details.

  """
  def of_list(client, params) do
    with {:ok, json} <- Client.request(client, :get, "/lists/statuses.json", params) do
      res = json |> Enum.map(&decode!/1)
      {:ok, res}
    end
  end

  ##################################
  # GET /statuses/lookup.json
  ##################################

  @typedoc """
  Parameters for `list/3`.

  > | name | description |
  > | - | - |
  > |id | A comma separated list of Tweet IDs, up to 100 are allowed in a single request. |
  > |include_entities | The entities node that may appear within embedded statuses will not be included when set to false. |
  > |trim_user | When set to either true , t or 1 , each Tweet returned in a timeline will include a user object including only the status authors numerical ID. Omit this parameter to receive the complete user object. |
  > |map | When using the map parameter, Tweets that do not exist or cannot be viewed by the current user will still have their key represented but with an explicitly null value paired with it |
  > |include_ext_alt_text | If alt text has been added to any attached media entities, this parameter will return an ext_alt_text value in the top-level key for the media entity. If no value has been set, this will be returned as null |
  > |include_card_uri | When set to either true , t or 1 , each Tweet returned will include a card_uri attribute when there is an ads card attached to the Tweet and when that card was attached using the card_uri value. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/tweets/post-and-engage/api-reference/get-statuses-lookup) for details.

  """
  @type list_params :: %{
          required(:id) => integer,
          optional(:include_entities) => boolean,
          optional(:trim_user) => boolean,
          optional(:map) => boolean,
          optional(:include_ext_alt_text) => boolean,
          optional(:include_card_uri) => boolean
        }
  @spec list(Client.t(), list_params) :: {:ok, list(t())} | {:error, Client.error()}
  @doc """
  Request `GET /statuses/lookup.json` and return decoded result.
  > Returns fully-hydrated Tweet objects for up to 100 Tweets per request, as specified by comma-separated values passed to the id parameter.
  >
  > This method is especially useful to get the details (hydrate) a collection of Tweet IDs.
  >
  > GET statuses / show / :id is used to retrieve a single Tweet object.
  >
  > There are a few things to note when using this method.
  >
  > You must be following a protected user to be able to see their most recent Tweets. If you don't follow a protected user their status will be removed.The order of Tweet IDs may not match the order of Tweets in the returned array.If a requested Tweet is unknown or deleted, then that Tweet will not be returned in the results list, unless the map parameter is set to true, in which case it will be returned with a value of null.If none of your lookup criteria matches valid Tweet IDs an empty array will be returned for map=false.You are strongly encouraged to use a POST for larger requests.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/tweets/post-and-engage/api-reference/get-statuses-lookup) for details.

  """
  def list(client, params) do
    with {:ok, json} <- Client.request(client, :get, "/statuses/lookup.json", params) do
      res = json |> Enum.map(&decode!/1)
      {:ok, res}
    end
  end

  ##################################
  # GET /statuses/retweets_of_me.json
  ##################################

  @typedoc """
  Parameters for `retweets_of_me/3`.

  > | name | description |
  > | - | - |
  > |count | Specifies the number of records to retrieve. Must be less than or equal to 100. If omitted, 20 will be assumed. |
  > |since_id | Returns results with an ID greater than (that is, more recent than) the specified ID. There are limits to the number of Tweets which can be accessed through the API. If the limit of Tweets has occured since the since_id, the since_id will be forced to the oldest ID available. |
  > |max_id | Returns results with an ID less than (that is, older than) or equal to the specified ID. |
  > |trim_user | When set to either true , t or 1 , each tweet returned in a timeline will include a user object including only the status authors numerical ID. Omit this parameter to receive the complete user object. |
  > |include_entities | The tweet entities node will not be included when set to false . |
  > |include_user_entities | The user entities node will not be included when set to false . |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/tweets/post-and-engage/api-reference/get-statuses-retweets_of_me) for details.

  """
  @type retweets_of_me_params :: %{
          optional(:count) => integer,
          optional(:since_id) => integer,
          optional(:max_id) => integer,
          optional(:trim_user) => boolean,
          optional(:include_entities) => boolean,
          optional(:include_user_entities) => boolean
        }
  @spec retweets_of_me(Client.t(), retweets_of_me_params) ::
          {:ok, list(t())} | {:error, Client.error()}
  @doc """
  Request `GET /statuses/retweets_of_me.json` and return decoded result.
  > Returns the most recent Tweets authored by the authenticating user that have been retweeted by others. This timeline is a subset of the user's GET statuses / user_timeline.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/tweets/post-and-engage/api-reference/get-statuses-retweets_of_me) for details.

  """
  def retweets_of_me(client, params) do
    with {:ok, json} <- Client.request(client, :get, "/statuses/retweets_of_me.json", params) do
      res = json |> Enum.map(&decode!/1)
      {:ok, res}
    end
  end

  ##################################
  # GET /statuses/retweets/:id.json
  ##################################

  @typedoc """
  Parameters for `retweets/3`.

  > | name | description |
  > | - | - |
  > |id | The numerical ID of the desired status. |
  > |count | Specifies the number of records to retrieve. Must be less than or equal to 100. |
  > |trim_user | When set to either true , t or 1 , each tweet returned in a timeline will include a user object including only the status authors numerical ID. Omit this parameter to receive the complete user object. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/tweets/post-and-engage/api-reference/get-statuses-retweets-id) for details.

  """
  @type retweets_params :: %{required(:id) => integer, optional(:count) => integer, optional(:trim_user) => boolean}
  @spec retweets(Client.t(), retweets_params) :: {:ok, list(t())} | {:error, Client.error()}
  @doc """
  Request `GET /statuses/retweets/:id.json` and return decoded result.
  > Returns a collection of the 100 most recent retweets of the Tweet specified by the id parameter.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/tweets/post-and-engage/api-reference/get-statuses-retweets-id) for details.

  """
  def retweets(client, params) do
    with {:ok, json} <- Client.request(client, :get, "/statuses/retweets/:id.json", params) do
      res = json |> Enum.map(&decode!/1)
      {:ok, res}
    end
  end

  ##################################
  # GET /statuses/show/:id.json
  ##################################

  @typedoc """
  Parameters for `find/3`.

  > | name | description |
  > | - | - |
  > |id | The numerical ID of the desired Tweet. |
  > |trim_user | When set to either true , t or 1 , each Tweet returned in a timeline will include a user object including only the status authors numerical ID. Omit this parameter to receive the complete user object. |
  > |include_my_retweet | When set to either true , t or 1 , any Tweets returned that have been retweeted by the authenticating user will include an additional current_user_retweet node, containing the ID of the source status for the retweet. |
  > |include_entities | The entities node will not be included when set to false. |
  > |include_ext_alt_text | If alt text has been added to any attached media entities, this parameter will return an ext_alt_text value in the top-level key for the media entity. If no value has been set, this will be returned as null |
  > |include_card_uri | When set to either true , t or 1 , the retrieved Tweet will include a card_uri attribute when there is an ads card attached to the Tweet and when that card was attached using the card_uri value. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/tweets/post-and-engage/api-reference/get-statuses-show-id) for details.

  """
  @type find_params :: %{
          required(:id) => integer,
          optional(:trim_user) => boolean,
          optional(:include_my_retweet) => boolean,
          optional(:include_entities) => boolean,
          optional(:include_ext_alt_text) => boolean,
          optional(:include_card_uri) => boolean
        }
  @spec find(Client.t(), find_params) :: {:ok, t()} | {:error, Client.error()}
  @doc """
  Request `GET /statuses/show/:id.json` and return decoded result.
  > Returns a single Tweet, specified by the id parameter. The Tweet's author will also be embedded within the Tweet.
  >
  > See GET statuses / lookup for getting Tweets in bulk (up to 100 per call). See also Embedded Timelines, Embedded Tweets, and GET statuses/oembed for tools to render Tweets according to Display Requirements.
  >
  > About Geo
  >
  > If there is no geotag for a status, then there will be an empty <geo></geo> or \"geo\" : {}. This can only be populated if the user has used the Geotagging API to send a statuses/update.
  >
  > The JSON response mostly uses conventions laid out in GeoJSON. The coordinates that Twitter renders are reversed from the GeoJSON specification (GeoJSON specifies a longitude then a latitude, whereas Twitter represents it as a latitude then a longitude), eg: \"geo\": { \"type\":\"Point\", \"coordinates\":[37.78029, -122.39697] }

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/tweets/post-and-engage/api-reference/get-statuses-show-id) for details.

  """
  def find(client, params) do
    with {:ok, json} <- Client.request(client, :get, "/statuses/show/:id.json", params) do
      res = json |> decode!()
      {:ok, res}
    end
  end

  ##################################
  # GET /statuses/oembed.json
  ##################################

  @typedoc """
  Parameters for `oembed/3`.

  > | name | description |
  > | - | - |
  > |url | The URL of the Tweet to be embedded |
  > |maxwidth | The maximum width of a rendered Tweet in whole pixels. A supplied value under or over the allowed range will be returned as the minimum or maximum supported width respectively; the reset width value will be reflected in the returned width property. Note that Twitter does not support the oEmbed maxheight parameter. Tweets are fundamentally text, and are therefore of unpredictable height that cannot be scaled like an image or video. Relatedly, the oEmbed response will not provide a value for height. Implementations that need consistent heights for Tweets should refer to the hide_thread and hide_media parameters below. |
  > |hide_media | When set to true, \"t\", or 1 links in a Tweet are not expanded to photo, video, or link previews. |
  > |hide_thread | When set to true, \"t\", or 1 a collapsed version of the previous Tweet in a conversation thread will not be displayed when the requested Tweet is in reply to another Tweet. |
  > |omit_script | When set to true, \"t\", or 1 the <script> responsible for loading widgets.js will not be returned. Your webpages should include their own reference to widgets.js for use across all Twitter widgets including Embedded Tweets. |
  > |align | Specifies whether the embedded Tweet should be floated left, right, or center in the page relative to the parent element. |
  > |related | A comma-separated list of Twitter usernames related to your content. This value will be forwarded to Tweet action intents if a viewer chooses to reply, like, or retweet the embedded Tweet. |
  > |lang | Request returned HTML and a rendered Tweet in the specified Twitter language supported by embedded Tweets. |
  > |theme | When set to dark, the Tweet is displayed with light text over a dark background. |
  > |link_color | Adjust the color of Tweet text links with a hexadecimal color value. |
  > |widget_type | Set to video to return a Twitter Video embed for the given Tweet. |
  > |dnt | When set to true, the Tweet and its embedded page on your site are not used for purposes that include personalized suggestions and personalized ads. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/tweets/post-and-engage/api-reference/get-statuses-oembed) for details.

  """
  @type oembed_params :: %{
          required(:url) => binary,
          optional(:maxwidth) => pos_integer,
          optional(:hide_media) => boolean,
          optional(:hide_thread) => boolean,
          optional(:omit_script) => boolean,
          optional(:align) => :left | :right | :center | :none,
          optional(:related) => binary,
          optional(:lang) => Schema.language(),
          optional(:theme) => :light | :dark,
          optional(:link_color) => binary,
          optional(:widget_type) => :video,
          optional(:dnt) => boolean
        }
  @spec oembed(Client.t(), oembed_params) ::
          {:ok,
           %{
             url: binary,
             author_name: binary,
             author_url: binary,
             html: binary,
             width: non_neg_integer,
             height: non_neg_integer | nil,
             type: binary,
             cache_age: binary,
             provider_name: binary,
             provider_url: binary,
             version: binary
           }}
          | {:error, Client.error()}
  @doc """
  Request `GET /statuses/oembed.json` and return decoded result.
  > Returns a single Tweet, specified by either a Tweet web URL or the Tweet ID, in an oEmbed-compatible format. The returned HTML snippet will be automatically recognized as an Embedded Tweet when Twitter's widget JavaScript is included on the page.
  >
  > The oEmbed endpoint allows customization of the final appearance of an Embedded Tweet by setting the corresponding properties in HTML markup to be interpreted by Twitter's JavaScript bundled with the HTML response by default. The format of the returned markup may change over time as Twitter adds new features or adjusts its Tweet representation.
  >
  > The Tweet fallback markup is meant to be cached on your servers for up to the suggested cache lifetime specified in the cache_age.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/tweets/post-and-engage/api-reference/get-statuses-oembed) for details.

  """
  def oembed(client, params) do
    Client.request(client, :get, "/statuses/oembed.json", params)
  end

  ##################################
  # POST /statuses/update.json
  ##################################

  @typedoc """
  Parameters for `create/3`.

  > | name | description |
  > | - | - |
  > |status | The text of the status update. URL encode as necessary. t.co link wrapping will affect character counts. |
  > |in_reply_to_status_id | The ID of an existing status that the update is in reply to. Note: This parameter will be ignored unless the author of the Tweet this parameter references is mentioned within the status text. Therefore, you must include @username , where username is the author of the referenced Tweet, within the update. |
  > |auto_populate_reply_metadata | If set to true and used with in_reply_to_status_id, leading @mentions will be looked up from the original Tweet, and added to the new Tweet from there. This wil append @mentions into the metadata of an extended Tweet as a reply chain grows, until the limit on @mentions is reached. In cases where the original Tweet has been deleted, the reply will fail. |
  > |exclude_reply_user_ids | When used with auto_populate_reply_metadata, a comma-separated list of user ids which will be removed from the server-generated @mentions prefix on an extended Tweet. Note that the leading @mention cannot be removed as it would break the in-reply-to-status-id semantics. Attempting to remove it will be silently ignored. |
  > |attachment_url | In order for a URL to not be counted in the status body of an extended Tweet, provide a URL as a Tweet attachment. This URL must be a Tweet permalink, or Direct Message deep link. Arbitrary, non-Twitter URLs must remain in the status text. URLs passed to the attachment_url parameter not matching either a Tweet permalink or Direct Message deep link will fail at Tweet creation and cause an exception. |
  > |media_ids | A comma-delimited list of media_ids to associate with the Tweet. You may include up to 4 photos or 1 animated GIF or 1 video in a Tweet. See Uploading Media for further details on uploading media. |
  > |possibly_sensitive | If you upload Tweet media that might be considered sensitive content such as nudity, or medical procedures, you must set this value to true. If this parameter is included in your request, it will override the user’s preferences. Including any value other than true, 1, or t will be interpreted as false. See Media setting and best practices for more context. |
  > |lat | The latitude of the location this Tweet refers to. This parameter will be ignored unless it is inside the range -90.0 to +90.0 (North is positive) inclusive. It will also be ignored if there is no corresponding long parameter. |
  > |long | The longitude of the location this Tweet refers to. The valid ranges for longitude are -180.0 to +180.0 (East is positive) inclusive. This parameter will be ignored if outside that range, if it is not a number, if geo_enabled is turned off, or if there no corresponding lat parameter. |
  > |place_id | A place in the world. |
  > |display_coordinates | Whether or not to put a pin on the exact coordinates a Tweet has been sent from. |
  > |trim_user | When set to either true , t or 1 , the response will include a user object including only the author's ID. Omit this parameter to receive the complete user object. |
  > |enable_dmcommands | When set to true, enables shortcode commands for sending Direct Messages as part of the status text to send a Direct Message to a user. When set to false, it turns off this behavior and includes any leading characters in the status text that is posted |
  > |fail_dmcommands | When set to true, causes any status text that starts with shortcode commands to return an API error. When set to false, allows shortcode commands to be sent in the status text and acted on by the API. |
  > |card_uri | Associate an ads card with the Tweet using the card_uri value from any ads card response. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/tweets/post-and-engage/api-reference/post-statuses-update) for details.

  """
  @type create_params :: %{
          required(:status) => binary,
          optional(:in_reply_to_status_id) => binary,
          optional(:auto_populate_reply_metadata) => boolean,
          optional(:exclude_reply_user_ids) => binary,
          optional(:attachment_url) => binary,
          optional(:media_ids) => integer,
          optional(:possibly_sensitive) => boolean,
          optional(:lat) => binary,
          optional(:long) => binary,
          optional(:place_id) => binary,
          optional(:display_coordinates) => boolean,
          optional(:trim_user) => boolean,
          optional(:enable_dmcommands) => boolean,
          optional(:fail_dmcommands) => boolean,
          optional(:card_uri) => binary
        }
  @spec create(Client.t(), create_params) :: {:ok, t()} | {:error, Client.error()}
  @doc """
  Request `POST /statuses/update.json` and return decoded result.
  > Updates the authenticating user's current status, also known as Tweeting.
  >
  > For each update attempt, the update text is compared with the authenticating user's recent Tweets. Any attempt that would result in duplication will be blocked, resulting in a 403 error. A user cannot submit the same status twice in a row.
  >
  > While not rate limited by the API, a user is limited in the number of Tweets they can create at a time. If the number of updates posted by the user reaches the current allowed limit this method will return an HTTP 403 error.
  >
  > About Geo
  >
  > Any geo-tagging parameters in the update will be ignored if geo_enabled for the user is false (this is the default setting for all users, unless the user has enabled geolocation in their settings)The number of digits after the decimal separator passed to lat (up to 8) is tracked so that when the lat is returned in a status object it will have the same number of digits after the decimal separator.Use a decimal point as the separator (and not a decimal comma) for the latitude and the longitude - usage of a decimal comma will cause the geo-tagged portion of the status update to be dropped.For JSON, the response mostly uses conventions described in GeoJSON. However, the geo object coordinates that Twitter renders are reversed from the GeoJSON specification. GeoJSON specifies a longitude then a latitude, whereas Twitter represents it as a latitude then a longitude: \"geo\": { \"type\":\"Point\", \"coordinates\":[37.78217, -122.40062] }The coordinates object is replacing the geo object (no deprecation date has been set for the geo object yet) -- the difference is that the coordinates object, in JSON, is now rendered correctly in GeoJSON.If a place_id is passed into the status update, then that place will be attached to the status. If no place_id was explicitly provided, but latitude and longitude are, the API attempts to implicitly provide a place by calling geo/reverse_geocode.Users have the ability to remove all geotags from all their Tweets en masse via the user settings page. Currently there is no method to remove geotags from individual Tweets.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/tweets/post-and-engage/api-reference/post-statuses-update) for details.

  """
  def create(client, params) do
    with {:ok, json} <- Client.request(client, :post, "/statuses/update.json", params) do
      res = json |> decode!()
      {:ok, res}
    end
  end

  ##################################
  # POST /statuses/destroy/:id.json
  ##################################

  @typedoc """
  Parameters for `delete/3`.

  > | name | description |
  > | - | - |
  > |id | The numerical ID of the desired status. |
  > |trim_user | When set to either true , t or 1 , each tweet returned in a timeline will include a user object including only the status authors numerical ID. Omit this parameter to receive the complete user object. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/tweets/post-and-engage/api-reference/post-statuses-destroy-id) for details.

  """
  @type delete_params :: %{required(:id) => integer, optional(:trim_user) => boolean}
  @spec delete(Client.t(), delete_params) :: {:ok, t()} | {:error, Client.error()}
  @doc """
  Request `POST /statuses/destroy/:id.json` and return decoded result.
  > Destroys the status specified by the required ID parameter. The authenticating user must be the author of the specified status. Returns the destroyed status if successful.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/tweets/post-and-engage/api-reference/post-statuses-destroy-id) for details.

  """
  def delete(client, params) do
    with {:ok, json} <- Client.request(client, :post, "/statuses/destroy/:id.json", params) do
      res = json |> decode!()
      {:ok, res}
    end
  end

  ##################################
  # POST /statuses/retweet/:id.json
  ##################################

  @typedoc """
  Parameters for `retweet/3`.

  > | name | description |
  > | - | - |
  > |id | The numerical ID of the desired status. |
  > |trim_user | When set to either true , t or 1 , each tweet returned in a timeline will include a user object including only the status authors numerical ID. Omit this parameter to receive the complete user object. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/tweets/post-and-engage/api-reference/post-statuses-retweet-id) for details.

  """
  @type retweet_params :: %{required(:id) => integer, optional(:trim_user) => boolean}
  @spec retweet(Client.t(), retweet_params) :: {:ok, t()} | {:error, Client.error()}
  @doc """
  Request `POST /statuses/retweet/:id.json` and return decoded result.
  > Retweets a tweet. Returns the original Tweet with Retweet details embedded.
  >
  > Usage Notes:
  >
  > This method is subject to update limits. A HTTP 403 will be returned if this limit as been hit.Twitter will ignore attempts to perform duplicate retweets.The retweet_count will be current as of when the payload is generated and may not reflect the exact count. It is intended as an approximation.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/tweets/post-and-engage/api-reference/post-statuses-retweet-id) for details.

  """
  def retweet(client, params) do
    with {:ok, json} <- Client.request(client, :post, "/statuses/retweet/:id.json", params) do
      res = json |> decode!()
      {:ok, res}
    end
  end

  ##################################
  # POST /statuses/unretweet/:id.json
  ##################################

  @typedoc """
  Parameters for `unretweet/3`.

  > | name | description |
  > | - | - |
  > |id | The numerical ID of the desired status. |
  > |trim_user | When set to either true , t or 1 , each Tweet returned in a timeline will include a user object including only the status authors numerical ID. Omit this parameter to receive the complete user object. |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/tweets/post-and-engage/api-reference/post-statuses-unretweet-id) for details.

  """
  @type unretweet_params :: %{required(:id) => integer, optional(:trim_user) => boolean}
  @spec unretweet(Client.t(), unretweet_params) :: {:ok, t()} | {:error, Client.error()}
  @doc """
  Request `POST /statuses/unretweet/:id.json` and return decoded result.
  > Untweets a retweeted status. Returns the original Tweet with Retweet details embedded.
  >
  > Usage Notes:
  >
  > This method is subject to update limits. A HTTP 429 will be returned if this limit has been hit.The untweeted retweet status ID must be authored by the user backing the authentication token.An application must have write privileges to POST. A HTTP 401 will be returned for read-only applications.When passing a source status ID instead of the retweet status ID a HTTP 200 response will be returned with the same Tweet object but no action.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/tweets/post-and-engage/api-reference/post-statuses-unretweet-id) for details.

  """
  def unretweet(client, params) do
    with {:ok, json} <- Client.request(client, :post, "/statuses/unretweet/:id.json", params) do
      res = json |> decode!()
      {:ok, res}
    end
  end

  ##################################
  # POST /favorites/create.json
  ##################################

  @typedoc """
  Parameters for `favorite/3`.

  > | name | description |
  > | - | - |
  > |id | The numerical ID of the Tweet to like. |
  > |include_entities | The entities node will be omitted when set to false . |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/tweets/post-and-engage/api-reference/post-favorites-create) for details.

  """
  @type favorite_params :: %{required(:id) => integer, optional(:include_entities) => boolean}
  @spec favorite(Client.t(), favorite_params) :: {:ok, t()} | {:error, Client.error()}
  @doc """
  Request `POST /favorites/create.json` and return decoded result.
  > Note: favorites are now known as likes.
  >
  > Favorites (likes) the Tweet specified in the ID parameter as the authenticating user. Returns the favorite Tweet when successful.
  >
  > The process invoked by this method is asynchronous. The immediately returned Tweet object may not indicate the resultant favorited status of the Tweet. A 200 OK response from this method will indicate whether the intended action was successful or not.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/tweets/post-and-engage/api-reference/post-favorites-create) for details.

  """
  def favorite(client, params) do
    with {:ok, json} <- Client.request(client, :post, "/favorites/create.json", params) do
      res = json |> decode!()
      {:ok, res}
    end
  end

  ##################################
  # POST /favorites/destroy.json
  ##################################

  @typedoc """
  Parameters for `unfavorite/3`.

  > | name | description |
  > | - | - |
  > |id | The numerical ID of the Tweet to un-like |
  > |include_entities | The entities node will be omitted when set to false . |
  >

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/tweets/post-and-engage/api-reference/post-favorites-destroy) for details.

  """
  @type unfavorite_params :: %{required(:id) => integer, optional(:include_entities) => boolean}
  @spec unfavorite(Client.t(), unfavorite_params) :: {:ok, t()} | {:error, Client.error()}
  @doc """
  Request `POST /favorites/destroy.json` and return decoded result.
  > Note: favorites are now known as likes.
  >
  > Unfavorites (un-likes) the Tweet specified in the ID parameter as the authenticating user. Returns the un-liked Tweet when successful.
  >
  > The process invoked by this method is asynchronous. The immediately returned Tweet object may not indicate the resultant favorited status of the Tweet. A 200 OK response from this method will indicate whether the intended action was successful or not.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/tweets/post-and-engage/api-reference/post-favorites-destroy) for details.

  """
  def unfavorite(client, params) do
    with {:ok, json} <- Client.request(client, :post, "/favorites/destroy.json", params) do
      res = json |> decode!()
      {:ok, res}
    end
  end
end
