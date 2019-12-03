defmodule OneTest do
  use ExUnit.Case
  test "calculates fuel requirement of 12" do
    assert One.get_fuel_requirement(12) == 2
  end

  test "calculates fuel requirement of 14" do
    assert One.get_fuel_requirement(14) == 2
  end

  test "calculates fuel requirement of 1969" do
    assert One.get_fuel_requirement(1969) == 654
  end

  test "calculates fuel requirement of 100756" do
    assert One.get_fuel_requirement(100756) == 33583
  end

  test "calculates fuel requirement of 14 plus fuel of fuel" do
    assert One.get_fuel_requirement_including_fuel_of_fuel(14) == 2
  end

  test "calculates fuel requirement of 1969 plus fuel of fuel" do
    assert One.get_fuel_requirement_including_fuel_of_fuel(1969) == 966
  end

  test "calculates fuel requirement of 100756 plus fuel of fuel" do
    assert One.get_fuel_requirement_including_fuel_of_fuel(100756) == 50346
  end
end
