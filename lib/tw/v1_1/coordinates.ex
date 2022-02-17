defmodule Tw.V1_1.Coordinates do
  @moduledoc """
  Coordinates data structure and related functions.
  https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/geo
  """

  import Tw.V1_1.Schema, only: :macros

  defobject("priv/schema/model/coordinates.json")
end