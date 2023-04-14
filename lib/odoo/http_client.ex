defmodule Odoo.HttpClient do
  @moduledoc false
  @behaviour Odoo.Api

  use Tesla
  adapter(Tesla.Adapter.Hackney, recv_timeout: 30_000)

  plug(Tesla.Middleware.Headers, [{"content-type", "application/json"}])
  # defaults to 5
  plug(Tesla.Middleware.FollowRedirects, max_redirects: 3)
  # plug(Tesla.Middleware.Logger)
  plug(Tesla.Middleware.JSON)

  @impl Odoo.Api
  def callp(url, data) do
    post(url, data) |> return_data(url)
  end

  @impl Odoo.Api
  def callp(url, data, cookie) do
    post(url, data, headers: [{"cookie", cookie}])
    |> return_data(url)
  end

  defp return_data({:error, :closed} = _data, _url) do
    {:error, "Connection closed."}
  end

  defp return_data({:error, :econnrefused} = _data, _url) do
    {:error, "Connection refused."}
  end

  defp return_data({:error, :nxdomain} = _data, url) do
    {:error, "Domain #{url} not exists."}
  end

  defp return_data({:error, response} = _data, _url) do
    {:error, response}
  end

  defp return_data(
         {:ok, %{body: %{"error" => error}} = _data},
         _url
       ) do
    # Error from Odoo response, not for http client
    {:error, "#{error["message"]} - #{error["data"]["message"]}."}
  end

  defp return_data(
         {:ok, %{"body" => %{"result" => %{"user_context" => user_context}}} = _data, _url}
       )
       when is_nil(user_context) do
    {:error, "Odoo login failed!"}
  end

  defp return_data({:ok, response} = _data, _url) when response.status in [404] do
    {:error, "Http client status: #{response.status}."}
  end

  defp return_data({:ok, response} = _data, _url) do
    cookie = Tesla.get_header(response, "set-cookie")

    resp =
      Odoo.HttpClientResponse.new()
      |> Map.put(:result, response.body["result"])
      |> Map.put(:cookie, cookie)

    {:ok, resp}
  end
end
