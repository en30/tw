defmodule Twitter.V1_1.User do
  @moduledoc """
  User data structure and related functions.
  https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/user
  """

  import Twitter.V1_1.Schema, only: :macros

  defobject("priv/schema/model/user.json")

  map_endpoint(:get, "/users/show.json", to: find)
end
