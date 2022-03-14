defmodule Tw.V1_1.Fixture do
  @moduledoc false

  def list_fixture do
    File.read!("test/support/fixtures/v1_1/list.json") |> Jason.decode!(keys: :atoms) |> Tw.V1_1.List.decode!()
  end

  def user_fixture do
    File.read!("test/support/fixtures/v1_1/user.json") |> Jason.decode!(keys: :atoms) |> Tw.V1_1.User.decode!()
  end

  def tweet_fixture do
    File.read!("test/support/fixtures/v1_1/tweet.json") |> Jason.decode!(keys: :atoms) |> Tw.V1_1.Tweet.decode!()
  end
end
