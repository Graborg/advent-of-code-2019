defmodule TenTest do
  use ExUnit.Case
  doctest Ten

  test "can gets index of 1,1" do
    assert Ten.coordinates_to_index({1, 1}) == 6
  end

  test "can gets index of 0,1" do
    assert Ten.coordinates_to_index({0, 1}) == 5
  end

  test "can gets index of 3,3" do
    assert Ten.coordinates_to_index({3, 3}) == 18
  end

  test "can gets index of 0,0" do
    assert Ten.coordinates_to_index({0, 0}) == 0
  end

  test "can gets index of 2,0" do
    assert Ten.coordinates_to_index({2, 0}) == 2
  end

  test "can gets index of 4" do
    assert Ten.index_to_coordinates(4) == {4, 0}
  end

  test "can gets index of 15" do
    assert Ten.index_to_coordinates(18) == {3, 3}
  end

  test "can gets index of 0" do
    assert Ten.index_to_coordinates(0) == {0, 0}
  end

  test "can gets index of 2" do
    assert Ten.index_to_coordinates(2) == {2, 0}
  end

  test "can find astroids" do
    input = """
      .#..#
      .....
      #####
      ....#
      ...##
    """

    res = Ten.map_to_detections(input)
    assert res == [7, 7, 6, 7, 7, 7, 5, 7, 8, 7]
  end
end
