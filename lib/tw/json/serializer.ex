defmodule Tw.JSON.Serializer do
  @moduledoc """
  JSON serializer constract.
  """

  @type encode_options :: keyword()
  @type decode_options :: keyword()

  @typedoc """
  Module which implements the Tw.JSON.Serializer behavior.
  """
  @type implementation :: module()

  @callback encode(iodata(), encode_options()) :: {:ok, iodata()} | {:error, Exception.t()}
  @callback decode(iodata(), decode_options()) :: {:ok, term()} | {:error, Exception.t()}
end
