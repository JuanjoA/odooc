defmodule Odoo.Session do
  @moduledoc """
  Module to store Odoo session
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

  @doc """
  - Sets locally the user context language
  - The user is responsible to use the right language in the user context
  """
  def set_locally_user_context_lang(session, language) do
    session
    |> Map.put(:user_context, %{session.user_context | "lang" => language})
  end
end
