Mix.install([
  {:floki, "~> 0.32"},
  {:req, "~> 0.2.0"}
])

defmodule Tw.V1_1.Schema do
  def fetch do
    endpoints = File.read!("priv/schema/endpoint/index.json") |> Jason.decode!()

    files =
      [
        # &generate_endpoint_result_objects/0,
        # &fetch_tweet_object/0,
        &fetch_user_object/0,
        # &fetch_geo_objects/0,
        # &fetch_entities_objects/0,
        # fetch_endpoint(endpoints, "GET statuses/home_timeline"),
        # fetch_endpoint(endpoints, "GET statuses/user_timeline"),
        # fetch_endpoint(endpoints, "GET statuses/mentions_timeline"),
        # fetch_endpoint(endpoints, "Standard search API"),
        # fetch_endpoint(endpoints, "GET users/show"),
        # fetch_endpoint(endpoints, "GET followers/ids"),
        # fetch_endpoint(endpoints, "GET friends/ids"),
        # fetch_endpoint(endpoints, "GET followers/list"),
        # fetch_endpoint(endpoints, "GET friends/list"),
        # fetch_endpoint(endpoints, "GET friendships/incoming"),
        # fetch_endpoint(endpoints, "GET friendships/outgoing"),
        # fetch_endpoint(endpoints, "GET friendships/no_retweets/ids"),
        # fetch_endpoint(endpoints, "GET friendships/lookup"),
        # fetch_endpoint(endpoints, "GET friendships/show"),
        # fetch_endpoint(endpoints, "GET users/lookup"),
        # fetch_endpoint(endpoints, "GET users/search"),
        # fetch_endpoint(endpoints, "GET account/verify_credentials"),
        # fetch_endpoint(endpoints, "GET blocks/ids"),
        # fetch_endpoint(endpoints, "GET mutes/users/ids"),
        # fetch_endpoint(endpoints, "GET statuses/retweeters/ids"),
        # fetch_endpoint(endpoints, "GET blocks/list"),
        # fetch_endpoint(endpoints, "GET mutes/users/list"),
        # fetch_endpoint(endpoints, "GET lists/members"),
        # fetch_endpoint(endpoints, "GET lists/subscribers"),
        # fetch_endpoint(endpoints, "GET favorites/list"),
        # fetch_endpoint(endpoints, "GET lists/statuses"),
        # fetch_endpoint(endpoints, "GET statuses/lookup"),
        # fetch_endpoint(endpoints, "GET statuses/retweets_of_me"),
        # fetch_endpoint(endpoints, "GET statuses/retweets/:id"),
        # fetch_endpoint(endpoints, "GET statuses/show/:id"),
        # fetch_oembed_endpoint(endpoints, "GET statuses/oembed"),
        # fetch_endpoint(endpoints, "GET trends/closest"),
        # fetch_endpoint(endpoints, "GET trends/available"),
        # fetch_endpoint(endpoints, "GET trends/place"),
        # fetch_endpoint(endpoints, "POST statuses/update"),
        # fetch_endpoint(endpoints, "POST statuses/destroy/:id"),
        # fetch_endpoint(endpoints, "POST statuses/retweet/:id"),
        # fetch_endpoint(endpoints, "POST statuses/unretweet/:id"),
        # fetch_endpoint(endpoints, "POST favorites/create"),
        # fetch_endpoint(endpoints, "POST favorites/destroy"),
        #fetch_endpoint(endpoints, "POST blocks/create"),
        #fetch_endpoint(endpoints, "POST blocks/destroy"),
        #fetch_endpoint(endpoints, "POST mutes/users/create"),
        #fetch_endpoint(endpoints, "POST mutes/users/destroy"),
        #fetch_endpoint(endpoints, "POST users/report_spam"),
        #fetch_endpoint(endpoints, "POST friendships/create"),
        #fetch_endpoint(endpoints, "POST friendships/destroy"),
        #fetch_endpoint(endpoints, "POST friendships/update"),
      ]
      |> Enum.map(&Task.async(&1))
      |> Task.await_many(10_000)

    IO.puts("Gnerated files below.")

    files
    |> Enum.each(&IO.puts/1)
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
      |> Enum.map(&Map.put(&1, "required", true))
      |> Enum.map(&put_nullable/1)
    )
    |> Kernel.++(
      ts["Additional Tweet attributes"]
      |> Enum.map(&Map.put(&1, "required", false))
      |> Enum.map(&put_nullable/1)
    )
    |> Kernel.++([
      # undocumented attributes
      %{"attribute" => "contributors", "type" => "Array of Int", "required" => false, "nullable" => true},
      %{"attribute" => "display_text_range", "type" => "Array of Int", "required" => false, "nullable" => true},
      %{"attribute" => "full_text", "type" => "String", "required" => false, "nullable" => true},
      %{"attribute" => "possibly_sensitive_appealable", "type" => "Boolean", "required" => false, "nullable" => true},
      %{"attribute" => "quoted_status_permalink", "type" => "Object", "required" => false, "nullable" => true}
    ])
    |> model_code_gen("tweet")
  end

  defp fetch_user_object() do
    {:ok, html} =
      Req.get!("https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/user")
      |> Map.fetch!(:body)
      |> Floki.parse_document()

    ts = tables(html, h_levels: [3])

    []
    |> Kernel.++(
      ts["User Data Dictionary"]
      |> Enum.map(&Map.put(&1, "required", true))
      |> Enum.map(&put_nullable/1)
      |> Kernel.++([
        %{"attribute" => "entities", "type" => "User Entities", "required" => true, "nullable" => false}
      ])
      |> model_code_gen("user")
    )
    |> Kernel.++(
      # https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/manage-account-settings/api-reference/get-account-verify_credentials
      ts["User Data Dictionary"]
      |> Enum.map(&Map.put(&1, "required", true))
      |> Enum.map(&put_nullable/1)
      |> Kernel.++([
        %{"attribute" => "entities", "type" => "User Entities", "required" => true, "nullable" => false},
        %{"attribute" => "show_all_inline_media", "type" => "Boolean", "required" => true, "nullable" => false},
        %{"attribute" => "status", "type" => "Tweet", "required" => true, "nullable" => true},
        %{"attribute" => "email", "type" => "String", "required" => false, "nullable" => true},
      ])
      |> model_code_gen("me")
    )
    |> Kernel.++(
      # undocumented object
      [
        %{"attribute" => "description", "type" => "Entities", "required" => true, "nullable" => false},
        %{"attribute" => "url", "type" => "Entities", "required" => false, "nullable" => false}
      ]
      |> model_code_gen("user_entities")
    )
  end

  defp fetch_geo_objects() do
    {:ok, html} =
      Req.get!("https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/geo")
      |> Map.fetch!(:body)
      |> Floki.parse_document()

    ts = tables(html, h_levels: [2, 3])

    []
    |> Kernel.++(
      ts["Place data dictionary"]
      |> Enum.map(&Map.put(&1, "required", true))
      |> Enum.map(&put_nullable/1)
      |> model_code_gen("place")
    )
    |> Kernel.++(
      ts["Coordinates object data dictionary"]
      |> Enum.map(&Map.put(&1, "required", true))
      |> Enum.map(&put_nullable/1)
      |> model_code_gen("coordinates")
    )
    |> Kernel.++(
      ts["Bounding box"]
      |> Enum.map(&Map.put(&1, "required", true))
      |> Enum.map(&put_nullable/1)
      |> model_code_gen("bounding_box")
    )
  end

  defp fetch_entities_objects() do
    {:ok, html} =
      Req.get!("https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/entities")
      |> Map.fetch!(:body)
      |> Floki.parse_document()

    ts = tables(html, h_levels: [3, 4])

    []
    |> Kernel.++(
      ts["Entities data dictionary"]
      |> Enum.map(&Map.put(&1, "required", true))
      |> Enum.map(&put_nullable/1)
      |> model_code_gen("entities")
    )
    |> Kernel.++(
      # Extended Entities
      # https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/extended-entities
      [
        %{"attribute" => "media", "type" => "Array of Media Objects", "required" => true, "nullable" => true}
      ]
      |> model_code_gen("extended_entities")
    )
    |> Kernel.++(
      ts["Hashtag object"]
      |> Enum.map(&Map.put(&1, "required", true))
      |> Enum.map(&put_nullable/1)
      |> model_code_gen("hashtag")
    )
    |> Kernel.++(
      ts["Media object"]
      |> Enum.map(&Map.put(&1, "required", true))
      |> Enum.map(&put_nullable/1)
      |> model_code_gen("media")
    )
    |> Kernel.++(
      ts["Sizes object"]
      |> Enum.map(&Map.put(&1, "required", true))
      |> Enum.map(&put_nullable/1)
      |> model_code_gen("sizes")
    )
    |> Kernel.++(
      ts["Size object"]
      |> Enum.map(&Map.put(&1, "required", true))
      |> Enum.map(&put_nullable/1)
      |> model_code_gen("size")
    )
    |> Kernel.++(
      ts["URL object"]
      |> Enum.map(&Map.put(&1, "required", true))
      |> Enum.map(&put_nullable/1)
      |> model_code_gen("url")
    )
    |> Kernel.++(
      ts["User mention object"]
      |> Enum.map(&Map.put(&1, "required", true))
      |> Enum.map(&put_nullable/1)
      |> model_code_gen("user_mention")
    )
    |> Kernel.++(
      ts["Symbol object"]
      |> Enum.map(&Map.put(&1, "required", true))
      |> Enum.map(&put_nullable/1)
      |> model_code_gen("symbol")
    )
    |> Kernel.++(
      ts["Poll object"]
      |> Enum.map(&Map.put(&1, "required", true))
      |> Enum.map(&put_nullable/1)
      |> model_code_gen("poll")
    )
  end

  defp generate_endpoint_result_objects do
    []
    |> Kernel.++(
      [
        %{"attribute" => "statuses", "type" => "Array of Tweets", "required" => true, "nullable" => false},
        %{"attribute" => "search_metadata", "type" => "Search Metadata Object", "required" => true, "nullable" => false},
      ]
      |> model_code_gen("search_result")
    )
    |> Kernel.++(
      [
        %{"attribute" => "completed_in", "type" => "Float", "required" => true, "nullable" => false},
        %{"attribute" => "max_id", "type" => "Int", "required" => true, "nullable" => false},
        %{"attribute" => "max_id_str", "type" => "String", "required" => true, "nullable" => false},
        %{"attribute" => "next_results", "type" => "String", "required" => true, "nullable" => false},
        %{"attribute" => "query", "type" => "String", "required" => true, "nullable" => false},
        %{"attribute" => "count", "type" => "Int", "required" => true, "nullable" => false},
        %{"attribute" => "since_id", "type" => "Int", "required" => true, "nullable" => false},
        %{"attribute" => "since_id_str", "type" => "String", "required" => true, "nullable" => false},
      ]
      |> model_code_gen("search_metadata")
    )
    |> Kernel.++(
      [
        %{"attribute" => "name", "type" => "String", "required" => true, "nullable" => false},
        %{"attribute" => "screen_name", "type" => "String", "required" => true, "nullable" => false},
        %{"attribute" => "id", "type" => "Int", "required" => true, "nullable" => false},
        %{"attribute" => "id_str", "type" => "String", "required" => true, "nullable" => false},
        %{"attribute" => "connections", "type" => "Array of Connection Enum", "required" => true, "nullable" => false},
      ]
      |> model_code_gen("friendship_lookup_result")
    )
    |> Kernel.++(
      [
        %{"attribute" => "source", "type" => "Friendship Source Object", "required" => true, "nullable" => false},
        %{"attribute" => "target", "type" => "Friendship Target Object", "required" => true, "nullable" => false},
      ]
      |> model_code_gen("friendship_relationship")
    )
    |> Kernel.++(
      [
        %{"attribute" => "id", "type" => "Int", "required" => true, "nullable" => false},
        %{"attribute" => "id_str", "type" => "String", "required" => true, "nullable" => false},
        %{"attribute" => "screen_name", "type" => "String", "required" => true, "nullable" => false},
        %{"attribute" => "following", "type" => "Boolean", "required" => true, "nullable" => false},
        %{"attribute" => "followed_by", "type" => "Boolean", "required" => true, "nullable" => false},
        %{"attribute" => "live_following", "type" => "Boolean", "required" => true, "nullable" => false},
        %{"attribute" => "following_received", "type" => "Boolean", "required" => true, "nullable" => true},
        %{"attribute" => "following_requested", "type" => "Boolean", "required" => true, "nullable" => true},
        %{"attribute" => "notifications_enabled", "type" => "Boolean", "required" => true, "nullable" => true},
        %{"attribute" => "can_dm", "type" => "Boolean", "required" => true, "nullable" => false},
        %{"attribute" => "blocking", "type" => "Boolean", "required" => true, "nullable" => true},
        %{"attribute" => "blocked_by", "type" => "Boolean", "required" => true, "nullable" => true},
        %{"attribute" => "muting", "type" => "Boolean", "required" => true, "nullable" => true},
        %{"attribute" => "want_retweets", "type" => "Boolean", "required" => true, "nullable" => true},
        %{"attribute" => "all_replies", "type" => "Boolean", "required" => true, "nullable" => true},
        %{"attribute" => "marked_spam", "type" => "Boolean", "required" => true, "nullable" => true},
      ]
      |> model_code_gen("friendship_source")
    )
    |> Kernel.++(
      [
        %{"attribute" => "id", "type" => "Int", "required" => true, "nullable" => false},
        %{"attribute" => "id_str", "type" => "String", "required" => true, "nullable" => false},
        %{"attribute" => "screen_name", "type" => "String", "required" => true, "nullable" => false},
        %{"attribute" => "following", "type" => "Boolean", "required" => true, "nullable" => false},
        %{"attribute" => "followed_by", "type" => "Boolean", "required" => true, "nullable" => false},
        %{"attribute" => "following_received", "type" => "Boolean", "required" => true, "nullable" => true},
        %{"attribute" => "following_requested", "type" => "Boolean", "required" => true, "nullable" => true},
      ]
      |> model_code_gen("friendship_target")
    )
    |> Kernel.++(
      [
        %{"attribute" => "country", "type" => "String", "required" => true, "nullable" => false},
        %{"attribute" => "countryCode", "type" => "String", "required" => true, "nullable" => false},
        %{"attribute" => "name", "type" => "String", "required" => true, "nullable" => false},
        %{"attribute" => "parentid", "type" => "Int", "required" => true, "nullable" => false},
        %{"attribute" => "placeType", "type" => "Place Type Object", "required" => true, "nullable" => false},
        %{"attribute" => "url", "type" => "String", "required" => true, "nullable" => false},
        %{"attribute" => "woeid", "type" => "Int", "required" => true, "nullable" => false},
      ]
      |> model_code_gen("trend_location")
    )
    |> Kernel.++(
      [
        %{"attribute" => "name", "type" => "String", "required" => true, "nullable" => false},
        %{"attribute" => "url", "type" => "String", "required" => true, "nullable" => false},
        %{"attribute" => "promoted_content", "type" => "Boolean", "required" => true, "nullable" => true},
        %{"attribute" => "query", "type" => "String", "required" => true, "nullable" => false},
        %{"attribute" => "tweet_volume", "type" => "Int", "required" => true, "nullable" => true},
      ]
      |> model_code_gen("trend")
    )
  end

  defp write_schema(schema, to: path) do
    json = schema |> Jason.encode!(pretty: true)

    :ok = File.write(path, json)
    [path]
  end

  def put_nullable(e) do
    Map.put(e, "nullable", String.contains?(e["description"], "Nullable"))
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

  defp fetch_endpoint(endpoints, name) do
    url = endpoints[name]
    type = return_type(name)

    fn ->
      {:ok, html} =
        Req.get!(url)
        |> Map.fetch!(:body)
        |> Floki.parse_document()


      ts = tables(html, h_levels: [2])

      parameters =
        (ts["Parameters"] || [])
        |> Enum.map(fn param ->
          param
          |> Map.put("type", infer_type(param["name"], param["example"]))
          |> Map.update!("required", fn
            "required" -> true
            "optional" -> false
            "semi-optional" -> false
            _ -> false
          end)
        end)

      schema = %{
        "doc_url" => url,
        "type" => type,
        "description" => main_paragraph(html),
        "parameters" => parameters
      }

      dest = Path.join(["priv/schema/endpoint", (url |> Path.basename() |> String.replace("-", "_")) <> ".json"])

      schema |> write_schema(to: dest)
    end
  end

  defp fetch_oembed_endpoint(endpoints, name) do
    url = endpoints[name]
    type = return_type(name)

    fn ->
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
          name = String.trim_trailing(name, "required")

          param
          |> Map.put("name", name)
          |> Map.put("type", type)
          |> Map.put("required", required)
        end)

      schema = %{
        "doc_url" => url,
        "type" => type,
        "description" => main_paragraph(html),
        "parameters" => parameters
      }

      dest = Path.join(["priv/schema/endpoint", (url |> Path.basename() |> String.replace("-", "_")) <> ".json"])

      schema |> write_schema(to: dest)
    end
  end

  def fetch_endpoint_index() do
    {:ok, html} =
      Req.get!("https://developer.twitter.com/en/docs/api-reference-index#twitter-api-standard")
      |> Map.fetch!(:body)
      |> Floki.parse_document()

    Floki.find(html, "a")
    |> Enum.filter(&match?(["https://developer.twitter.com/en/docs/twitter-api/v1/"<>_], Floki.attribute(&1, "href")))
    |> Enum.map(fn e ->
      [url] = Floki.attribute(e, "href")
      {Floki.text(e), url}
    end)
    |> Map.new()
    |> write_schema(to: "priv/schema/endpoint/index.json")
  end

  defp infer_type(name, example)
  defp infer_type(_name, "true"), do: "Boolean"
  defp infer_type(_name, "false"), do: "Boolean"
  defp infer_type("count", _), do: "Int"
  defp infer_type("screen_name", "twitterapi twitter"), do: "Array of Strings"
  defp infer_type("user_id", "783214 6253282"), do: "Array of Int"
  defp infer_type("id", "20 1050118621198921728"), do: "Array of Int"

  defp infer_type(_name, example) do
    case Integer.parse(example) do
      {_, ""} -> "Int"
      _ -> "String"
    end
  end

  defp return_type(endpoint) when endpoint in [
    "GET statuses/home_timeline",
    "GET statuses/user_timeline",
    "GET statuses/mentions_timeline",
    "GET favorites/list",
    "GET lists/statuses",
    "GET statuses/lookup",
    "GET statuses/retweets_of_me",
    "GET statuses/retweets/:id",
  ] do
    "Array of Tweets"
  end
  defp return_type(endpoint) when endpoint in [
    "GET users/show",
    "POST blocks/create",
    "POST blocks/destroy",
    "POST mutes/users/create",
    "POST mutes/users/destroy",
    "POST users/report_spam",
    "POST friendships/create",
    "POST friendships/destroy",
  ] do
    "User object"
  end
  defp return_type("GET users/lookup"), do: "Array of User objects"
  defp return_type("GET users/search"), do: "Array of User objects"
  defp return_type("Standard search API"), do: "Search Result Object"
  defp return_type(endpoint) when endpoint in [
    "GET followers/ids",
    "GET friends/ids",
    "GET friendships/incoming",
    "GET friendships/outgoing",
    "GET blocks/ids",
    "GET mutes/users/ids",
    "GET statuses/retweeters/ids",
  ] do
    "Cursored Result Object with ids Array of Int"
  end
  defp return_type(endpoint) when endpoint in [
    "GET followers/list",
    "GET friends/list",
    "GET blocks/list",
    "GET mutes/users/list",
    "GET lists/members",
    "GET lists/subscribers",
  ] do
    "Cursored Result Object with users Array of User objects"
  end
  defp return_type("GET friendships/no_retweets/ids"), do: "Array of Int"
  defp return_type("GET friendships/lookup"), do: "Array of Friendship Lookup Result Objects"
  defp return_type(endpoint) when endpoint in [
    "GET friendships/show",
    "POST friendships/update",
  ] do
    "Friendship Relationship Object"
  end
  defp return_type("GET account/verify_credentials"), do: "Me Object"
  defp return_type(endpoint) when endpoint in [
    "GET statuses/show/:id",
    "POST statuses/update",
    "POST statuses/destroy/:id",
    "POST statuses/retweet/:id",
    "POST statuses/unretweet/:id",
    "POST favorites/create",
    "POST favorites/destroy",
  ] do
    "Tweet"
  end
  defp return_type("GET statuses/oembed"), do: "oEmbed Object"
  defp return_type(endpoint) when endpoint in [
    "GET trends/closest",
    "GET trends/available"
  ] do
    "Array of Trend Location Objects"
  end
  defp return_type("GET trends/place"), do: "Array of Trends Objects"

  defp model_code_gen(schema, name) do
    module_code =
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

    IO.puts("\n\n" <> module_code)

    [name]
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

  defp fields(schema) do
    schema
    |> Enum.map(&String.to_atom(&1["attribute"]))
  end

  defp required_fields(schema) do
    schema
    |> Enum.filter(& &1["required"])
    |> Enum.map(&String.to_atom(&1["attribute"]))
  end

  defp struct_field_types(schema) do
    schema
    |> Enum.map(fn e ->
      {String.to_atom(e["attribute"]), to_ex_type(e["attribute"], e["type"], e["nullable"] || !e["required"])}
    end)
  end

  defp field_type_table(schema) do
    rows =
      schema
      |> Enum.map(fn e ->
        [
          "| `",
          e["attribute"],
          "` | ",
          (format_description(e) || " - ") |> String.replace("\n", " "),
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
    |> Enum.map(fn e ->
      field_decoder(e["attribute"], e["type"], e["required"], e["nullable"])
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.reduce(quote(do: json), fn q, a ->
      quote do
        unquote(a)
        |> unquote(q)
      end
    end)
  end

  defp to_ex_type("created_at", "String"), do: quote(do: DateTime.t())
  defp to_ex_type("bounding_box", "Object"), do: quote(do: Tw.V1_1.BoundingBox.t())

  defp to_ex_type(name, "Array of " <> t),
    do: quote(do: list(unquote(to_ex_type(name, t |> String.trim_trailing("s")))))

  defp to_ex_type(name, "Collection of " <> t),
    do: quote(do: list(unquote(to_ex_type(name, t |> String.trim_trailing("s")))))

  defp to_ex_type(_name, "String"), do: quote(do: binary)
  defp to_ex_type(_name, "Int64"), do: quote(do: integer)
  defp to_ex_type(_name, "Integer"), do: quote(do: integer)
  defp to_ex_type(_name, "Int"), do: quote(do: integer)
  defp to_ex_type(_name, "Boolean"), do: quote(do: boolean)
  defp to_ex_type(_name, "Float"), do: quote(do: float)
  defp to_ex_type(_name, "User object"), do: quote(do: Tw.V1_1.User.t())
  defp to_ex_type(_name, "Me Object"), do: quote(do: Tw.V1_1.Me.t())
  defp to_ex_type(_name, "Tweet"), do: quote(do: Tw.V1_1.Tweet.t())
  defp to_ex_type(_name, "Object"), do: quote(do: map)
  defp to_ex_type(_name, "Array of String"), do: quote(do: list(binary))
  defp to_ex_type(_name, "Coordinates"), do: quote(do: Tw.V1_1.Coordinates.t())
  defp to_ex_type(_name, "Places"), do: quote(do: Tw.V1_1.Place.t())
  defp to_ex_type(_name, "Entities"), do: quote(do: Tw.V1_1.Entities.t())
  defp to_ex_type(_name, "Hashtag Object"), do: quote(do: Tw.V1_1.Hashtag.t())
  defp to_ex_type(_name, "Media Object"), do: quote(do: Tw.V1_1.Media.t())
  defp to_ex_type(_name, "URL Object"), do: quote(do: Tw.V1_1.URL.t())
  defp to_ex_type(_name, "User Mention Object"), do: quote(do: Tw.V1_1.UserMention.t())
  defp to_ex_type(_name, "Symbol Object"), do: quote(do: Tw.V1_1.Symbol.t())
  defp to_ex_type(_name, "Poll Object"), do: quote(do: Tw.V1_1.Poll.t())
  defp to_ex_type("sizes", "Size Object"), do: quote(do: Tw.V1_1.Sizes.t())
  defp to_ex_type(_name, "Size Object"), do: quote(do: Tw.V1_1.Size.t())
  defp to_ex_type(_name, "Option Object"), do: quote(do: map)
  defp to_ex_type(_name, "User Entities"), do: quote(do: Tw.V1_1.UserEntities.t())
  defp to_ex_type(_name, "Extended Entities"), do: quote(do: Tw.V1_1.ExtendedEntities.t())
  defp to_ex_type(_name, "Search Result Object"), do: quote(do: Tw.V1_1.SearchResult.t())
  defp to_ex_type(_name, "Search Metadata Object"), do: quote(do: Tw.V1_1.SearchMetadata.t())
  defp to_ex_type(_name, "Friendship Lookup Result Object"), do: quote(do: Tw.V1_1.FriendshipLookupResult.t())
  defp to_ex_type(_name, "Friendship Source Object"), do: quote(do: Tw.V1_1.FriendshipSource.t())
  defp to_ex_type(_name, "Friendship Target Object"), do: quote(do: Tw.V1_1.FriendshipTarget.t())
  defp to_ex_type("maxwidth", "Int [220..550]"), do: quote(do: pos_integer)
  defp to_ex_type(_name, "Boolean, String or Int"), do: quote(do: boolean)
  defp to_ex_type(_name, "Enum {left,right,center,none}"), do: quote(do: :left | :right | :center | :none)
  defp to_ex_type(_name, "Enum(Language)"), do: quote(do: Tw.V1_1.Schema.language())
  defp to_ex_type(_name, "Enum {light, dark}"), do: quote(do: :light | :dark)
  defp to_ex_type(_name, "Enum {video}"), do: quote(do: :video)
  defp to_ex_type(_name, "Place Type Object"), do: quote(do: %{code: non_neg_integer, name: binary})
  defp to_ex_type(_name, "Trend Location Object"), do: quote(do: Tw.V1_1.TrendLocation.t())

  defp to_ex_type(_name, "Trends Object"),
    do:
      quote(
        do: %{
          trends: list(Tw.V1_1.Trend.t()),
          as_of: DateTime.t(),
          created_at: DateTime.t(),
          locations: list(%{name: binary, woeid: non_neg_integer()})
        }
      )

  defp to_ex_type(_name, "oEmbed Object"),
    do:
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

  defp to_ex_type(_name, "Friendship Relationship Object"),
    do: quote(do: %{relationship: %{source: Tw.V1_1.FriendshipSource.t(), target: Tw.V1_1.FriendshipTarget.t()}})

  defp to_ex_type(_name, "Connection Enum"),
    do: quote(do: :following | :following_requested | :followed_by | :none | :blocking | :muting)

  defp to_ex_type(_name, "Cursored Result Object with " <> kv) do
    [k, v] = String.split(kv, " ", parts: 2)

    quote do
      Tw.V1_1.CursoredResult.t(unquote(String.to_atom(k)), unquote(to_ex_type("", v)))
    end
  end

  # TODO
  defp to_ex_type(_name, "Rule Object"), do: quote(do: map)
  defp to_ex_type(_name, "Arrays of Enrichment Objects"), do: quote(do: list(map))

  defp to_ex_type(name, type, false), do: to_ex_type(name, type)

  defp to_ex_type(name, type, true) do
    quote do
      unquote(to_ex_type(name, type)) | nil
    end
  end

  @doc false
  def field_decoder(name, twitter_type, required, nilable)

  def field_decoder(name, twitter_type, false, false) do
    decoder = field_decoder(name, twitter_type)

    if decoder == quote(do: &Function.identity/1) do
      nil
    else
      quote do
        Map.update(unquote(String.to_atom(name)), nil, Tw.V1_1.Schema.nilable(unquote(decoder)))
      end
    end
  end

  def field_decoder(name, twitter_type, false, true) do
    decoder = field_decoder(name, twitter_type)

    if decoder == quote(do: &Function.identity/1) do
      nil
    else
      quote do
        Map.update(unquote(String.to_atom(name)), nil, Tw.V1_1.Schema.nilable(unquote(decoder)))
      end
    end
  end

  def field_decoder(name, twitter_type, true, false) do
    decoder = field_decoder(name, twitter_type)

    if decoder == quote(do: &Function.identity/1) do
      nil
    else
      quote do
        Map.update!(unquote(String.to_atom(name)), unquote(decoder))
      end
    end
  end

  def field_decoder(name, twitter_type, true, true) do
    decoder = field_decoder(name, twitter_type)

    if decoder == quote(do: &Function.identity/1) do
      nil
    else
      quote do
        Map.update!(unquote(String.to_atom(name)), Tw.V1_1.Schema.nilable(unquote(decoder)))
      end
    end
  end

  def field_decoder(name, twitter_type)

  def field_decoder(name, "Array of " <> twitter_type) do
    quote do
      fn v ->
        Enum.map(v, unquote(field_decoder(name, twitter_type |> String.trim_trailing("s"))))
      end
    end
  end

  def nilable(decoder_fn), do: fn v -> v && decoder_fn.(v) end

  def field_decoder("created_at", "String"), do: quote(do: &Tw.V1_1.Schema.decode_twitter_datetime!/1)
  def field_decoder("bounding_box", "Object"), do: quote(do: &Tw.V1_1.BoundingBox.decode!/1)
  def field_decoder(_name, "User object"), do: quote(do: &Tw.V1_1.User.decode!/1)
  def field_decoder(_name, "Tweet"), do: quote(do: &Tw.V1_1.Tweet.decode!/1)
  def field_decoder(_name, "Coordinates"), do: quote(do: &Tw.V1_1.Coordinates.decode!/1)
  def field_decoder(_name, "Places"), do: quote(do: &Tw.V1_1.Place.decode!/1)
  def field_decoder(_name, "Entities"), do: quote(do: &Tw.V1_1.Entities.decode!/1)
  def field_decoder(_name, "Hashtag Object"), do: quote(do: &Tw.V1_1.Hashtag.decode!/1)
  def field_decoder(_name, "Media Object"), do: quote(do: &Tw.V1_1.Media.decode!/1)
  def field_decoder(_name, "URL Object"), do: quote(do: &Tw.V1_1.URL.decode!/1)
  def field_decoder(_name, "User Mention Object"), do: quote(do: &Tw.V1_1.UserMention.decode!/1)
  def field_decoder(_name, "Symbol Object"), do: quote(do: &Tw.V1_1.Symbol.decode!/1)
  def field_decoder(_name, "Poll Object"), do: quote(do: &Tw.V1_1.Poll.decode!/1)
  def field_decoder("sizes", "Size Object"), do: quote(do: &Tw.V1_1.Sizes.decode!/1)
  def field_decoder(_name, "Size Object"), do: quote(do: &Tw.V1_1.Size.decode!/1)
  def field_decoder(_name, "User Entities"), do: quote(do: &Tw.V1_1.UserEntities.decode!/1)
  def field_decoder(_name, "Extended Entities"), do: quote(do: &Tw.V1_1.ExtendedEntities.decode!/1)
  def field_decoder(_name, "Search Metadata Object"), do: quote(do: &Tw.V1_1.SearchMetadata.decode!/1)
  def field_decoder(_name, "Friendship Source Object"), do: quote(do: &Tw.V1_1.FriendshipSource.decode!/1)
  def field_decoder(_name, "Friendship Target Object"), do: quote(do: &Tw.V1_1.FriendshipTarget.decode!/1)

  def field_decoder(_name, "Connection Enum"),
    do: quote(do: &Tw.V1_1.FriendshipLookupResult.decode_connection!/1)

  def field_decoder(_name, _type), do: quote(do: &Function.identity/1)

  defp decoder("Array of " <> twitter_type) do
    quote(do: fn x -> Enum.map(x, unquote(decoder(twitter_type |> String.trim_trailing("s")))) end)
  end

  defp decoder("Tweet"), do: quote(do: &Tw.V1_1.Tweet.decode!/1)
  defp decoder("User object"), do: quote(do: &Tw.V1_1.User.decode!/1)
  defp decoder("Me Object"), do: quote(do: &Tw.V1_1.Me.decode!/1)
  defp decoder("Search Result Object"), do: quote(do: &Tw.V1_1.SearchResult.decode!/1)
  defp decoder("Friendship Lookup Result Object"), do: quote(do: &Tw.V1_1.FriendshipLookupResult.decode!/1)
  defp decoder("Trend Location Object"), do: quote(do: &Tw.V1_1.TrendLocation.decode!/1)

  defp decoder("Cursored Result Object with " <> kv) do
    [k, v] = String.split(kv, " ", parts: 2)

    quote do
      fn json ->
        json
        |> unquote(field_decoder(k, v, true, false))
      end
    end
  end

  defp decoder("Friendship Relationship Object") do
    quote do
      fn json ->
        json
        |> Map.update!(:relationship, &Tw.V1_1.Friendship.decode!/1)
      end
    end
  end

  defp decoder("oEmbed Object") do
    quote do
      fn json -> json end
    end
  end

  defp decoder("Trends Object") do
    quote do
      fn json ->
        json
        |> Map.update!(:trends, &Tw.V1_1.Trend.decode!/1)
        |> Map.update!(:as_of, &DateTime.from_iso8601/1)
        |> Map.update!(:created_at, &DateTime.from_iso8601/1)
      end
    end
  end

  defp decoder(_), do: quote(do: &Function.identity/1)

  @spec decode_twitter_datetime!(binary) :: DateTime.t()
  @doc """
  Decode Twitter's datetime format into DateTime.

      iex> Schema.decode_twitter_datetime!("Sun Feb 13 00:28:45 +0000 2022")
      ~U[2022-02-13 00:28:45Z]

      iex> Schema.decode_twitter_datetime!("a")
      ** (RuntimeError) Parsing datetime failed: a
  """
  def decode_twitter_datetime!(str) do
    with <<_day_of_week::binary-size(4), rest::binary>> <- str,
         {month, rest} <- parse_month(rest),
         " " <> rest <- rest,
         {day, rest} <- Integer.parse(rest),
         " " <> rest <- rest,
         {hour, rest} <- Integer.parse(rest),
         ":" <> rest <- rest,
         {minute, rest} <- Integer.parse(rest),
         ":" <> rest <- rest,
         {second, rest} <- Integer.parse(rest),
         " +0000 " <> rest <- rest,
         {year, ""} <- Integer.parse(rest) do
      DateTime.new!(Date.new!(year, month + 1, day), Time.new!(hour, minute, second), "Etc/UTC")
    else
      _ -> raise "Parsing datetime failed: #{str}"
    end
  end

  for {pat, idx} <- Enum.with_index(~W[Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec]) do
    defp parse_month(unquote(pat) <> rest), do: {unquote(idx), rest}
  end

  defp format_description(%{"description" => nil}), do: nil

  defp format_description(%{"attribute" => attribute, "description" => description, "type" => type}) do
    if to_ex_type(attribute, type) |> twitter_type?() do
      Regex.replace(~r/Example:?\s*(?:.|\n)*?(?=Note:|\z)/m, description, "")
    else
      Regex.replace(~r/Example:\s*((?:.|\n)*?)(?=Note:|\z)/m, description, fn _, x ->
        x = String.replace(x, ~r/\s*"#{attribute}"\s*:\s*/, "")
        "Example: `#{x}`. "
      end)
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
      schema["parameters"]
      |> Enum.map(fn
        %{"name" => name, "type" => type, "required" => true} ->
          {{:required, [], [String.to_atom(name)]}, to_ex_type(name, type, false)}

        %{"name" => name, "type" => type} ->
          {{:optional, [], [String.to_atom(name)]}, to_ex_type(name, type, false)}
      end)

    {:%{}, [], kvs}
  end

  defp params_type_table(schema) do
    rows =
      schema["parameters"]
      |> Enum.map(fn
        %{"name" => name, "description" => description} ->
          ["|", name, " | ", description, " | \n"]
      end)

    [
      "| name | description |\n",
      "| - | - |\n"
      | rows
    ]
    |> IO.iodata_to_binary()
  end

  defp cite(text) do
    "> " <> String.replace(text, "\n", "\n> ")
  end
end

Tw.V1_1.Schema.fetch()
