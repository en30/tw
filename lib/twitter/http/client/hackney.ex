defmodule Twitter.HTTP.Client.Hackney do
  @moduledoc """
  Hackney-based HTTP client adapter.
  """

  @behaviour Twitter.HTTP.Client

  @impl true
  def request(method, url, headers, body, opts) do
    with {:ok, status, headers, body_ref} <- :hackney.request(method, url, headers, body, opts),
         {:ok, body} <- :hackney.body(body_ref) do
      {:ok, %{status: status, headers: headers, body: body}}
    else
      {:error, reason} ->
        {:error, RuntimeError.exception(inspect(reason))}
    end
  end
end
