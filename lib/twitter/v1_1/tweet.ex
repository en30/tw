defmodule Twitter.V1_1.Tweet do
  @moduledoc """
  Tweet data structure and related functions.
  https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/tweet
  """

  alias Twitter.V1_1.Client
  import Twitter.V1_1.Schema, only: :macros

  defobject("priv/schema/model/tweet.json")

  @spec home_timeline(Client.t(), keyword) :: {:ok, list(t)} | {:error, Exception.t()}
  def home_timeline(client, opts \\ []) do
    with {:ok, resp} <- Client.request(client, :get, "/statuses/home_timeline.json", opts),
         :ok <- File.write!("home_timeline.json", resp.body),
         {:ok, json} <- Jason.decode(resp.body) do
      {:ok, Enum.map(json, &decode/1)}
    else
      {:error, message} ->
        {:error, message}
    end
  end
end
