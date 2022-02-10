defmodule Odoo.HttpClient do
  @moduledoc false
  use Tesla
  adapter(Tesla.Adapter.Hackney, recv_timeout: 30_000)

  plug(Tesla.Middleware.Headers, [{"content-type", "application/json"}])
  # defaults to 5
  plug(Tesla.Middleware.FollowRedirects, max_redirects: 3)
  # plug(Tesla.Middleware.Logger)
  plug(Tesla.Middleware.JSON)

  def opost(url, data) do
    post(url, data) |> return_data(url)
  end

  def opost(url, data, cookie) do
    post(url, data, headers: [{"cookie", cookie}])
    |> return_data(url)
  end

  defp return_data(data_tuple, url) do
    case data_tuple do
      {:error, :closed} ->
        {:error, "Connection closed."}

      {:error, :econnrefused} ->
        {:error, "Connection refused."}

      {:error, :nxdomain} ->
        {:error, "Domain #{url} not exists."}

      {:error, response} ->
        {:error, response, response.status}

      {:ok, response} ->
        if response.status in [404] do
          {:error, "Http client status: #{response.status}."}
        else
          cookie = Tesla.get_header(response, "set-cookie")
          {:ok, response.body, response.status, cookie}
        end
    end
  end
end
