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

  defp return_data({:error, :closed}=_data, _url) do
    {:error, "Connection closed."}
  end
  defp return_data({:error, :econnrefused}=_data, _url) do
    {:error, "Connection refused."}
  end
  defp return_data({:error, :nxdomain}=_data, url) do
    {:error, "Domain #{url} not exists."}
  end
  defp return_data({:error, response}=_data, _url) do
    {:error, response}
  end
  defp return_data(
    { :ok,  %{body: %{"error"=> error}}=_data }, _url) do
    {:error, "#{error["message"]} - #{error["data"]["message"]}."}
  end
  defp return_data({:ok, response}=_data, _url) when response.status in [404] do
    {:error, "Http client status: #{response.status}."}
  end
  defp return_data({:ok, response}=_data, _url) do
    cookie = Tesla.get_header(response, "set-cookie")
    new_body = Map.put(response.body, "cookie", cookie)
    {:ok, new_body}
  end

end
