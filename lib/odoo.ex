defmodule Odoo do
  @moduledoc """
  Library to access Odoo JSON-RPC API.

  Provides the following methods for interacting with Odoo:

  - login
  - search
  - search_read
  - read
  - read_group
  - create
  - write
  - delete
  """

  @doc """

  - Login in Odoo and set session_id for future calls

  ### Params
  - user: string  Odoo user
  - password: string  Odoo password
  - database: string  Odoo database
  - url: string  Odoo url, http or https

  ### Examples

  ```
  iex> {:ok, odoo} = Odoo.login(
    "admin", "admin", "mydatabasename",
    "https://mydatabasename.odoo.com")

  {:ok,
  %Odoo.Session{
    cookie: "session_id=c8e544d0b305920afgdgsfdfdsa7b0cfe; Expires=Fri, 06-May-2022 23:16:12 GMT; Max-Age=7776000; HttpOnly; Path=/",
    database: "mydatabasename",
    password: "admin",
    url: "https://mydatabasename.odoo.com",
    user: "admin",
    user_context: %{"lang" => "en_US", "tz" => "Asia/Calcutta", "uid" => 2}
  }}


  ```
  """
  @spec login(String.t(), String.t(), String.t(), String.t()) ::
          {:ok, Odoo.Session.t()} | {:error, String.t()}
  def login(user, password, database, url) do
    Odoo.Core.login(user, password, database, parse_url(url))
  end

  defp parse_url(url) do
    if String.last(url) == "/" do
      String.slice(url, 0..-2)
    else
      url
    end
  end

  @doc """


  ### Examples

  - Search and read with default options (limit, domain, fields, offset and order)

  ```{:ok, res} = Odoo.search_read(odoo, "res.partner")```

  - Put options to tune the query:

  ```elixir
  {:ok, result} = Odoo.search_read(
    odoo,
    "res.partner",
    [
      limit: 1,
      domain: [["name", "ilike", "Antonio"]],
      fields: ["name", "street"],
      offset: 11,
      order: "name asc"])
  {:ok,
    [
      %{
        "id" => 226,
        "name" => "Antonio Fulanito de tal",
        "street" => "Calle principal 1"
      }
    ]}
    ```


    - Search and read active and archived records (by default odoo only return active records)
  ```elixir
  {:ok, partners} = Odoo.search_read(
        odoo,
        "res.partner", [
            fields: ["name"],
            offset: 0,
            limit: 10,
            order: "id",
            domain: [["active", "in", [true,false]]]
        ]
  )
  ```

  """
  def search_read(odoo = %Odoo.Session{}, model, opts \\ []) do
    Odoo.Core.search_read(odoo, model, opts)
  end

  @doc """
  - Search by domain. Return single id or id list.

  ### Params

  - Arguments in keyword list format.

  - Required opts:
      - domain: list of list

  - Optional arguments
    - limit: int, max number of rows to return from odoo
    - offset: int, offset over the default values to return

  ### Examples
  ```elixir
    iex>  {:ok, partner_ids} = Odoo.search(
      odoo,
      "res.partner",
      [ domain: [
          ["name", "ilike", "Antonia%"],
          ["customer", "=", true],
          ["create_date",">=","2021-06-01"]
        ],
        limit: 5,
        offset: 10,
        order: "name"
      ])

      {:ok, [318519, 357088, 237581, 378802, 258340]}
  ```

  - Return one value is a single integer for the id
  - Return more than one value is a list of integers
  - Can also return {:error, message} if the operation fails.
  """
  def search(odoo = %Odoo.Session{}, model, opts \\ []) do
    Odoo.Core.search(odoo, model, opts)
  end

  @doc """
  - Create objects
  - Return {:ok, new_object_id} or {:error, message}
  ### Examples

  ```elixir
  iex> {:ok, odoo} = Odoo.login()
  iex> {:ok, product_id} = Odoo.create(odoo, "product.product", [name: "mi mega producto3"])
  {:ok, 63}
  ```

  """
  def create(odoo = %Odoo.Session{}, model, opts \\ []) do
    Odoo.Core.create(odoo, model, opts)
  end

  @doc """
  - Read objects by id
  - Return {:ok, objects_list} or {:error, message}

  ### Examples

  ```elixir
  iex> {:ok, odoo} = Odoo.login()
  iex> {:ok, product} = Odoo.read(
    odoo,
    "product.product",
    [63],
    [fields: ["name", "categ_id"]])

  {:ok, [%{"categ_id" => [1, "All"], "id" => 63, "name" => "mi mega producto3"}]}
  ```
  """
  def read(odoo = %Odoo.Session{}, model, object_id, opts \\ []) do
    Odoo.Core.read(odoo, model, object_id, opts)
  end

  @doc """
  - Read and group objects

  ### Params

  - :fields
  - :domain
  - :groupby
  - :lazy
  - :orderby
  - :offset

  ### Examples

  ```elixir
  iex> {:ok, result} = Odoo.read_group(
      odoo,
      "account.invoice", [
        domain: [["date_invoice", ">=", "2021-11-01"]],
        groupby: ["date_invoice:month"],
        fields: ["number", "partner_id"], limit: 2, lazy: true])
     %{
     "__domain" => [
       "&",
       "&",
       ["date_invoice", ">=", "2022-01-01"],
       ["date_invoice", "<", "2022-02-01"],
       ["date_invoice", ">=", "2021-11-01"]
     ],
     "date_invoice:month" => "enero 2022",
     "date_invoice_count" => 61
   },
   %{
     "__domain" => [
       "&",
       "&",
       ["date_invoice", ">=", "2022-02-01"],
       ["date_invoice", "<", "2022-03-01"],
       ["date_invoice", ">=", "2021-11-01"]
     ],
     "date_invoice:month" => "febrero 2022",
     "date_invoice_count" => 32
   }
  ]}
  ```

  """
  def read_group(odoo = %Odoo.Session{}, model, opts \\ []) do
    Odoo.Core.read_group(odoo, model, opts)
  end

  @doc """
  - Update objects by id

  ### Examples

  ```elixir
  iex> {:ok, odoo} = Odoo.login()
  iex> {:ok, result} = Odoo.write(odoo, "product.product", [63], [name: "Mega Pro 3"])
  {:ok, true}
  ```
  """
  def write(odoo = %Odoo.Session{}, model, object_id, opts \\ []) do
    Odoo.Core.write(odoo, model, object_id, opts)
  end

  @doc """
  - Delete objects by id

  ### Examples
  ```elixir
  iex> {:ok, result} = Odoo.delete(odoo, "product.product", [63])
  {:ok, true}
  ```

  """
  def delete(odoo = %Odoo.Session{}, model, object_id) do
    Odoo.Core.delete(odoo, model, object_id)
  end

  @doc """
  Pagination over results in search_read (launch call to api odoo)

  ### Examples

  ```elixir
  iex> {:ok, result} = Odoo.search_read(
        odoo, "product.product", limit: 5, fields: ["name"], order: "id asc")
  {:ok,
    %Odoo.Result{
      data: [
        %{"id" => 1, "name" => "Restaurant Expenses"},
        %{"id" => 2, "name" => "Hotel Accommodation"},
        %{"id" => 3, "name" => "Virtual Interior Design"},
        %{"id" => 4, "name" => "Virtual Home Staging"},
        %{"id" => 5, "name" => "Office Chair"}
      ],
      model: "product.product",
      opts: [limit: 5, fields: ["name"], order: "id asc"]
    }}

   iex> {:ok, result2} = Odoo.next(odoo, result)
   {:ok,
    %Odoo.Result{
      data: [
        %{"id" => 6, "name" => "Office Lamp"},
        %{"id" => 7, "name" => "Office Design Software"},
        %{"id" => 8, "name" => "Desk Combination"},
        %{"id" => 9, "name" => "Customizable Desk"},
        %{"id" => 10, "name" => "Customizable Desk"}
      ],
      model: "product.product",
      opts: [offset: 5, limit: 5, fields: ["name"], order: "id asc"]
    }}

  ```
  """
  def next(odoo = %Odoo.Session{}, result) do
    new_opts = Odoo.Result.next(result.opts)
    Odoo.search_read(odoo, result.model, new_opts)
  end

  @doc """

  Get previous page results (launch call to api odoo)

  ### Examples

  ```elixir
  ...
  iex> {:ok, result2} = Odoo.next(odoo, result)
  {:ok,
      %Odoo.Result{
        data: [
          %{"id" => 6, "name" => "Office Lamp"},
          %{"id" => 7, "name" => "Office Design Software"},
          %{"id" => 8, "name" => "Desk Combination"},
          %{"id" => 12, "name" => "Customizable Desk"},
          %{"id" => 13, "name" => "Customizable Desk"}
        ],
        model: "product.product",
        opts: [offset: 5, limit: 5, fields: ["name"], order: "id asc"]
      }}

  iex> {:ok, result3} = Odoo.prev(odoo, result2)
  {:ok,
    %Odoo.Result{
      data: [
        %{"id" => 1, "name" => "Restaurant Expenses"},
        %{"id" => 2, "name" => "Hotel Accommodation"},
        %{"id" => 3, "name" => "Virtual Interior Design"},
        %{"id" => 4, "name" => "Virtual Home Staging"},
        %{"id" => 5, "name" => "Office Chair"}
      ],
      model: "product.product",
      opts: [offset: 0, limit: 5, fields: ["name"], order: "id asc"]
    }}
  ```

  """
  def prev(odoo = %Odoo.Session{}, result) do
    new_opts = Odoo.Result.prev(result.opts)
    Odoo.search_read(odoo, result.model, new_opts)
  end
end
