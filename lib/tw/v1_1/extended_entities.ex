defmodule Tw.V1_1.ExtendedEntities do
  @moduledoc """
  Extended Entities data structure and related functions.
  https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/extended-entities
  """

  alias Tw.V1_1.Media
  alias Tw.V1_1.Schema

  @enforce_keys [:media]
  defstruct([:media])

  @type t :: %__MODULE__{media: list(Media.t()) | nil}
  @spec decode!(map) :: t
  @doc """
  Decode JSON-decoded map into `t:t/0`
  """
  def decode!(json) do
    json =
      json
      |> Map.update!(:media, Schema.nilable(fn v -> Enum.map(v, &Media.decode!/1) end))

    struct(__MODULE__, json)
  end
end
