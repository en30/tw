defmodule Twitter.V1_1.Tweet do
  @moduledoc """
  Tweet data structure and related functions.
  """

  alias Twitter.V1_1.Client

  def home_timeline(client, opts \\ []) do
    client
    |> Client.request(:get, "/statuses/home_timeline.json", opts)
  end
end
