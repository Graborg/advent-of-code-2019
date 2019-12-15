defmodule EightTest do
  use ExUnit.Case
  doctest Eight

  test "greets the world" do
    assert Eight.hello() == :world
  end
end
