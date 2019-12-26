defmodule TenTest do
  use ExUnit.Case
  doctest Ten

  test "can gets index of 1,1" do
    assert Ten.coordinates_to_index({1, 1}, 5) == 6
  end

  test "can gets index of 0,1" do
    assert Ten.coordinates_to_index({0, 1}, 5) == 5
  end

  test "can gets index of 3,3" do
    assert Ten.coordinates_to_index({3, 3}, 5) == 18
  end

  test "can gets index of 0,0" do
    assert Ten.coordinates_to_index({0, 0}, 5) == 0
  end

  test "can gets index of 2,0" do
    assert Ten.coordinates_to_index({2, 0}, 5) == 2
  end

  test "can gets index of 4" do
    assert Ten.index_to_coordinates(4, 5) == {4, 0}
  end

  test "can gets index of 15" do
    assert Ten.index_to_coordinates(18, 5) == {3, 3}
  end

  test "can gets index of 0" do
    assert Ten.index_to_coordinates(0, 5) == {0, 0}
  end

  test "can gets index of 2" do
    assert Ten.index_to_coordinates(2, 5) == {2, 0}
  end

  test "can find astroids 4x4" do
    input = """
    .#..#
    .....
    #####
    ....#
    ...##
    """

    res = Ten.map_to_detections(input)
    assert res == {8, {3, 4}}
  end

  test "can find astroids in big" do
    input = """
    ......#.#.
    #..#.#....
    ..#######.
    .#.#.###..
    .#..#.....
    ..#....#.#
    #..#....#.
    .##.#..###
    ##...#..#.
    .#....####
    """

    res = Ten.map_to_detections(input)
    assert res == {33, {5,8}}
  end

  test "can find astroids in bigg" do
    input = """
    #.#...#.#.
    .###....#.
    .#....#...
    ##.#.#.#.#
    ....#.#.#.
    .##..###.#
    ..#...##..
    ..##....##
    ......#...
    .####.###.
    """

    res = Ten.map_to_detections(input)
    assert res == {35, {1,2}}
  end

  test "can find astroids in biggg" do
    input = """
    .#..#..###
    ####.###.#
    ....###.#.
    ..###.##.#
    ##.##.#.#.
    ....###..#
    ..#.#..#.#
    #..#.#.###
    .##...##.#
    .....#.#..
    """

    res = Ten.map_to_detections(input)
    assert res == {41, {6,3}}
  end

  test "can find astroids in biggest" do
    input = """
    .#..##.###...#######
    ##.############..##.
    .#.######.########.#
    .###.#######.####.#.
    #####.##.#.##.###.##
    ..#####..#.#########
    ####################
    #.####....###.#.#.##
    ##.#################
    #####.##.###..####..
    ..######..##.#######
    ####.##.####...##..#
    .#####..#.######.###
    ##...#.##########...
    #.##########.#######
    .####.#.###.###.#.##
    ....##.##.###..#####
    .#.#.###########.###
    #.#.#.#####.####.###
    ###.##.####.##.#..##
    """

    res = Ten.map_to_detections(input)
    assert res == {210, {11,13}}
  end

  test "can find astroids in challenge" do
    res = Ten.map_to_detections()
    assert res == {276, {17, 22}}
  end
end
