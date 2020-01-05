defmodule ElevenTest do
  use ExUnit.Case
  doctest Eleven

  # test "greets the world" do
  #   assert Enum.count(Eleven.paint_hull()) == 2056

  # end

  test "greets the world" do
    Eleven.paint_hull()
    |> elem(1)
    # |> IO.inspect()
    # assert Enum.count() == 0
  end
end
