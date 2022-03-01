defmodule Tw.V1_1.Schema do
  @moduledoc false

  # https://developer.twitter.com/en/docs/twitter-for-websites/supported-languages
  @type language ::
          :en
          | :ar
          | :bn
          | :cs
          | :da
          | :de
          | :el
          | :es
          | :fa
          | :fi
          | :fil
          | :fr
          | :he
          | :hi
          | :hu
          | :id
          | :it
          | :ja
          | :ko
          | :msa
          | :nl
          | :no
          | :pl
          | :pt
          | :ro
          | :ru
          | :sv
          | :th
          | :tr
          | :uk
          | :ur
          | :vi
          | :"zh-cn"
          | :"zh-tw"
          | :"pt-BR"
          | :pt

  def nilable(decoder_fn), do: fn v -> v && decoder_fn.(v) end
end
