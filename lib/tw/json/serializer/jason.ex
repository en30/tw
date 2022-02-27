defmodule Tw.JSON.Serializer.Jason do
  @moduledoc """
  Jason-based JSON serializer adapter.
  """

  @behaviour Tw.JSON.Serializer

  @impl true
  def encode(iodata, options), do: Jason.encode_to_iodata(iodata, options)

  @impl true
  def decode(iodata, options), do: Jason.decode(iodata, options)
end
