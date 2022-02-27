defmodule Tw.JSON.Serializer do
  @moduledoc """
  JSON serializer constract.
  """

  @type encode_options :: keyword()
  @type decode_options :: keyword()

  @callback encode(iodata(), encode_options()) :: {:ok, iodata()} | {:error, Exception.t()}
  @callback decode(iodata(), decode_options()) :: {:ok, term()} | {:error, Exception.t()}
end
