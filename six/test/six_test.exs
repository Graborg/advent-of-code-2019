defmodule SixTest do
  use ExUnit.Case
  doctest Six

  test "gets orbits" do
    assert Six.get_nr_orbits([ "COM)B", "B)C", "C)D", "D)E", "E)F", "B)G", "G)H", "D)I", "E)J", "J)K", "K)L"]) == 42
  end

  test "calculates orbits from input" do
    assert Six.get_nr_orbits_for_map_data() == 42
  end
end
