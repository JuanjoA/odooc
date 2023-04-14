defmodule Odoo.HttpClientResponse do
  @moduledoc """
  Struct to store formated response from http client
  """
  alias __MODULE__

  defstruct [
    :result,
    :cookie
  ]

  @doc false
  def new, do: %HttpClientResponse{}
end
