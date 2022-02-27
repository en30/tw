defmodule Tw.V1_1.Schema do
  @moduledoc """
  Map JSON-decoded Twitter data to Elixir data.
  """

  # https://developer.twitter.com/en/docs/twitter-for-websites/supported-languages
  @type language ::
          :en
          | :ar
          | :bn
          | :cs
          | :da
          | :de
          | :el
          | :es
          | :fa
          | :fi
          | :fil
          | :fr
          | :he
          | :hi
          | :hu
          | :id
          | :it
          | :ja
          | :ko
          | :msa
          | :nl
          | :no
          | :pl
          | :pt
          | :ro
          | :ru
          | :sv
          | :th
          | :tr
          | :uk
          | :ur
          | :vi
          | :"zh-cn"
          | :"zh-tw"
          | :"pt-BR"
          | :pt

  @doc false
  defmacro defobject(schema_file) do
    schema =
      File.read!(schema_file)
      |> Jason.decode!()

    quote do
      @external_resource unquote(schema_file)

      @enforce_keys unquote(required_fields(schema))
      defstruct unquote(fields(schema))

      @typedoc """
      #{unquote(schema |> field_type_table() |> cite())}
      """
      @type t :: %__MODULE__{unquote_splicing(struct_field_types(schema))}

      @spec decode(map) :: t
      @doc """
      Decode JSON-decoded map into `t:t/0`
      """
      def decode(json) do
        %__MODULE__{unquote_splicing(decode_fields(schema))}
      end
    end
  end

  @doc false
  defmacro map_endpoint(method, path, to: {fn_name, _meta, nil}) do
    schema_file = endpoint_schema_path(method, path)

    schema =
      schema_file
      |> File.read!()
      |> Jason.decode!()

    params_type_name = :"#{fn_name}_params"

    type = to_ex_type("", schema["type"])
    decode = decoder(schema["type"])

    quote do
      @external_resource unquote(schema_file)

      @typedoc """
      Parameters for `#{unquote(fn_name)}/3`.

      #{unquote(cite(params_type_table(schema)))}

      See [the Twitter API documentation](#{unquote(schema["doc_url"])}) for details.
      """
      @type unquote({params_type_name, [], Elixir}) :: unquote(params_type(schema))

      @spec unquote(fn_name)(Tw.V1_1.Client.t(), unquote({params_type_name, [], Elixir}), Tw.HTTP.Client.options()) ::
              {:ok, unquote(type)} | {:error, Tw.V1_1.TwitterAPIError.t()}
      @doc """
      Request `#{unquote(method |> to_string() |> String.upcase())} #{unquote(path)}` and return decoded result.
      #{unquote(cite(schema["description"]))}

      See [the Twitter API documentation](#{unquote(schema["doc_url"])}) for details.
      """
      def unquote(fn_name)(client, params, http_client_opts \\ []) do
        with {:ok, resp} <- Tw.V1_1.Client.request(client, unquote(method), unquote(path), params, http_client_opts),
             {:ok, json} <- Tw.V1_1.Client.decode_json(client, resp.body) do
          {:ok, apply(unquote(decode), [json])}
        else
          {:error, error} ->
            {:error, error}
        end
      end
    end
  end

  defp endpoint_schema_path(method, path) do
    path = path |> String.replace("/", "_") |> String.replace(":", "")
    Path.join(["priv/schema/endpoint", to_string(method) <> path])
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
      dec =
        quote do
          Tw.V1_1.Schema.decode_field(
            json[unquote(e["attribute"])],
            unquote(e["attribute"]),
            unquote(e["type"])
          )
        end

      {String.to_atom(e["attribute"]), dec}
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
  def decode_field(json_value, name, twitter_type)

  def decode_field(nil, _name, _twitter_type), do: nil

  def decode_field(json_value, name, "Array of " <> twitter_type) do
    Enum.map(json_value, &decode_field(&1, name, twitter_type |> String.trim_trailing("s")))
  end

  def decode_field(json_value, "created_at", "String"), do: decode_twitter_datetime!(json_value)
  def decode_field(json_value, "bounding_box", "Object"), do: Tw.V1_1.BoundingBox.decode(json_value)
  def decode_field(json_value, _name, "User object"), do: Tw.V1_1.User.decode(json_value)
  def decode_field(json_value, _name, "Tweet"), do: Tw.V1_1.Tweet.decode(json_value)
  def decode_field(json_value, _name, "Coordinates"), do: Tw.V1_1.Coordinates.decode(json_value)
  def decode_field(json_value, _name, "Places"), do: Tw.V1_1.Place.decode(json_value)
  def decode_field(json_value, _name, "Entities"), do: Tw.V1_1.Entities.decode(json_value)
  def decode_field(json_value, _name, "Hashtag Object"), do: Tw.V1_1.Hashtag.decode(json_value)
  def decode_field(json_value, _name, "Media Object"), do: Tw.V1_1.Media.decode(json_value)
  def decode_field(json_value, _name, "URL Object"), do: Tw.V1_1.URL.decode(json_value)
  def decode_field(json_value, _name, "User Mention Object"), do: Tw.V1_1.UserMention.decode(json_value)
  def decode_field(json_value, _name, "Symbol Object"), do: Tw.V1_1.Symbol.decode(json_value)
  def decode_field(json_value, _name, "Poll Object"), do: Tw.V1_1.Poll.decode(json_value)
  def decode_field(json_value, "sizes", "Size Object"), do: Tw.V1_1.Sizes.decode(json_value)
  def decode_field(json_value, _name, "Size Object"), do: Tw.V1_1.Size.decode(json_value)
  def decode_field(json_value, _name, "User Entities"), do: Tw.V1_1.UserEntities.decode(json_value)
  def decode_field(json_value, _name, "Extended Entities"), do: Tw.V1_1.ExtendedEntities.decode(json_value)
  def decode_field(json_value, _name, "Search Metadata Object"), do: Tw.V1_1.SearchMetadata.decode(json_value)
  def decode_field(json_value, _name, "Friendship Source Object"), do: Tw.V1_1.FriendshipSource.decode(json_value)
  def decode_field(json_value, _name, "Friendship Target Object"), do: Tw.V1_1.FriendshipTarget.decode(json_value)
  def decode_field(json_value, _name, "Place Type Object"), do: %{code: json_value["code"], name: json_value["name"]}

  def decode_field(json_value, _name, "Connection Enum"),
    do: Tw.V1_1.FriendshipLookupResult.decode_connection(json_value)

  def decode_field(json_value, _field, _type), do: json_value

  defp decoder("Array of " <> twitter_type) do
    quote(do: fn x -> Enum.map(x, unquote(decoder(twitter_type |> String.trim_trailing("s")))) end)
  end

  defp decoder("Tweet"), do: quote(do: &Tw.V1_1.Tweet.decode/1)
  defp decoder("User object"), do: quote(do: &Tw.V1_1.User.decode/1)
  defp decoder("Me Object"), do: quote(do: &Tw.V1_1.Me.decode/1)
  defp decoder("Search Result Object"), do: quote(do: &Tw.V1_1.SearchResult.decode/1)
  defp decoder("Friendship Lookup Result Object"), do: quote(do: &Tw.V1_1.FriendshipLookupResult.decode/1)
  defp decoder("Trend Location Object"), do: quote(do: &Tw.V1_1.TrendLocation.decode/1)

  defp decoder("Cursored Result Object with " <> kv) do
    [k, v] = String.split(kv, " ", parts: 2)

    quote do
      fn json ->
        %{
          next_cursor: json["next_cursor"],
          next_cursor_str: json["next_cursor_str"],
          previous_cursor: json["previous_cursor"],
          previous_cursor_str: json["previous_cursor_str"]
        }
        |> Map.put(
          String.to_existing_atom(unquote(k)),
          Tw.V1_1.Schema.decode_field(json[unquote(k)], unquote(k), unquote(v))
        )
      end
    end
  end

  defp decoder("Friendship Relationship Object") do
    quote do
      fn json ->
        %{relationship: Tw.V1_1.Friendship.decode(json["relationship"])}
      end
    end
  end

  defp decoder("oEmbed Object") do
    quote do
      fn json ->
        ~W[url author_name author_url html width height type cache_age provider_name provider_url version]
        |> Enum.reduce(%{}, fn key, a ->
          Map.put(a, String.to_atom(key), json[key])
        end)
      end
    end
  end

  defp decoder("Trends Object") do
    quote do
      fn json ->
        %{
          trends: Enum.map(json["trends"], &Tw.V1_1.Trend.decode/1),
          as_of: json["as_of"] |> DateTime.from_iso8601(),
          created_at: json["created_at"] |> DateTime.from_iso8601(),
          locations: Enum.map(json["locations"], &%{name: &1["name"], woeid: &1["woeid"]})
        }
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
