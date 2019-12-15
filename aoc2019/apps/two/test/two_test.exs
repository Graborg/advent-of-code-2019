defmodule TwoTest do
  use ExUnit.Case
  doctest Two

  test "calculates [1,0,0,0,99]" do
    assert Two.calculate([1,0,0,0,99]) == [2,0,0,0,99]
  end
  test "calculates [2,3,0,3,99]" do
    assert Two.calculate([2,3,0,3,99]) == [2,3,0,6,99]
  end
  test "calculates [2,4,4,5,99,0]" do
    assert Two.calculate([2,4,4,5,99,0]) == [2,4,4,5,99,9801]
  end
  test "calculates [1,1,1,4,99,5,6,0,99]" do
    assert Two.calculate([1,1,1,4,99,5,6,0,99]) == [30,1,1,4,2,5,6,0,99]
  end
end
