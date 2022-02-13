defmodule Twitter.V1_1.UserMention do
  @moduledoc """
  UserMention data structure and related functions.
  https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/entities
  """

  import Twitter.V1_1.Schema, only: :macros

  defobject("priv/schema/model/user_mention.json")
end
