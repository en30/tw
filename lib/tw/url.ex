defmodule Tw.URL do
  @moduledoc """
  Include knowledge on Twitter Web's URL.
  """

  alias Tw.V1_1

  @spec user(V1_1.User.t() | V1_1.User.id() | binary()) :: binary()
  def user(%V1_1.User{id_str: id_str}), do: user(id_str)
  def user(id), do: "https://twitter.com/i/user/#{id}"

  @spec tweet(V1_1.Tweet.t() | V1_1.Tweet.id() | binary()) :: binary()
  def tweet(%V1_1.Tweet{id_str: id_str}), do: tweet(id_str)
  def tweet(id), do: "https://twitter.com/i/web/status/#{id}"

  @spec list(V1_1.List.t() | V1_1.List.id() | binary()) :: binary()
  def list(%V1_1.List{id_str: id_str}), do: list(id_str)
  def list(id), do: "https://twitter.com/i/lists/#{id}"

  @type search_params :: %{
          required(:q) => binary(),
          optional(:f) => :live | :user | :image | :video,
          optional(:pf) => :on,
          optional(:lf) => :on
        }
  @spec search(search_params()) :: binary()
  def search(params), do: "https://twitter.com/search?" <> URI.encode_query(params)

  @spec hashtag(V1_1.Hashtag.t() | binary()) :: binary()
  def hashtag(%V1_1.Hashtag{text: text}), do: hashtag(text)
  def hashtag(text) when is_binary(text), do: "https://twitter.com/hashtag/" <> URI.encode(text)

  @type new_tweet_params :: %{
          optional(:text) => binary(),
          optional(:url) => binary(),
          optional(:hashtags) => list(binary()),
          optional(:via) => binary(),
          optional(:related) => list(binary())
        }
  @spec new_tweet(new_tweet_params()) :: binary()
  def new_tweet(params), do: "https://twitter.com/intent/tweet?" <> URI.encode_query(params)

  @type new_retweet_params :: %{tweet: V1_1.Tweet.t()} | %{tweet_id: V1_1.Tweet.id()}
  @spec new_retweet(new_retweet_params()) :: binary()
  def new_retweet(%{tweet: %V1_1.Tweet{id: id}}), do: new_retweet(%{tweet_id: id})
  def new_retweet(params), do: "https://twitter.com/intent/retweet?" <> URI.encode_query(params)

  @type new_like_params :: %{tweet: V1_1.Tweet.t()} | %{tweet_id: V1_1.Tweet.id()}
  @spec new_like(new_like_params()) :: binary()
  def new_like(%{tweet: %V1_1.Tweet{id: id}}), do: new_like(%{tweet_id: id})
  def new_like(params), do: "https://twitter.com/intent/like?" <> URI.encode_query(params)

  @type new_follow_params :: %{user: V1_1.User.t()} | %{screen_name: binary()} | %{user_id: V1_1.Tweet.id()}
  @spec new_follow(new_follow_params()) :: binary()
  def new_follow(%{user: %V1_1.User{id: id}}), do: new_follow(%{user_id: id})
  def new_follow(params), do: "https://twitter.com/intent/follow?" <> URI.encode_query(params)

  @type switch_account() :: binary()
  def switch_account, do: "https://twitter.com/account/switch"
end
