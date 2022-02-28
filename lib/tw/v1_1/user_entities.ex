defmodule Tw.V1_1.UserEntities do
  @moduledoc """
  Undocumented User Entities data structure and related functions.
  https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/user
  """

  alias Tw.V1_1.Entities
  alias Tw.V1_1.Schema

  @enforce_keys [:description]
  defstruct([:description, :url])

  @type t :: %__MODULE__{description: Entities.t(), url: Entities.t() | nil}
  @spec decode!(map) :: t
  @doc """
  Decode JSON-decoded map into `t:t/0`
  """
  def decode!(json) do
    json =
      json
      |> Map.update!(:description, &Entities.decode!/1)
      |> Map.update(:url, nil, Schema.nilable(&Entities.decode!/1))

    struct(__MODULE__, json)
  end
end
