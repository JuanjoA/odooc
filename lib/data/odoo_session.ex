defmodule Odoo.Session do
  @moduledoc """
  Struct to store Odoo session
  """
  alias __MODULE__

  defstruct [
    :user,
    :password,
    :url,
    :database,
    :user_context,
    :cookie
  ]

  @doc false
  def new, do: %Session{}
end
