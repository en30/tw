defmodule Tw.HTTP.Response do
  @moduledoc """
  HTTP response data structure.
  """

  defstruct [:status, :headers, :body]

  @type t :: %__MODULE__{
          status: non_neg_integer(),
          headers: list({binary, binary}),
          body: nil | binary
        }

  @spec new(keyword) :: t
  @doc false
  def new(opts) do
    opts = opts |> Keyword.update!(:headers, &Enum.map(&1, fn {k, v} -> {String.downcase(k), v} end))
    struct!(__MODULE__, opts)
  end

  @spec get_header(t, binary) :: list(binary())
  @doc false
  def get_header(%__MODULE__{} = response, key) do
    response.headers
    |> Enum.reduce([], fn
      {^key, value}, a -> [value | a]
      _, a -> a
    end)
    |> Enum.reverse()
  end
end
