defmodule OdooTest do
  use ExUnit.Case, async: true
  import Mox

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  describe "Odoo.login/4" do
    test "> login fails returns {:error, String.t()}" do
      msg_err = "Login failed"

      expect(
        Odoo.ApiMock,
        :callp,
        fn _url, _payload -> {:error, msg_err} end
      )

      assert {:error, ^msg_err} =
               Odoo.login(
                 "user",
                 "pass",
                 "db",
                 "http://localhost:8069"
               )
    end

    test "> login ok returns {:ok, Odoo.Session.t()}" do
      expect(
        Odoo.ApiMock,
        :callp,
        fn _url, _payload ->
          resp = %Odoo.HttpClientResponse{
            result: %{"user_context" => %{}},
            cookie: "a cookie"
          }

          {:ok, resp}
        end
      )

      assert {:ok, _odoo = %Odoo.Session{}} =
               Odoo.login(
                 "user",
                 "pass",
                 "db",
                 "http://localhost:8069"
               )
    end

    test "> login ok returns right values (user, pass, db,...)" do
      acontext = %{"lang" => "en_US", "tz" => "Europe/Brussels", "uid" => 2}

      expect(
        Odoo.ApiMock,
        :callp,
        fn _url, _payload ->
          resp = %Odoo.HttpClientResponse{
            result: %{"user_context" => acontext},
            cookie: "a cookie"
          }

          {:ok, resp}
        end
      )

      {:ok, odoo = %Odoo.Session{}} =
        Odoo.login(
          "user",
          "pass",
          "db",
          "http://localhost:8069"
        )

      assert odoo.user == "user"
      assert odoo.password == "pass"
      assert odoo.database == "db"
      assert odoo.url == "http://localhost:8069"
      assert odoo.cookie == "a cookie"
      assert odoo.user_context == acontext
    end

    test "> user request has all arguments or error" do
      user = "user"
      pass = "pass"
      db = "db"
      url = "http://localhost:8069"
      msg = "User is required"
      assert {:error, ^msg} = Odoo.login(nil, pass, db, url)
      msg = "Password is required"
      assert {:error, ^msg} = Odoo.login(user, nil, db, url)
      msg = "Database is required"
      assert {:error, ^msg} = Odoo.login(user, pass, nil, url)
      msg = "Url is required"
      assert {:error, ^msg} = Odoo.login(user, pass, db, nil)
    end
  end
end
