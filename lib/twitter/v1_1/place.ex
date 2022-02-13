defmodule Twitter.V1_1.Place do
  @moduledoc """
  Place data structure and related functions.
  https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/geo
  """

  import Twitter.V1_1.Schema, only: :macros

  defobject("priv/schema/model/place.json")
end
