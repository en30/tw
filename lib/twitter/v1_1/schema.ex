defmodule Twitter.V1_1.Schema do
  @spec decode_twitter_datetime!(binary) :: NaiveDateTime.t()
  @doc """
  Decode Twitter's datetime format into NaiveDateTime.
  iex> Schema.decode_twitter_datetime!("Sun Feb 13 00:28:45 +0000 2022")
  ~N[2022-02-13 00:28:45]

  iex> Schema.decode_twitter_datetime!("a")
  ** (RuntimeError) Parsing datetime failed: a
  """
  def decode_twitter_datetime!(str) do
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
      NaiveDateTime.new!(year, month + 1, day, hour, minute, second)
    else
      _ -> raise "Parsing datetime failed: #{str}"
    end
  end

  for {pat, idx} <- Enum.with_index(~W[Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec]) do
    defp parse_month(unquote(pat) <> rest), do: {unquote(idx), rest}
  end
end
