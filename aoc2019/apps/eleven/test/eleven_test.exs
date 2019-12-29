defmodule ElevenTest do
  use ExUnit.Case
  doctest Eleven

  test "greets the world" do
    assert Eleven.hello() == :world
  end
end
