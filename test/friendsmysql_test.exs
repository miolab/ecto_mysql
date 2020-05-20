defmodule FriendsmysqlTest do
  use ExUnit.Case
  doctest Friendsmysql

  test "greets the world" do
    assert Friendsmysql.hello() == :world
  end
end
