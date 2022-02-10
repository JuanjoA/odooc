defmodule OdoocTest do
  use ExUnit.Case
  doctest Odooc

  test "greets the world" do
    assert Odooc.hello() == :world
  end
end
