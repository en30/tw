defmodule Twitter.V1_1.ExtendedEntities do
  @moduledoc """
  Extended Entities data structure and related functions.
  https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/extended-entities
  """

  import Twitter.V1_1.Schema, only: :macros

  defobject("priv/schema/model/extended_entities.json")
end
