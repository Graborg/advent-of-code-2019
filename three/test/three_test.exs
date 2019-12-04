defmodule ThreeTest do
  use ExUnit.Case
  doctest Three

  test "test case one" do
    wire_one = "R75,D30,R83,U83,L12,D49,R71,U7,L72"
    wire_two = "U62,R66,U55,R34,D71,R55,D58,R83"
    assert Three.get_closest_intersection(wire_one, wire_two) == 159
  end

  test "test case two" do
    wire_one = "R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51"
    wire_two = "U98,R91,D20,R16,D67,R40,U7,R15,U6,R7"
    assert Three.get_closest_intersection(wire_one, wire_two) == 135
  end
end
