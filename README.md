# Elixir Odoo library

* Library to connect Odoo ERP from Elixir and do CRUD operations.

# State

* Can do login, search, search_read, read, read_group, create, write, delete and pagination.

# Documentation

* See _doc_ directory


# Todo

* Add tests
* Improve this README.md
** next and prev docs update and test it, y spec
* add execute_kw
** execute_kw tests


# Code review before publish

** Cambiar tesla por cliente http más ligero y rápido, por ejemplo "req"
** revisar check_response para usar en data_tuple

## Odoo.login -> Odoo.Api.login
  ** test: si lo llamas con otro número de parámetros error
  ** test: si algún parámetro en nil o "" error
  ** test: si login ok, devuelve session con lo indicado, mínimo comprobar {:ok,_}
  ** test: si contraseña incorrecta que no pete unpack
  ** 