defmodule Tw.V1_1.Schema do
  @moduledoc """
  Map JSON-decoded Twitter data to Elixir data.
  """

  defmacro defobject(schema_file) do
    schema =
      File.read!(schema_file)
      |> Jason.decode!()

    quote do
      @external_resource unquote(schema_file)

      @enforce_keys unquote(required_fields(schema))
      defstruct unquote(fields(schema))

      @type t :: %__MODULE__{unquote_splicing(struct_field_types(schema))}

      unquote_splicing(field_type_defs(schema))

      @spec decode(map) :: t
      @doc """
      Decode JSON-decoded map into `t:t/0`
      """
      def decode(json) do
        %__MODULE__{unquote_splicing(decode_fields(schema))}
      end
    end
  end

  defmacro map_endpoint(method, path, to: {fn_name, _meta, nil}) do
    schema_file = endpoint_schema_path(method, path)

    schema =
      schema_file
      |> File.read!()
      |> Jason.decode!()

    params_type_name = :"#{fn_name}_param"

    type = to_ex_type("", schema["type"])
    decode = decoder(schema["type"])

    quote do
      @external_resource unquote(schema_file)

      @type unquote({params_type_name, [], Elixir}) :: unquote(params_type(params_type_name, schema))
      unquote_splicing(params_type_defs(params_type_name, schema))

      @spec unquote(fn_name)(Tw.V1_1.Client.t(), list(unquote({params_type_name, [], Elixir}))) ::
              {:ok, unquote(type)} | {:error, Tw.V1_1.TwitterAPIError.t() | Jason.DecodeError.t()}
      @doc """
      #{unquote(cite(schema["description"]))}

      See [the Twitter API documentation](#{unquote(schema["doc_url"])}) for details.
      """
      def unquote(fn_name)(client, opts \\ []) do
        with {:ok, resp} <- Tw.V1_1.Client.request(client, unquote(method), unquote(path), opts),
             {:ok, json} <- Jason.decode(resp.body) do
          {:ok, apply(unquote(decode), [json])}
        else
          {:error, error} ->
            {:error, error}
        end
      end
    end
  end

  defp endpoint_schema_path(method, path) do
    path = path |> String.replace("/", "_")
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

  defp field_type_defs(schema) do
    schema
    |> Enum.map(fn e ->
      quote do
        @typedoc unquote(format_description(e))
        @type unquote({String.to_atom(e["attribute"]), [], Elixir}) ::
                unquote(to_ex_type(e["attribute"], e["type"], e["nullable"] || !e["required"]))
      end
    end)
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

  def to_ex_type("created_at", "String"), do: quote(do: DateTime.t())
  def to_ex_type("bounding_box", "Object"), do: quote(do: Tw.V1_1.BoundingBox.t())
  def to_ex_type(name, "Array of " <> t), do: quote(do: list(unquote(to_ex_type(name, t |> String.trim_trailing("s")))))

  def to_ex_type(name, "Collection of " <> t),
    do: quote(do: list(unquote(to_ex_type(name, t |> String.trim_trailing("s")))))

  def to_ex_type(_name, "String"), do: quote(do: binary)
  def to_ex_type(_name, "Int64"), do: quote(do: integer)
  def to_ex_type(_name, "Integer"), do: quote(do: integer)
  def to_ex_type(_name, "Int"), do: quote(do: integer)
  def to_ex_type(_name, "Boolean"), do: quote(do: boolean)
  def to_ex_type(_name, "Float"), do: quote(do: float)
  def to_ex_type(_name, "User object"), do: quote(do: Tw.V1_1.User.t())
  def to_ex_type(_name, "Tweet"), do: quote(do: Tw.V1_1.Tweet.t())
  def to_ex_type(_name, "Object"), do: quote(do: map)
  def to_ex_type(_name, "Array of String"), do: quote(do: list(binary))
  def to_ex_type(_name, "Coordinates"), do: quote(do: Tw.V1_1.Coordinates.t())
  def to_ex_type(_name, "Places"), do: quote(do: Tw.V1_1.Place.t())
  def to_ex_type(_name, "Entities"), do: quote(do: Tw.V1_1.Entities.t())
  def to_ex_type(_name, "Hashtag Object"), do: quote(do: Tw.V1_1.Hashtag.t())
  def to_ex_type(_name, "Media Object"), do: quote(do: Tw.V1_1.Media.t())
  def to_ex_type(_name, "URL Object"), do: quote(do: Tw.V1_1.URL.t())
  def to_ex_type(_name, "User Mention Object"), do: quote(do: Tw.V1_1.UserMention.t())
  def to_ex_type(_name, "Symbol Object"), do: quote(do: Tw.V1_1.Symbol.t())
  def to_ex_type(_name, "Poll Object"), do: quote(do: Tw.V1_1.Poll.t())
  def to_ex_type("sizes", "Size Object"), do: quote(do: Tw.V1_1.Sizes.t())
  def to_ex_type(_name, "Size Object"), do: quote(do: Tw.V1_1.Size.t())
  def to_ex_type(_name, "Option Object"), do: quote(do: map)
  def to_ex_type(_name, "User Entities"), do: quote(do: Tw.V1_1.UserEntities.t())
  def to_ex_type(_name, "Extended Entities"), do: quote(do: Tw.V1_1.ExtendedEntities.t())
  def to_ex_type(_name, "Search Result Object"), do: quote(do: Tw.V1_1.SearchResult.t())
  def to_ex_type(_name, "Search Metadata Object"), do: quote(do: Tw.V1_1.SearchMetadata.t())

  def to_ex_type(_name, "Cursored Result Object with " <> kv) do
    [k, v] = String.split(kv, " ", parts: 2)

    quote do
      %{
        unquote(String.to_atom(k)) => unquote(to_ex_type("", v)),
        next_cursor: integer,
        next_cursor_str: binary,
        previous_cursor: integer,
        previous_cursor_str: binary
      }
    end
  end

  # TODO
  def to_ex_type(_name, "Rule Object"), do: quote(do: map)
  def to_ex_type(_name, "Arrays of Enrichment Objects"), do: quote(do: list(map))

  defp to_ex_type(name, type, false), do: to_ex_type(name, type)

  defp to_ex_type(name, type, true) do
    quote do
      unquote(to_ex_type(name, type)) | nil
    end
  end

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

  def decode_field(json_value, _field, _type), do: json_value

  defp decoder("Array of " <> twitter_type) do
    quote(do: fn x -> Enum.map(x, unquote(decoder(twitter_type |> String.trim_trailing("s")))) end)
  end

  defp decoder("Tweet"), do: quote(do: &Tw.V1_1.Tweet.decode/1)
  defp decoder("User object"), do: quote(do: &Tw.V1_1.User.decode/1)
  defp decoder("Search Result Object"), do: quote(do: &Tw.V1_1.SearchResult.decode/1)

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

  defp params_type(params_type_name, schema) do
    schema["parameters"]
    |> Enum.map(fn
      %{"name" => name, "required" => _} ->
        quote do
          {unquote(String.to_atom(name)), unquote({:"#{params_type_name}_#{name}", [], Elixir})}
        end
    end)
    |> Enum.reduce(fn e, acc ->
      quote(do: unquote(acc) | unquote(e))
    end)
  end

  def params_type_defs(params_type_name, schema) do
    schema["parameters"]
    |> Enum.map(fn
      %{"name" => name, "description" => description, "required" => _, "type" => type} ->
        quote do
          @typedoc unquote(description)
          @type unquote({:"#{params_type_name}_#{name}", [], Elixir}) ::
                  unquote(to_ex_type(name, type, false))
        end
    end)
  end

  def cite(text) do
    "> " <> String.replace(text, "\n", "\n> ")
  end
end
