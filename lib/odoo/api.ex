defmodule Odoo.Api do
  @moduledoc """
  Behaviour for Odoo API http clients.
  """
  @type response :: Odoo.HttpClientResponse.t()
  @type url :: String.t()
  @type payload :: map()
  @type message :: String.t()
  @type cookie :: String.t()

  @callback callp(url, payload) :: {:ok, response} | {:error, message()}
  @callback callp(url, payload, cookie) :: {:ok, response} | {:error, message()}

  def callp(url, payload), do: impl().callp(url, payload)
  def callp(url, payload, cookie), do: impl().callp(url, payload, cookie)

  defp impl, do: Application.get_env(:odoo, :apiclient, Odoo.HttpClient)
end
