defmodule Tw.V1_1.Me do
  @moduledoc """
  Extended `Tw.V1_1.User` returned by `GET account/verify_credentials`.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/manage-account-settings/api-reference/get-account-verify_credentials) for details.
  """

  import Tw.V1_1.Schema, only: :macros

  defobject("priv/schema/model/me.json")
end
