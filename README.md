# Tw

[![CI](https://github.com/en30/tw/actions/workflows/ci.yml/badge.svg)](https://github.com/en30/tw/actions/workflows/ci.yml)

[Docs](https://hexdocs.pm/tw)

<!-- MDOC !-->

Twitter API Client for elixir.

- depends only on `jason` (optional) and `hackney` (optional).
  - JSON library and HTTP client are replacable.
- no implicit state (at least for now)

## Installation

The package can be installed by adding `tw` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:jason, "~> 1.2"},   # only if you choose jason
    {:hackney, "~> 1.0"}, # only if you choose hackney
    {:tw, "~> 0.1.2"}
  ]
end
```

## Examples

### Twitter API v1.1

```elixir
alias Tw.OAuth.
alias Tw.V1_1.Client
alias Tw.V1_1.Tweet

credentials = OAuth.V1_0a.Credentials.new(
  consumer_key: "xxx",
  consumer_secret: "xxx",
  access_token: "xxx",
  access_token_secret: "xxx",
)
client = Client.new(
  credentials: credentials,
)
{:ok, [%Tweet{} | _]} = Tweet.home_timeline(client, %{count: 10})
```

There are functions which wrap API endpoints. They provide functionality below.

- parameter encoding from `Struct`, `List` etc.
- response decoding into `Struct`.
- documentation.
- typespec.

If the corresponding function is not implemented for your desired endpoint, or if the above is unnecessary/problematic, the `Client` can be used as is.

```elixir
alias Tw.V1_1.Client
{:ok, result_map} = Client.request(client, :get, "/foo/bar.json", %{param_1: 2})
```

## HTTP Client is replacable

You can use whichever HTTP client you want as long as it implements `Tw.HTTP.Client` (inspired by [the greate Goth redesign article](https://dashbit.co/blog/goth-redesign)).

## JSON encoder/decoder is replacable

You can also switch JSON encode/decoder to another one as long as it implements `Tw.JSON.Serializer`.

<!-- MDOC !-->

## Development

### Generate base code from Twitter v1.1 documentation

```console
$ elixir bin/codegen.exs endpoint 'GET statuses/home_timeline' home_timeline
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/tw](https://hexdocs.pm/tw).
