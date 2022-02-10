defmodule Odoo.Result do
  @moduledoc """
  Structure to contain result data from odoo and helpers
  """
  alias __MODULE__

  defstruct [
    :data,
    :model,
    :opts
  ]

  @doc false
  def new, do: %Result{}

  @doc """
  Using offset and limit, return a new set of options to operate over next results page
  """
  def next(opts) do
    limit = Keyword.get(opts, :limit, 0)
    offset = Keyword.get(opts, :offset, 0)

    opts
    |> Keyword.put(:offset, offset + limit)
  end

  @doc """
  Return previous page (offset - limit)
  """
  def prev(opts) do
    limit = Keyword.get(opts, :limit, 0)
    offset = Keyword.get(opts, :offset, 0)

    new_offset =
      if offset - limit < 0 do
        0
      else
        offset - limit
      end

    opts
    |> Keyword.put(:offset, new_offset)
  end
end
