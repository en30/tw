defmodule Tw.V1_1.TwitterDateTime do
  @moduledoc """
  A module for decoding Twitter's datetime format.
  """

  @spec decode!(binary) :: DateTime.t()
  @doc """
  Decode Twitter's datetime format into DateTime.

      iex> TwitterDateTime.decode!("Sun Feb 13 00:28:45 +0000 2022")
      ~U[2022-02-13 00:28:45Z]

      iex> TwitterDateTime.decode!("a")
      ** (RuntimeError) Parsing datetime failed: a
  """
  def decode!(str) do
    with <<_day_of_week::binary-size(4), rest::binary>> <- str,
         {month, rest} <- parse_month(rest),
         " " <> rest <- rest,
         {day, rest} <- Integer.parse(rest),
         " " <> rest <- rest,
         {hour, rest} <- Integer.parse(rest),
         ":" <> rest <- rest,
         {minute, rest} <- Integer.parse(rest),
         ":" <> rest <- rest,
         {second, rest} <- Integer.parse(rest),
         " +0000 " <> rest <- rest,
         {year, ""} <- Integer.parse(rest) do
      DateTime.new!(Date.new!(year, month + 1, day), Time.new!(hour, minute, second), "Etc/UTC")
    else
      _ -> raise "Parsing datetime failed: #{str}"
    end
  end

  for {pat, idx} <- Enum.with_index(~W[Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec]) do
    defp parse_month(unquote(pat) <> rest), do: {unquote(idx), rest}
  end
end
