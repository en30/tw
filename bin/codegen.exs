Mix.install([
  {:floki, "~> 0.32"},
  {:req, "~> 0.2.0"}
])

defmodule Tw.V1_1.Schema.Type do
  @type t :: {quoted_type :: term(), decoder :: (map -> term())}

  @identity quote(do: Function.identity())

  def from_twitter(:created_at, "String"), do: quote(do: DateTime.t())
  def from_twitter(:bounding_box, "Object"), do: quote(do: BoundingBox.t())

  def from_twitter(name, "Array of " <> t) do
    quote(do: list(unquote(from_twitter(name, t |> String.trim_trailing("s")))))
  end

  def from_twitter(name, "Collection of " <> t),
    do: from_twitter(name, "Array of " <> t)

  def from_twitter(_name, "String"), do: quote(do: binary)
  def from_twitter(_name, "Int64"), do: quote(do: integer)
  def from_twitter(_name, "Integer"), do: quote(do: integer)
  def from_twitter(_name, "Int"), do: quote(do: integer)
  def from_twitter(_name, "Boolean"), do: quote(do: boolean)
  def from_twitter(_name, "Float"), do: quote(do: float)
  def from_twitter(_name, "Object"), do: quote(do: map)
  def from_twitter(_name, "Array of String"), do: quote(do: list(binary))
  def from_twitter(_name, "Option Object"), do: quote(do: map)
  def from_twitter(:maxwidth, "Int [220..550]"), do: quote(do: pos_integer)
  def from_twitter(_name, "Boolean, String or Int"), do: quote(do: boolean)

  def from_twitter(_name, "Enum {left,right,center,none}"),
    do: quote(do: :left | :right | :center | :none)

  def from_twitter(_name, "Enum(Language)"), do: quote(do: Schema.language())
  def from_twitter(_name, "Enum {light, dark}"), do: quote(do: :light | :dark)
  def from_twitter(_name, "Enum {video}"), do: quote(do: :video)
  def from_twitter(_name, "Place Type Object"), do: quote(do: %{code: non_neg_integer, name: binary})
  def from_twitter(_name, "Rule Object"), do: quote(do: map)
  def from_twitter(_name, "Arrays of Enrichment Objects"), do: quote(do: list(map))

  def from_twitter(_name, "User object"), do: quote(do: User.t())
  def from_twitter(_name, "Me Object"), do: quote(do: Me.t())
  def from_twitter(_name, "Tweet"), do: quote(do: Tweet.t())
  def from_twitter(_name, "Coordinates"), do: quote(do: Coordinates.t())
  def from_twitter(_name, "Places"), do: quote(do: Place.t())
  def from_twitter(_name, "Entities"), do: quote(do: Entities.t())
  def from_twitter(_name, "Hashtag Object"), do: quote(do: Hashtag.t())
  def from_twitter(_name, "Media Object"), do: quote(do: Media.t())
  def from_twitter(_name, "URL Object"), do: quote(do: URL.t())
  def from_twitter(_name, "User Mention Object"), do: quote(do: UserMention.t())
  def from_twitter(_name, "Symbol Object"), do: quote(do: Symbol.t())
  def from_twitter(_name, "Poll Object"), do: quote(do: Poll.t())
  def from_twitter(:sizes, "Size Object"), do: quote(do: Sizes.t())
  def from_twitter(_name, "Size Object"), do: quote(do: Size.t())
  def from_twitter(_name, "User Entities"), do: quote(do: UserEntities.t())
  def from_twitter(_name, "Extended Entities"), do: quote(do: ExtendedEntities.t())
  def from_twitter(_name, "Search Result Object"), do: quote(do: SearchResult.t())
  def from_twitter(_name, "Search Metadata Object"), do: quote(do: SearchMetadata.t())
  def from_twitter(_name, "Friendship Lookup Result Object"), do: quote(do: FriendshipLookupResult.t())
  def from_twitter(_name, "Friendship Source Object"), do: quote(do: FriendshipSource.t())
  def from_twitter(_name, "Friendship Target Object"), do: quote(do: FriendshipTarget.t())
  def from_twitter(_name, "Trend Location Object"), do: quote(do: TrendLocation.t())

  def from_twitter(_name, "Trends Object") do
    quote do
      %{
        trends: list(Trend.t()),
        as_of: DateTime.t(),
        created_at: DateTime.t(),
        locations: list(%{name: binary, woeid: non_neg_integer()})
      }
    end
  end

  def from_twitter(_name, "Connection Enum"), do: quote(do: FriendshipLookupResult.connections())

  def from_twitter(name, type, false), do: from_twitter(name, type)

  def from_twitter(name, type, true) do
    quote do
      unquote(from_twitter(name, type)) | nil
    end
  end

  def decoder({{:., [], [{:__aliases__, _, [:CursoredResult]}, :t]}, [], [k, v]}) do
    quote do
      Map.update!(unquote(k), fn v -> v |> unquote(decoder(v)) end)
    end
  end

  def decoder(:created_at, {:binary, _, _}), do: quote(do: &TwitterDateTime.decode!/1)
  def decoder(:bounding_box, _), do: quote(do: &BoundingBox.decode!/1)

  def decoder({:list, _, [type]}) do
    case decoder(type) do
      @identity ->
        @identity

      decs when is_list(decs) ->
        decs
        |> Enum.reject(&match?(@identity, &1))
        |> case do
          [] ->
            @identity

          decs ->
            res =
              decs
              |> Enum.reduce(quote(do: v), fn e, a ->
                quote(do: unquote(a) |> unquote(e))
              end)

            quote do
              Enum.map(fn v -> unquote(res) end)
            end
        end

      {{:., [], [{:__aliases__, _, _} = mod, f]}, [], []} ->
        quote do
          Enum.map(&(unquote(mod).unquote(f) / 1))
        end

      dec ->
        quote do
          Enum.map(fn v -> v |> unquote(dec) end)
        end
    end
  end

  def decoder({:%{}, _, fields}) do
    fields
    |> Enum.map(fn {k, v} ->
      case decoder(v) do
        @identity ->
          @identity

        decs when is_list(decs) ->
          decs
          |> Enum.reject(&match?(@identity, &1))
          |> case do
            [] ->
              @identity

            decs ->
              res =
                decs
                |> Enum.reduce(quote(do: v), fn e, a ->
                  quote(do: unquote(a) |> unquote(e))
                end)

              quote(do: Map.update!(unquote(k), fn v -> unquote(res) end))
          end

        dec ->
          quote(do: Map.update!(unquote(k), fn v -> v |> unquote(dec) end))
      end
    end)
    |> Enum.reject(&identity?/1)
  end

  def decoder({{:., _, [{:__aliases__, _, _} = mod, :t]}, _, []}) do
    quote(do: unquote(mod).decode!())
  end

  def decoder(_), do: @identity

  defp identity?(type), do: type == @identity

  def infer(name, example)
  def infer(_name, "true"), do: quote(do: boolean())
  def infer(_name, "false"), do: quote(do: boolean())
  def infer("count", _), do: quote(do: integer())
  def infer("screen_name", "twitterapi twitter"), do: quote(do: list(binary()))
  def infer("user_id", "783214 6253282"), do: quote(do: list(integer()))
  def infer("id", "20 1050118621198921728"), do: quote(do: list(integer()))

  def infer(_name, example) do
    case Integer.parse(example) do
      {_, ""} -> quote(do: integer())
      _ -> quote(do: binary())
    end
  end
end

defmodule Tw.V1_1.Schema.Endpoint do
  alias Tw.V1_1.Schema.Type

  def return_type(endpoint)
      when endpoint in [
             "GET statuses/home_timeline",
             "GET statuses/user_timeline",
             "GET statuses/mentions_timeline",
             "GET favorites/list",
             "GET lists/statuses",
             "GET statuses/lookup",
             "GET statuses/retweets_of_me",
             "GET statuses/retweets/:id"
           ] do
    quote(do: list(Tweet.t()))
  end

  def return_type(endpoint)
      when endpoint in [
             "GET users/show",
             "POST blocks/create",
             "POST blocks/destroy",
             "POST mutes/users/create",
             "POST mutes/users/destroy",
             "POST users/report_spam",
             "POST friendships/create",
             "POST friendships/destroy"
           ] do
    quote(do: User.t())
  end

  def return_type(endpoint)
      when endpoint in [
             "GET users/lookup",
             "GET users/search"
           ],
      do: quote(do: list(User.t()))

  def return_type("Standard search API"), do: quote(do: SearchResult.t())

  def return_type(endpoint)
      when endpoint in [
             "GET followers/ids",
             "GET friends/ids",
             "GET friendships/incoming",
             "GET friendships/outgoing",
             "GET blocks/ids",
             "GET mutes/users/ids",
             "GET statuses/retweeters/ids"
           ] do
    quote(do: CursoredResult.t(:id, list(integer())))
  end

  def return_type(endpoint)
      when endpoint in [
             "GET followers/list",
             "GET friends/list",
             "GET blocks/list",
             "GET mutes/users/list",
             "GET lists/members",
             "GET lists/subscribers"
           ] do
    quote(do: CursoredResult.t(:users, list(User.t())))
  end

  def return_type("GET friendships/no_retweets/ids"), do: quote(do: list(integer()))
  def return_type("GET friendships/lookup"), do: quote(do: list(FriendshipLookupResult.t()))

  def return_type(endpoint)
      when endpoint in [
             "GET friendships/show",
             "POST friendships/update"
           ] do
    quote(do: %{relationship: %{source: FriendshipSource.t(), target: FriendshipTarget.t()}})
  end

  def return_type(endpoint)
      when endpoint in [
             "GET account/verify_credentials",
             "POST account/update_profile_image"
           ] do
    quote(do: Me.t())
  end

  def return_type(endpoint)
      when endpoint in [
             "GET statuses/show/:id",
             "POST statuses/update",
             "POST statuses/destroy/:id",
             "POST statuses/retweet/:id",
             "POST statuses/unretweet/:id",
             "POST favorites/create",
             "POST favorites/destroy"
           ] do
    quote(do: Tweet.t())
  end

  def return_type("GET statuses/oembed") do
    quote(
      do: %{
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
      }
    )
  end

  def return_type(endpoint)
      when endpoint in [
             "GET trends/closest",
             "GET trends/available"
           ] do
    quote(do: list(TrendLocation.t()))
  end

  def return_type("GET trends/place") do
    quote do
      list(%{
        trends: list(Trend.t()),
        as_of: DateTime.t(),
        created_at: DateTime.t(),
        locations: list(%{name: binary(), woeid: non_neg_integer()})
      })
    end
  end

  def return_type(endpoint)
      when endpoint in [
             "GET account/settings",
             "POST account/settings"
           ] do
    quote(
      do: %{
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
        sleep_time: %{
          enabled: boolean(),
          end_time: non_neg_integer() | nil,
          start_time: non_neg_integer() | nil
        },
        time_zone: %{
          name: binary(),
          tzinfo_name: binary(),
          utc_offset: integer()
        },
        translator_type: binary(),
        trend_location: list(TrendLocation.t()),
        use_cookie_personalization: boolean()
      }
    )
  end

  def return_type("GET users/profile_banner") do
    quote(
      do: %{
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
      }
    )
  end

  def return_type(endpoint)
      when endpoint in [
             "POST account/update_profile_banner",
             "POST account/remove_profile_banner"
           ] do
    quote(do: binary())
  end
end

defmodule Tw.V1_1.Schema.ModelField do
  defstruct [:name, :type, :required, :nilable, description: nil]

  @type t :: %__MODULE__{
          name: atom(),
          type: term(),
          description: binary() | nil,
          required: boolean(),
          nilable: boolean()
        }

  defmacro model_field(name, type, opts) do
    quote do
      Tw.V1_1.Schema.ModelField.new(unquote(name), unquote(Macro.escape(type)), unquote(opts))
    end
  end

  def new(name, type, opts) do
    Keyword.merge(opts, name: name, type: type)
    |> then(&struct!(__MODULE__, &1))
  end

  def decoder(model_field)

  def decoder(%{name: name, type: type, required: false, nilable: false}) do
    decoder = decoder(name, type)

    if decoder == quote(do: &Function.identity/1) do
      nil
    else
      quote do
        Map.update(unquote(name), nil, Schema.nilable(unquote(decoder)))
      end
    end
  end

  def decoder(%{name: name, type: type, required: false, nilable: true}) do
    decoder = decoder(name, type)

    if decoder == quote(do: &Function.identity/1) do
      nil
    else
      quote do
        Map.update(unquote(name), nil, Schema.nilable(unquote(decoder)))
      end
    end
  end

  def decoder(%{name: name, type: type, required: true, nilable: false}) do
    decoder = decoder(name, type)

    if decoder == quote(do: &Function.identity/1) do
      nil
    else
      quote do
        Map.update!(unquote(name), unquote(decoder))
      end
    end
  end

  def decoder(%{name: name, type: type, required: true, nilable: true}) do
    decoder = decoder(name, type)

    if decoder == quote(do: &Function.identity/1) do
      nil
    else
      quote do
        Map.update!(unquote(name), Schema.nilable(unquote(decoder)))
      end
    end
  end

  def decoder(name, type_ast)

  def decoder(:created_at, {:binary, _, _}), do: quote(do: &TwitterDateTime.decode!/1)
  def decoder(:bounding_box, _), do: quote(do: &BoundingBox.decode!/1)

  def decoder(name, {:list, _, [type]}) do
    quote do
      fn v ->
        Enum.map(v, unquote(decoder(name, type)))
      end
    end
  end

  def decoder(name, {{:., _, [{:__aliases__, _, _} = mod, :t]}, _, []}) do
    quote(do: &unquote(mod).decode!/1)
  end

  def decoder(name, type) do
    quote(do: &Function.identity/1)
  end
end

defmodule Tw.V1_1.Schema do
  import Tw.V1_1.Schema.ModelField, only: :macros
  alias Tw.V1_1.Schema.ModelField
  alias Tw.V1_1.Schema.Type
  alias Tw.V1_1.Schema.Endpoint

  def fetch(["model", "tweet"]), do: fetch_tweet_object()
  def fetch(["model", "user"]), do: fetch_user_object()
  def fetch(["model", "geo"]), do: fetch_geo_objects()
  def fetch(["model", "entities"]), do: fetch_entities_objects()
  def fetch(["model", "endpoint_results"]), do: generate_endpoint_result_objects()

  def fetch(["endpoint", "GET statuses/oembed" = name, func_name]) do
    endpoints = fetch_endpoint_index()
    url = endpoints[name]
    type = Endpoint.return_type(name)

    {:ok, html} =
      Req.get!(url)
      |> Map.fetch!(:body)
      |> Floki.parse_document()

    ts = tables(html, h_levels: [2])

    parameters =
      ts["Parameters"]
      |> Enum.map(fn param ->
        [name, type] = param["name"] |> String.split("\n")
        required = String.ends_with?(name, "required")
        name = String.trim_trailing(name, "required") |> String.to_atom()

        %{
          name: name,
          type: Type.from_twitter(name, type),
          required: required,
          description: param["description"],
          example: param["example"]
        }
      end)

    schema = %{
      doc_url: url,
      type: type,
      description: main_paragraph(html),
      parameters: parameters
    }

    schema
    |> endpoint_code_gen(func_name)
    |> IO.puts()
  end

  def fetch(["endpoint", endpoint, func_name]) do
    endpoints = fetch_endpoint_index()

    case endpoints[endpoint] do
      nil ->
        IO.puts(:stderr, """
        "#{endpoint}" not found.
        Supported endpoints:
        #{endpoints |> Map.keys() |> Enum.sort() |> Enum.join("\n")}
        """)

      url ->
        type = Endpoint.return_type(endpoint)

        {:ok, html} =
          Req.get!(url)
          |> Map.fetch!(:body)
          |> Floki.parse_document()

        ts = tables(html, h_levels: [2])

        parameters =
          (ts["Parameters"] || [])
          |> Enum.map(fn param ->
            %{
              name: String.to_atom(param["name"]),
              type: Type.infer(param["name"], param["example"]),
              description: param["description"],
              example: param["example"]
            }
            |> Map.put(
              :required,
              case param["required"] do
                "required" -> true
                "optional" -> false
                "semi-optional" -> false
                _ -> false
              end
            )
          end)

        schema = %{
          doc_url: url,
          type: type,
          description: main_paragraph(html),
          parameters: parameters
        }

        schema
        |> endpoint_code_gen(func_name)
        |> IO.puts()
    end
  end

  defp fetch_tweet_object() do
    {:ok, html} =
      Req.get!("https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/tweet")
      |> Map.fetch!(:body)
      |> Floki.parse_document()

    ts = tables(html, h_levels: [3])

    []
    |> Kernel.++(
      ts["Tweet Data Dictionary"]
      |> Enum.map(&decode_model_field!(&1, required: true, nilable: true))
    )
    |> Kernel.++(
      ts["Additional Tweet attributes"]
      |> Enum.map(&decode_model_field!(&1, required: false, nilable: true))
    )
    |> Kernel.++([
      # undocumented attributes
      model_field(:contributors, list(integer()), required: false, nilable: true),
      model_field(:display_text_range, list(integer()), required: false, nilable: true),
      model_field(:full_text, binary(), required: false, nilable: true),
      model_field(:possibly_sensitive_appealable, boolean(), required: false, nilable: true),
      model_field(:quoted_status_permalink, map(), required: false, nilable: true)
    ])
    |> model_code_gen("tweet")
  end

  def nilable(decoder_fn), do: fn v -> v && decoder_fn.(v) end

  defp fetch_user_object() do
    {:ok, html} =
      Req.get!("https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/user")
      |> Map.fetch!(:body)
      |> Floki.parse_document()

    ts = tables(html, h_levels: [3])

    ts["User Data Dictionary"]
    |> Enum.map(&decode_model_field!(&1, required: true, nilable: true))
    |> Kernel.++([
      model_field(:entities, UserEntities.t(), required: true, nilable: false)
    ])
    |> model_code_gen("user")

    # https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/manage-account-settings/api-reference/get-account-verify_credentials
    ts["User Data Dictionary"]
    |> Enum.map(&decode_model_field!(&1, required: true, nilable: true))
    |> Kernel.++([
      model_field(:entities, UserEntities.t(), required: true, nilable: false),
      model_field(:show_all_inline_media, boolean(),
        required: true,
        nilable: false
      ),
      model_field(:status, Tweet.t(), required: true, nilable: true),
      model_field(:email, binary(), required: false, nilable: true)
    ])
    |> model_code_gen("me")

    # undocumented object
    [
      model_field(:description, Entities.t(), required: true, nilable: false),
      model_field(:url, Entities.t(), required: false, nilable: false)
    ]
    |> model_code_gen("user_entities")
  end

  defp fetch_geo_objects() do
    {:ok, html} =
      Req.get!("https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/geo")
      |> Map.fetch!(:body)
      |> Floki.parse_document()

    ts = tables(html, h_levels: [2, 3])

    ts["Place data dictionary"]
    |> Enum.map(&decode_model_field!(&1, required: true, nilable: true))
    |> model_code_gen("place")

    ts["Coordinates object data dictionary"]
    |> Enum.map(&decode_model_field!(&1, required: true, nilable: true))
    |> model_code_gen("coordinates")

    ts["Bounding box"]
    |> Enum.map(&decode_model_field!(&1, required: true, nilable: true))
    |> model_code_gen("bounding_box")
  end

  defp fetch_entities_objects() do
    {:ok, html} =
      Req.get!("https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/entities")
      |> Map.fetch!(:body)
      |> Floki.parse_document()

    ts = tables(html, h_levels: [3, 4])

    ts["Entities data dictionary"]
    |> Enum.map(&decode_model_field!(&1, required: true, nilable: true))
    |> model_code_gen("entities")

    # Extended Entities
    # https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/extended-entities
    [
      model_field(:media, "Array of Media Objects", required: true, nilable: true)
    ]
    |> model_code_gen("extended_entities")

    ts["Hashtag object"]
    |> Enum.map(&decode_model_field!(&1, required: true, nilable: true))
    |> model_code_gen("hashtag")

    ts["Media object"]
    |> Enum.map(&decode_model_field!(&1, required: true, nilable: true))
    |> model_code_gen("media")

    ts["Sizes object"]
    |> Enum.map(&decode_model_field!(&1, required: true, nilable: true))
    |> model_code_gen("sizes")

    ts["Size object"]
    |> Enum.map(&decode_model_field!(&1, required: true, nilable: true))
    |> model_code_gen("size")

    ts["URL object"]
    |> Enum.map(&decode_model_field!(&1, required: true, nilable: true))
    |> model_code_gen("url")

    ts["User mention object"]
    |> Enum.map(&decode_model_field!(&1, required: true, nilable: true))
    |> model_code_gen("user_mention")

    ts["Symbol object"]
    |> Enum.map(&decode_model_field!(&1, required: true, nilable: true))
    |> model_code_gen("symbol")

    ts["Poll object"]
    |> Enum.map(&decode_model_field!(&1, required: true, nilable: true))
    |> model_code_gen("poll")
  end

  defp generate_endpoint_result_objects do
    [
      model_field(:statuses, list(Tweet.t()), required: true, nilable: false),
      model_field(:search_metadata, SearchMetadata.t(),
        required: true,
        nilable: false
      )
    ]
    |> model_code_gen("search_result")

    [
      model_field(:completed_in, float(), required: true, nilable: false),
      model_field(:max_id, integer(), required: true, nilable: false),
      model_field(:max_id_str, binary(), required: true, nilable: false),
      model_field(:next_results, binary(), required: true, nilable: false),
      model_field(:query, binary(), required: true, nilable: false),
      model_field(:count, integer(), required: true, nilable: false),
      model_field(:since_id, integer(), required: true, nilable: false),
      model_field(:since_id_str, binary(), required: true, nilable: false)
    ]
    |> model_code_gen("search_metadata")

    [
      model_field(:name, binary(), required: true, nilable: false),
      model_field(:screen_name, binary(), required: true, nilable: false),
      model_field(:id, integer(), required: true, nilable: false),
      model_field(:id_str, binary(), required: true, nilable: false),
      model_field(:connections, FriendshipLookupResult.connections(),
        required: true,
        nilable: false
      )
    ]
    |> model_code_gen("friendship_lookup_result")

    [
      model_field(:source, FriendshipSource.t(), required: true, nilable: false),
      model_field(:target, FriendshipTarget.t(), required: true, nilable: false)
    ]
    |> model_code_gen("friendship_relationship")

    [
      model_field(:id, integer(), required: true, nilable: false),
      model_field(:id_str, binary(), required: true, nilable: false),
      model_field(:screen_name, binary(), required: true, nilable: false),
      model_field(:following, boolean(), required: true, nilable: false),
      model_field(:followed_by, boolean(), required: true, nilable: false),
      model_field(:live_following, boolean(), required: true, nilable: false),
      model_field(:following_received, boolean(), required: true, nilable: true),
      model_field(:following_requested, boolean(), required: true, nilable: true),
      model_field(:notifications_enabled, boolean(),
        required: true,
        nilable: true
      ),
      model_field(:can_dm, boolean(), required: true, nilable: false),
      model_field(:blocking, boolean(), required: true, nilable: true),
      model_field(:blocked_by, boolean(), required: true, nilable: true),
      model_field(:muting, boolean(), required: true, nilable: true),
      model_field(:want_retweets, boolean(), required: true, nilable: true),
      model_field(:all_replies, boolean(), required: true, nilable: true),
      model_field(:marked_spam, boolean(), required: true, nilable: true)
    ]
    |> model_code_gen("friendship_source")

    [
      model_field(:id, integer(), required: true, nilable: false),
      model_field(:id_str, binary(), required: true, nilable: false),
      model_field(:screen_name, binary(), required: true, nilable: false),
      model_field(:following, boolean(), required: true, nilable: false),
      model_field(:followed_by, boolean(), required: true, nilable: false),
      model_field(:following_received, boolean(), required: true, nilable: true),
      model_field(:following_requested, boolean(), required: true, nilable: true)
    ]
    |> model_code_gen("friendship_target")

    [
      model_field(:country, binary(), required: true, nilable: false),
      model_field(:countryCode, binary(), required: true, nilable: false),
      model_field(:name, binary(), required: true, nilable: false),
      model_field(:parentid, integer(), required: true, nilable: false),
      model_field(:placeType, %{code: non_neg_integer, name: binary}, required: true, nilable: false),
      model_field(:url, binary(), required: true, nilable: false),
      model_field(:woeid, integer(), required: true, nilable: false)
    ]
    |> model_code_gen("trend_location")

    [
      model_field(:name, binary(), required: true, nilable: false),
      model_field(:url, binary(), required: true, nilable: false),
      model_field(:promoted_content, boolean(), required: true, nilable: true),
      model_field(:query, binary(), required: true, nilable: false),
      model_field(:tweet_volume, integer(), required: true, nilable: true)
    ]
    |> model_code_gen("trend")
  end

  defp tables(html, h_levels: levels) do
    h = levels |> Enum.map(fn level -> "h#{level}" end) |> Enum.join(",")

    Floki.find(html, "#{h}, table")
    |> Enum.reverse()
    |> Enum.reduce([], fn
      {"table", _, _} = table, [] ->
        [{to_map(table)}]

      {"table", _, _} = table, [{_, _} | _] = acc ->
        [{to_map(table)} | acc]

      {"table", _, _} = table, [{_} | tail] ->
        [{to_map(table)} | tail]

      {"h" <> _, _, _} = heading, [{fields} | tail] ->
        [{Floki.text(heading) |> String.trim() |> String.trim("¶"), fields} | tail]

      _, acc ->
        acc
    end)
    |> Map.new()
  end

  defp main_paragraph(html) do
    Floki.find(html, "h1 ~ *")
    |> Enum.take_while(fn
      {"h2", _, _} -> false
      _ -> true
    end)
    |> Enum.map(&Floki.text/1)
    |> Enum.reject(&(String.trim(&1) == ""))
    |> Enum.join("\n\n")
  end

  defp to_map(table) do
    {keys, rows} =
      case table |> Floki.find("th") do
        [] ->
          keys = table |> Floki.find("tr:first-child td") |> Enum.map(&Floki.text/1)

          rows =
            table
            |> Floki.find("tr:not(:first-child) td")
            |> Enum.map(&Floki.text/1)
            |> Enum.chunk_every(length(keys))

          {keys, rows}

        ths ->
          keys = ths |> Enum.map(&Floki.text/1)

          rows =
            table
            |> Floki.find("td")
            |> Enum.map(&Floki.text/1)
            |> Enum.chunk_every(length(keys))

          {keys, rows}
      end

    keys =
      keys
      |> Enum.map(&String.downcase/1)
      |> Enum.map(&String.trim/1)
      |> Enum.map(fn
        "field" -> "attribute"
        e -> e
      end)

    rows
    |> Enum.map(fn values ->
      Enum.zip(keys, values)
      |> Map.new()
    end)
  end

  defp inspect_elems(html) do
    html
    |> Enum.map(fn
      {"h" <> _, _, _} = tree -> Floki.text(tree)
      {el, _, _} -> el
    end)
    |> IO.inspect()

    html
  end

  def fetch_endpoint_index() do
    {:ok, html} =
      Req.get!("https://developer.twitter.com/en/docs/api-reference-index#twitter-api-standard")
      |> Map.fetch!(:body)
      |> Floki.parse_document()

    Floki.find(html, "a")
    |> Enum.filter(&match?(["https://developer.twitter.com/en/docs/twitter-api/v1/" <> _], Floki.attribute(&1, "href")))
    |> Enum.map(fn e ->
      [url] = Floki.attribute(e, "href")
      {Floki.text(e), url}
    end)
    |> Map.new()
  end

  defp model_code_gen(schema, name) do
    model_code_ast(schema, name)
    |> Macro.to_string(fn
      str, original_string when is_binary(str) ->
        if String.contains?(str, "\n") do
          res =
            original_string
            |> String.trim(~S["])
            |> String.replace("\\n", "\n")

          ~s["""
          #{res}
          """]
        else
          original_string
        end

      {:def, _, _}, string ->
        string
        |> String.replace("def(decode!(json))", "def decode!(json)")

      _ast, string ->
        string
    end)
    |> String.trim_leading("(")
    |> String.trim_trailing(")")
    |> then(fn module_code ->
      IO.puts("\n\n" <> module_code)
    end)
  end

  defp model_code_ast(schema, name) do
    module_name = {:__aliases__, [alias: false], [:Tw, :V1_1, name |> Macro.camelize() |> String.to_atom()]}

    quote do
      defmodule unquote(module_name) do
        @enforce_keys unquote(required_fields(schema))
        defstruct unquote(fields(schema))

        @typedoc unquote(schema |> field_type_table() |> cite())
        @type t :: %__MODULE__{unquote_splicing(struct_field_types(schema))}

        @spec decode!(map) :: t
        @doc """
        Decode JSON-decoded map into `t:t/0`
        """
        def decode!(json) do
          json = unquote(decode_fields(schema))

          struct(__MODULE__, json)
        end
      end
    end
  end

  defp endpoint_code_gen(schema, fn_name) do
    [method, suff] =
      schema.doc_url
      |> Path.basename()
      |> String.split("-", parts: 2)

    method = String.to_atom(method)
    path = "/" <> String.replace(suff, "-", "/") <> ".json"

    endpoint_code_ast(schema, method, path, fn_name)
    |> Macro.to_string(fn
      str, original_string when is_binary(str) ->
        if String.contains?(str, "\n") do
          res =
            original_string
            |> String.trim(~S["])
            |> String.replace("\\n", "\n")

          ~s["""
        #{res}
        """]
        else
          original_string
        end

      {:def, _, _}, string ->
        string
        |> String.replace(~r/def\((.*?)\) do/, "def \\g{1} do")
        |> String.replace(~r/with\((.*?)\) do/, "with \\g{1} do")

      _ast, string ->
        string
    end)
    |> String.replace(~r/@endpoint\("(.*?)"\)/, """
    ##################################
    # \\g{1}
    ##################################
    """)
    |> String.trim_leading("(")
    |> String.trim_trailing(")")
  end

  defp endpoint_code_ast(schema, method, path, fn_name) do
    raw_fn_name = {String.to_atom(fn_name), [], Elixir}
    params_type_name = :"#{fn_name}_params"

    endpoint = "#{method |> to_string() |> String.upcase()} #{path}"

    typedoc = """
    Parameters for `#{fn_name}/3`.

    #{cite(params_type_table(schema))}

    See [the Twitter API documentation](#{schema.doc_url}) for details.
    """

    doc = """
    Request `#{endpoint}` and return decoded result.
    #{cite(schema.description)}

    See [the Twitter API documentation](#{schema.doc_url}) for details.
    """

    func =
      case Type.decoder(schema.type) do
        quote(do: Function.identity()) ->
          quote do
            def unquote(raw_fn_name)(client, params) do
              Client.request(client, unquote(method), unquote(path), params)
            end
          end

        decs when is_list(decs) ->
          res =
            decs
            |> Enum.reduce(quote(do: json), fn e, a ->
              quote(do: unquote(a) |> unquote(e))
            end)

          quote do
            def unquote(raw_fn_name)(client, params) do
              with {:ok, json} <- Client.request(client, unquote(method), unquote(path), params) do
                res = unquote(res)

                {:ok, res}
              end
            end
          end

        decode ->
          quote do
            def unquote(raw_fn_name)(client, params) do
              with {:ok, json} <- Client.request(client, unquote(method), unquote(path), params) do
                res =
                  json
                  |> unquote(decode)

                {:ok, res}
              end
            end
          end
      end

    quote do
      @endpoint unquote(endpoint)
      @typedoc unquote(typedoc)
      @type unquote({params_type_name, [], Elixir}) :: unquote(params_type(schema))

      @spec unquote(raw_fn_name)(Client.t(), unquote({params_type_name, [], Elixir})) ::
              {:ok, unquote(schema.type)} | {:error, Client.error()}
      @doc unquote(doc)
      unquote(func)
    end
  end

  defp fields(schema) do
    schema
    |> Enum.map(& &1.name)
  end

  defp required_fields(schema) do
    schema
    |> Enum.filter(& &1.required)
    |> fields()
  end

  defp struct_field_types(schema) do
    schema
    |> Enum.map(fn model_field ->
      if model_field.nilable || !model_field.required do
        {model_field.name, quote(do: unquote(model_field.type) | nil)}
      else
        {model_field.name, model_field.type}
      end
    end)
  end

  defp field_type_table(schema) do
    rows =
      schema
      |> Enum.map(fn field ->
        [
          "| `",
          field.name |> Atom.to_string(),
          "` | ",
          (format_description(field) || " - ") |> String.replace("\n", " "),
          " |\n"
        ]
      end)

    [
      "| field | description |\n",
      "| - | - |\n"
      | rows
    ]
    |> IO.iodata_to_binary()
  end

  defp decode_fields(schema) do
    schema
    |> Enum.map(&ModelField.decoder/1)
    |> Enum.reject(&is_nil/1)
    |> Enum.reduce(quote(do: json), fn q, a ->
      quote do
        unquote(a)
        |> unquote(q)
      end
    end)
  end

  defp format_description(model_field) do
    case model_field.description do
      nil ->
        nil

      description ->
        if model_field.type |> twitter_type?() do
          Regex.replace(~r/Example:?\s*(?:.|\n)*?(?=Note:|\z)/m, description, "")
        else
          Regex.replace(~r/Example:\s*((?:.|\n)*?)(?=Note:|\z)/m, description, fn _, x ->
            x = String.replace(x, ~r/\s*"#{model_field.name}"\s*:\s*/, "")
            "Example: `#{x}`. "
          end)
        end
    end
  end

  defp format_description(_), do: nil

  defp twitter_type?(ast) do
    ast
    |> Macro.traverse(
      false,
      fn
        {_, _, [:Tw | _]} = ast, _acc -> {ast, true}
        ast, acc -> {ast, acc}
      end,
      fn
        {_, _, [:Tw | _]} = ast, _acc -> {ast, true}
        ast, acc -> {ast, acc}
      end
    )
    |> elem(1)
  end

  defp params_type(schema) do
    kvs =
      schema.parameters
      |> Enum.map(fn
        %{name: name, type: type, required: true} ->
          {{:required, [], [name]}, type}

        %{name: name, type: type} ->
          {{:optional, [], [name]}, type}
      end)

    {:%{}, [], kvs}
  end

  defp params_type_table(schema) do
    rows =
      schema.parameters
      |> Enum.map(fn
        %{name: name, description: description} ->
          ["|", Atom.to_string(name), " | ", description, " | \n"]
      end)

    [
      "| name | description |\n",
      "| - | - |\n",
      rows
    ]
    |> IO.iodata_to_binary()
  end

  defp cite(text) do
    "> " <> String.replace(text, "\n", "\n> ")
  end

  def decode_model_field!(%{"attribute" => name, "type" => type, "required" => required, "nullable" => nilable} = field) do
    ModelField.new(
      String.to_atom(name),
      Type.from_twitter(name, type),
      description: field["description"],
      required: required,
      nilable: nilable
    )
  end

  def decode_model_field!(%{"attribute" => name, "type" => type} = field, required: required, nilable: nilable) do
    ModelField.new(
      String.to_atom(name),
      Type.from_twitter(name, type),
      description: field["description"],
      required: required,
      nilable: nilable
    )
  end
end

Tw.V1_1.Schema.fetch(System.argv())
