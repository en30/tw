# Twitter

<!-- MDOC !-->

A Twitter API Client for Elixir that has not been implemented at all yet.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `twitter` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:twitter, "~> 0.0.1"}
  ]
end
```

## Examples

### Version 1.1

```elixir
  credentials = Twitter.OAuth.V1_0a.Credentials.new(
    consumer_key: "xxx",
    consumer_secret: "xxx",
    access_token: "xxx",
    acess_token_secret: "xxx",
  )
  client = Twitter.V1_1.Client.new(
    http_client: Twitter.HTTP.Client.Hackney, # or another module which implements Twitter.HTTP.Client
    credentials: credentials,
  )
  Twitter.V1_1.Tweet.home_timeline(client, count: 10)
```

<!-- MDOC !-->

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/twitter](https://hexdocs.pm/twitter).
