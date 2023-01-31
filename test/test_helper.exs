Mox.defmock(Odoo.MockHttpClientAdapter, for: Odoo.HttpClientAdapter)
Application.put_env(:odoo, :httpclient, Odoo.MockHttpClientAdapter)
ExUnit.start()
