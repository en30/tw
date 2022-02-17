defmodule Tw.V1_1.Size do
  @moduledoc """
  Size data structure and related functions.
  https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/entities
  """

  import Tw.V1_1.Schema, only: :macros

  defobject("priv/schema/model/size.json")
end
