defmodule Tw.V1_1.UserEntities do
  @moduledoc """
  Undocumented User Entities data structure and related functions.
  https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/user
  """

  import Tw.V1_1.Schema, only: :macros

  defobject("priv/schema/model/user_entities.json")
end
