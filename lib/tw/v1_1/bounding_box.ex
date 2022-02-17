defmodule Tw.V1_1.BoundingBox do
  @moduledoc """
  Bounding Box data structure and related functions.
  https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/geo
  """

  import Tw.V1_1.Schema, only: :macros

  defobject("priv/schema/model/bounding_box.json")
end
