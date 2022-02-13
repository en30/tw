Mix.install([
  {:floki, "~> 0.32"},
  {:req, "~> 0.2.0"}
])

defmodule Twitter.V1_1.Schema do
  def fetch do
    files = [
      &fetch_tweet_object/0,
      &fetch_user_object/0,
      &fetch_geo_objects/0,
      &fetch_entities_objects/0,
    ]
    |> Enum.map(& Task.async(&1))
    |> Task.await_many(10_000)

    IO.puts("Gnerated files below.")
    files
    |> Enum.each(&IO.puts/1)
  end

  defp fetch_tweet_object() do
    {:ok, html} =
      Req.get!(
        "https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/tweet"
      )
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
      %{"attribute" => "quoted_status_permalink", "type" => "Object", "required" => false, "nullable" => true},
    ])
    |> write_schema(to: "priv/schema/model/tweet.json")
  end

  defp fetch_user_object() do
    {:ok, html} =
      Req.get!(
        "https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/user"
      )
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
      Req.get!(
        "https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/geo"
      )
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
      Req.get!(
        "https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/entities"
      )
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
        %{"attribute" => "media", "type" => "Array of Media Objects", "required" => true, "nullable" => true},
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

      {"table", _, _} = table, [{_,_} | _] = acc ->
        [{to_map(table)} | acc]

      {"table", _, _} = table, [{_} | tail] ->
        [{to_map(table)} | tail]

      {"h" <> _, _, _} = heading, [{fields} | tail] ->
        [{Floki.text(heading) |> String.trim(), fields} | tail]

      _, acc -> acc
    end)
    |> Map.new()
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
end

Twitter.V1_1.Schema.fetch()
