defmodule OdooCoreTest do

  use ExUnit.Case, async: true
  import Mox

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  describe "Odoo.Core.login/4" do

    test "> login fails returns {:error, String.t()}" do
      msg_err = "Login failed"
      expect(
        Odoo.ApiMock,
        :callp, fn _url, _payload -> {:error, msg_err} end)

      assert {:error, ^msg_err} = Odoo.Core.login(
        "user", "pass", "db", "http://localhost:8069")
    end

    test "> login ok returns {:ok, Odoo.Session.t()}" do
      expect(
        Odoo.ApiMock,
        :callp, fn _url, _payload ->
            resp = %Odoo.HttpClientResponse{
              result: %{"user_context" => %{}},
              cookie: "a cookie"}
            {:ok, resp}
         end)

      assert {:ok, _odoo = %Odoo.Session{} } = Odoo.Core.login(
        "user", "pass", "db", "http://localhost:8069")
    end

    test "> login ok returns right values" do
      acontext = %{"lang" => "en_US", "tz" => "Europe/Brussels", "uid" => 2}
      expect(
        Odoo.ApiMock,
        :callp, fn _url, _payload ->
          resp = %Odoo.HttpClientResponse{
            result: %{"user_context" => acontext},
            cookie: "a cookie"}
          {:ok, resp}
        end)
      {:ok, odoo = %Odoo.Session{} } = Odoo.Core.login(
        "user", "pass", "db", "http://localhost:8069")
      assert odoo.user == "user"
      assert odoo.password == "pass"
      assert odoo.database == "db"
      assert odoo.url == "http://localhost:8069"
      assert odoo.cookie == "a cookie"
      assert odoo.user_context == acontext
    end
  end

end
