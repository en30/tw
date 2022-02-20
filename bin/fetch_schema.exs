Mix.install([
  {:floki, "~> 0.32"},
  {:req, "~> 0.2.0"}
])

defmodule Tw.V1_1.Schema do
  def fetch do
    endpoints = File.read!("priv/schema/endpoint/index.json") |> Jason.decode!()

    files =
      [
        &generate_endpoint_result_objects/0,
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
        fetch_endpoint(endpoints, "POST blocks/create"),
        fetch_endpoint(endpoints, "POST blocks/destroy"),
        fetch_endpoint(endpoints, "POST mutes/users/create"),
        fetch_endpoint(endpoints, "POST mutes/users/destroy"),
        fetch_endpoint(endpoints, "POST users/report_spam"),
        fetch_endpoint(endpoints, "POST friendships/create"),
        fetch_endpoint(endpoints, "POST friendships/destroy"),
        fetch_endpoint(endpoints, "POST friendships/update"),
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
    |> write_schema(to: "priv/schema/model/tweet.json")
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
      |> write_schema(to: "priv/schema/model/user.json")
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
      |> write_schema(to: "priv/schema/model/me.json")
    )
    |> Kernel.++(
      # undocumented object
      [
        %{"attribute" => "description", "type" => "Entities", "required" => true, "nullable" => false},
        %{"attribute" => "url", "type" => "Entities", "required" => false, "nullable" => false}
      ]
      |> write_schema(to: "priv/schema/model/user_entities.json")
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
      |> write_schema(to: "priv/schema/model/place.json")
    )
    |> Kernel.++(
      ts["Coordinates object data dictionary"]
      |> Enum.map(&Map.put(&1, "required", true))
      |> Enum.map(&put_nullable/1)
      |> write_schema(to: "priv/schema/model/coordinates.json")
    )
    |> Kernel.++(
      ts["Bounding box"]
      |> Enum.map(&Map.put(&1, "required", true))
      |> Enum.map(&put_nullable/1)
      |> write_schema(to: "priv/schema/model/bounding_box.json")
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
      |> write_schema(to: "priv/schema/model/entities.json")
    )
    |> Kernel.++(
      # Extended Entities
      # https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/extended-entities
      [
        %{"attribute" => "media", "type" => "Array of Media Objects", "required" => true, "nullable" => true}
      ]
      |> write_schema(to: "priv/schema/model/extended_entities.json")
    )
    |> Kernel.++(
      ts["Hashtag object"]
      |> Enum.map(&Map.put(&1, "required", true))
      |> Enum.map(&put_nullable/1)
      |> write_schema(to: "priv/schema/model/hashtag.json")
    )
    |> Kernel.++(
      ts["Media object"]
      |> Enum.map(&Map.put(&1, "required", true))
      |> Enum.map(&put_nullable/1)
      |> write_schema(to: "priv/schema/model/media.json")
    )
    |> Kernel.++(
      ts["Sizes object"]
      |> Enum.map(&Map.put(&1, "required", true))
      |> Enum.map(&put_nullable/1)
      |> write_schema(to: "priv/schema/model/sizes.json")
    )
    |> Kernel.++(
      ts["Size object"]
      |> Enum.map(&Map.put(&1, "required", true))
      |> Enum.map(&put_nullable/1)
      |> write_schema(to: "priv/schema/model/size.json")
    )
    |> Kernel.++(
      ts["URL object"]
      |> Enum.map(&Map.put(&1, "required", true))
      |> Enum.map(&put_nullable/1)
      |> write_schema(to: "priv/schema/model/url.json")
    )
    |> Kernel.++(
      ts["User mention object"]
      |> Enum.map(&Map.put(&1, "required", true))
      |> Enum.map(&put_nullable/1)
      |> write_schema(to: "priv/schema/model/user_mention.json")
    )
    |> Kernel.++(
      ts["Symbol object"]
      |> Enum.map(&Map.put(&1, "required", true))
      |> Enum.map(&put_nullable/1)
      |> write_schema(to: "priv/schema/model/symbol.json")
    )
    |> Kernel.++(
      ts["Poll object"]
      |> Enum.map(&Map.put(&1, "required", true))
      |> Enum.map(&put_nullable/1)
      |> write_schema(to: "priv/schema/model/poll.json")
    )
  end

  defp generate_endpoint_result_objects do
    []
    |> Kernel.++(
      [
        %{"attribute" => "statuses", "type" => "Array of Tweets", "required" => true, "nullable" => false},
        %{"attribute" => "search_metadata", "type" => "Search Metadata Object", "required" => true, "nullable" => false},
      ]
      |> write_schema(to: "priv/schema/model/search_result.json")
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
      |> write_schema(to: "priv/schema/model/search_metadata.json")
    )
    |> Kernel.++(
      [
        %{"attribute" => "name", "type" => "String", "required" => true, "nullable" => false},
        %{"attribute" => "screen_name", "type" => "String", "required" => true, "nullable" => false},
        %{"attribute" => "id", "type" => "Int", "required" => true, "nullable" => false},
        %{"attribute" => "id_str", "type" => "String", "required" => true, "nullable" => false},
        %{"attribute" => "connections", "type" => "Array of Connection Enum", "required" => true, "nullable" => false},
      ]
      |> write_schema(to: "priv/schema/model/friendship_lookup_result.json")
    )
    |> Kernel.++(
      [
        %{"attribute" => "source", "type" => "Friendship Source Object", "required" => true, "nullable" => false},
        %{"attribute" => "target", "type" => "Friendship Target Object", "required" => true, "nullable" => false},
      ]
      |> write_schema(to: "priv/schema/model/friendship_relationship.json")
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
      |> write_schema(to: "priv/schema/model/friendship_source.json")
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
      |> write_schema(to: "priv/schema/model/friendship_target.json")
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
      |> write_schema(to: "priv/schema/model/trend_location.json")
    )
    |> Kernel.++(
      [
        %{"attribute" => "name", "type" => "String", "required" => true, "nullable" => false},
        %{"attribute" => "url", "type" => "String", "required" => true, "nullable" => false},
        %{"attribute" => "promoted_content", "type" => "Boolean", "required" => true, "nullable" => true},
        %{"attribute" => "query", "type" => "String", "required" => true, "nullable" => false},
        %{"attribute" => "tweet_volume", "type" => "Int", "required" => true, "nullable" => true},
      ]
      |> write_schema(to: "priv/schema/model/trend.json")
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
end

Tw.V1_1.Schema.fetch()
