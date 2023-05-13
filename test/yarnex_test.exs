defmodule YarnTest do
  use ExUnit.Case
  doctest Yarn

  test "gets api endpoint" do
    assert Yarn.api_endpoint("twtxt.net") == "https://twtxt.net/api/v1"
  end
end
