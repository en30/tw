defmodule Tw.V1_1.Endpoint do
  @moduledoc """
  Helpers for endpoint mapping functions.
  """

  @type user_params :: Tw.V1_1.User.t() | %{user_id: Tw.V1_1.User.id()} | %{screen_name: Tw.V1_1.User.screen_name()}
  defmacro user_params do
    quote do
      %{user: Tw.V1_1.User.t()} | %{user_id: Tw.V1_1.User.id()} | %{screen_name: Tw.V1_1.User.screen_name()}
    end
  end

  defmacro optional_user_params do
    quote do
      %{} | %{user: Tw.V1_1.User.t()} | %{user_id: Tw.V1_1.User.id()} | %{screen_name: Tw.V1_1.User.screen_name()}
    end
  end

  @type user_list_params ::
          list(Tw.V1_1.User.t())
          | %{user_id: list(Tw.V1_1.User.id())}
          | %{screen_name: list(Tw.V1_1.User.screen_name())}
  defmacro user_list_params do
    quote do
      %{users: list(Tw.V1_1.User.t())}
      | %{user_ids: list(Tw.V1_1.User.id())}
      | %{screen_names: list(Tw.V1_1.User.screen_name())}
    end
  end

  @type list_params ::
          %{list: Tw.V1_1.List.t()}
          | %{list_id: non_neg_integer()}
          | %{slug: binary(), owner_id: Tw.V1_1.User.id()}
          | %{slug: binary(), owner_screen_name: Tw.V1_1.User.screen_name()}
  defmacro list_params do
    quote do
      %{list: Tw.V1_1.List.t()}
      | %{list_id: non_neg_integer()}
      | %{slug: binary(), owner_id: Tw.V1_1.User.id()}
      | %{slug: binary(), owner_screen_name: Tw.V1_1.User.screen_name()}
    end
  end

  defmacro deftype_cross_merge(name, u1, u2) do
    quote do
      @type unquote(name) :: unquote(cross_merge(Macro.expand(u1, __ENV__), Macro.expand(u2, __ENV__)))
    end
  end

  def cross_merge(u1, u2) do
    for keys1 <- type_keys(u1), keys2 <- type_keys(u2) do
      {:%{}, [], keys1 ++ keys2}
    end
    |> Enum.reduce(fn e, a ->
      {:|, [], [e, a]}
    end)
  end

  defp type_keys({:|, _, [t1, t2]}), do: type_keys(t1) ++ type_keys(t2)
  defp type_keys({:%{}, _, keys}), do: [keys]

  def preprocess_list_params(%{list: %{id: id}} = params) do
    params
    |> Map.delete(:list)
    |> Map.put(:list_id, id)
  end

  def preprocess_list_params(%{list_id: _} = params), do: params
  def preprocess_list_params(%{slug: _, owner_id: _} = params), do: params
  def preprocess_list_params(%{slug: _, owner_screen_name: _} = params), do: params

  def preprocess_user_params(%{user: %{id: id}} = params) do
    params
    |> Map.delete(:user)
    |> Map.put(:user_id, id)
  end

  def preprocess_user_params(%{user_id: _} = params), do: params
  def preprocess_user_params(%{screen_name: _} = params), do: params

  def preprocess_optional_user_params(%{user: _} = params) do
    preprocess_user_params(params)
  end

  def preprocess_optional_user_params(params), do: params

  def preprocess_user_list_params(%{users: users} = params) do
    params
    |> Map.delete(:users)
    |> Map.put(:user_id, Enum.map_join(users, ",", & &1.id))
  end

  def preprocess_user_list_params(%{user_ids: ids} = params) do
    params
    |> Map.delete(:user_ids)
    |> Map.put(:user_id, Enum.join(ids, ","))
  end

  def preprocess_user_list_params(%{screen_names: names} = params) do
    params
    |> Map.delete(:screen_names)
    |> Map.put(:screen_name, Enum.join(names, ","))
  end
end
