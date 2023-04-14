Mox.defmock(Odoo.ApiMock, for: Odoo.Api)
Application.put_env(:odoo, :apiclient, Odoo.ApiMock)

ExUnit.start()
