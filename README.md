# Tw

<!-- MDOC !-->

An unofficial Twitter API Client for Elixir that has not been implemented at all yet.

## Installation

The package can be installed by adding `tw` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:tw, "~> 0.1.0"}
  ]
end
```

## Examples

### Twitter API v1.1

```elixir
credentials = Tw.OAuth.V1_0a.Credentials.new(
  consumer_key: "xxx",
  consumer_secret: "xxx",
  access_token: "xxx",
  access_token_secret: "xxx",
)
client = Tw.V1_1.Client.new(
  credentials: credentials,
)
Tw.V1_1.Tweet.home_timeline(client, %{count: 10})
```

If you want to use an endpoint which is not implemented by this client, you can use low-level API.

```elixir
Tw.V1_1.Client.request(client, :get, "/foo/bar.json", %{})
```

<!-- MDOC !-->

## Development

### Fetch schema for Twitter API v1.1

```console
$ elixir bin/fetch_schema.exs
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/tw](https://hexdocs.pm/tw).
