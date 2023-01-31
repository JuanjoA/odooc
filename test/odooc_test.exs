defmodule OdoocTest do

  use ExUnit.Case, async: true
  import Mox

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  test "test error wip..." do
    Odoo.MockHttpClientAdapter
    |> expect(:opost, fn {_url, _payload} -> {:ok, %{}} end)

    assert Odoo.HttpClientAdapter.opost("url", "payload") == {:ok, %{}}
  end

end
