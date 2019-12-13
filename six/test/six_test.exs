defmodule SixTest do
  use ExUnit.Case
  doctest Six

  test "gets orbits" do
    assert Six.get_nr_orbits([ "COM)B", "B)C", "C)D", "D)E", "E)F", "B)G", "G)H", "D)I", "E)J", "J)K", "K)L"]) == 42
  end

  test "calculates orbits from input" do
    assert Six.get_nr_orbits_for_map_data() == 270768
  end

  test "get min path to santa" do
    orbit_map = ["COM)B", "B)C", "C)D", "D)E", "E)F", "B)G", "G)H", "D)I", "E)J", "J)K", "K)L", "K)YOU", "I)SAN"]
    assert Six.get_min_path_to_santa(orbit_map) == 4
  end

  test "get min path to santa real map" do
    assert Six.get_min_path_to_santa() == 451
  end
end
