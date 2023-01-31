defmodule Odoo.HttpClientAdapter do

  @type url :: String.t()
  @type payload :: map()
  @type message :: String.t()
  @type cookie :: String.t()

  @callback opost(url, payload) :: {:ok, map()} | {:error, message()}
  @callback opost(url, payload, cookie) :: {:ok, map()} | {:error, message()}

  def opost(url, payload), do: impl().opost(url, payload)
  def opost(url, payload, cookie), do: impl().opost(url, payload, cookie)

  defp impl, do: Application.get_env(:odoo, :httpclient, Odoo.HttpClient)

end
