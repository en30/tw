defmodule Twitter.V1_1.Poll do
  @moduledoc """
  Poll data structure and related functions.
  https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/entities
  """

  import Twitter.V1_1.Schema, only: :macros

  defobject("priv/schema/model/poll.json")
end
