defmodule YarnexTest do
  use ExUnit.Case
  doctest Yarnex

  test "greets the world" do
    assert Yarnex.hello() == :world
  end
end
