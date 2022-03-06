defmodule Tw.HTTP.MultipartFormData do
  @moduledoc false

  defstruct [:boundary, parts: []]
  @dash "--"
  @crlf "\r\n"
  @head_pre "Content-Disposition: form-data; name=\""
  @head_suff "\""

  @spec new([{:boundary, binary()} | {:parts, [{binary(), iodata()}]}]) :: struct
  def new(opts) do
    opts =
      opts
      |> Keyword.put_new_lazy(:boundary, fn -> 32 |> :crypto.strong_rand_bytes() |> Base.url_encode64() end)

    struct!(__MODULE__, opts)
  end

  def content_type(%__MODULE__{boundary: boundary}) do
    "multipart/form-data; boundary=#{boundary}"
  end

  def encode(%__MODULE__{boundary: boundary, parts: parts}) do
    parts
    |> Enum.sort_by(fn {k, _v} -> k end)
    |> Enum.flat_map(fn {k, v} -> part(boundary, k, v) end)
    |> Enum.concat([@dash, boundary, @dash, @crlf, @crlf])
    |> IO.iodata_to_binary()
  end

  defp part(boundary, k, v) do
    [
      [@dash, boundary, @crlf],
      [@head_pre, k, @head_suff, @crlf, @crlf],
      [v, @crlf]
    ]
  end
end
