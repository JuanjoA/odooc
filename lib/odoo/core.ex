defmodule Odoo.Core do
  @moduledoc false

  @odoo_call_kw_endpoint "/web/dataset/call_kw"
  @odoo_login_endpoint "/web/session/authenticate"

  def login(user, password, database, url) do
    url_endpoint = parse_url(url) <> @odoo_login_endpoint

    params = %{
      db: database,
      login: user,
      password: password
    }
    case json_rpc(url_endpoint, "call", params) do
      {:error, message} ->
        {:error, message}

      {:ok, response = %Odoo.HttpClientResponse{}} ->
        odoo_session =
          Odoo.Session.new()
          |> Map.put(:user_context, response.result["user_context"])
          |> Map.put(:cookie, response.cookie)
          |> Map.put(:user, user)
          |> Map.put(:password, password)
          |> Map.put(:database, database)
          |> Map.put(:url, url)
        {:ok, odoo_session}
    end
  end

  @spec search(Odoo.Session.t(), String.t(), Keyword.t()) ::
          {:ok, [Odoo.Result.t()]} | {:error, String.t()}
  def search(odoo = %Odoo.Session{}, model, opts \\ []) do
    url = odoo.url <> @odoo_call_kw_endpoint
    domain = Keyword.get(opts, :domain, [])
    kwargs =
      %{}
      |> Map.put(:limit, Keyword.get(opts, :limit, 0))
      |> Map.put(:offset, Keyword.get(opts, :offset, 0))
      |> Map.put(:order, Keyword.get(opts, :order, 0))
      |> Map.put(:context, odoo.user_context)

    params = %{
      "model" => model,
      "method" => "search",
      "args" => [domain],
      "kwargs" => kwargs
    }

    json_rpc(url, "call", params, odoo.cookie)
    |> return_data(model, opts)
  end

  def search_read(odoo = %Odoo.Session{}, model, opts \\ []) do
    url = odoo.url <> @odoo_call_kw_endpoint

    kwargs =
      %{}
      |> Map.put(:limit, Keyword.get(opts, :limit, 0))
      |> Map.put(:offset, Keyword.get(opts, :offset, 0))
      |> Map.put(:fields, Keyword.get(opts, :fields, nil))
      |> Map.put(:order, Keyword.get(opts, :order, nil))
      |> Map.put(:domain, Keyword.get(opts, :domain, []))
      |> Map.put(:context, odoo.user_context)

    params = %{
      "model" => model,
      "method" => "search_read",
      "args" => [],
      "kwargs" => kwargs
    }

    json_rpc(url, "call", params, odoo.cookie)
    |> return_data(model, opts)
  end

  def read(odoo = %Odoo.Session{}, model, object_ids, opts \\ []) do
    url = odoo.url <> @odoo_call_kw_endpoint

    kwargs =
      %{}
      |> Map.put(:fields, Keyword.get(opts, :fields, nil))
      |> Map.put(:context, odoo.user_context)

    params = %{
      "model" => model,
      "method" => "read",
      "args" => [object_ids],
      "kwargs" => kwargs
    }

    json_rpc(url, "call", params, odoo.cookie)
    |> return_data(model, opts)
  end

  def read_group(odoo = %Odoo.Session{}, model, opts \\ []) do
    url = odoo.url <> @odoo_call_kw_endpoint

    kwargs =
      %{}
      |> Map.put(:context, odoo.user_context)
      |> Map.put(:fields, Keyword.get(opts, :fields, nil))
      |> Map.put(:domain, Keyword.get(opts, :domain, nil))
      |> Map.put(:groupby, Keyword.get(opts, :groupby, nil))
      |> Map.put(:lazy, Keyword.get(opts, :lazy, false))
      |> Map.put(:orderby, Keyword.get(opts, :orderby, nil))
      |> Map.put(:offset, Keyword.get(opts, :offset, 0))

    params = %{
      "model" => model,
      "method" => "read_group",
      "args" => [],
      "kwargs" => kwargs
    }

    json_rpc(url, "call", params, odoo.cookie)
    |> return_data(model, opts)
  end

  def create(odoo = %Odoo.Session{}, model, opts \\ []) do
    url = odoo.url <> @odoo_call_kw_endpoint

    kwargs =
      %{}
      |> Map.put(:context, odoo.user_context)

    params = %{
      "model" => model,
      "method" => "create",
      "args" => [Enum.into(opts, %{})],
      "kwargs" => kwargs
    }

    json_rpc(url, "call", params, odoo.cookie)
    |> return_data(model, opts)
  end

  def write(odoo = %Odoo.Session{}, model, object_ids, opts \\ []) do
    url = odoo.url <> @odoo_call_kw_endpoint

    kwargs =
      %{}
      |> Map.put(:context, odoo.user_context)

    params = %{
      "model" => model,
      "method" => "write",
      "args" => object_ids ++ [Enum.into(opts, %{})],
      "kwargs" => kwargs
    }

    json_rpc(url, "call", params, odoo.cookie)
    |> return_data(model, opts)
  end

  def delete(odoo = %Odoo.Session{}, model, object_ids) do
    url = odoo.url <> @odoo_call_kw_endpoint

    kwargs =
      %{}
      |> Map.put(:context, odoo.user_context)

    params = %{
      "model" => model,
      "method" => "unlink",
      "args" => object_ids,
      "kwargs" => kwargs
    }

    json_rpc(url, "call", params, odoo.cookie)
    |> return_data(model, object_ids)
  end

  defp return_data(response_tuple, model, opts) do
    result =
      Odoo.Result.new()
      |> Map.put(:model, model)
      |> Map.put(:opts, opts)

    case response_tuple do
      {:error, _} ->
        response_tuple
      {:ok, response = %Odoo.HttpClientResponse{}} ->
        {:ok, Map.put(result, :data, response.result)}
      _ ->
        {:error, "Odoo.Core module: Unknow Error from http client"}
    end
  end

  @spec json_rpc(
    String.t(), String.t(), map(), String.t() | nil)
    :: {:ok, map()} | {:error, String.t()}
  defp json_rpc(url, method, params, session_id \\ nil) do
    data = %{
      "jsonrpc" => "2.0",
      "method" => method,
      "params" => params,
      "id" => :rand.uniform(9999)
    }

    if session_id do
      Odoo.Api.callp(url, data, session_id)
    else
      Odoo.Api.callp(url, data)
    end
  end

  defp parse_url(url) do
    if String.last(url) == "/" do
      String.slice(url, 0..-2)
    else
      url
    end
  end

end
