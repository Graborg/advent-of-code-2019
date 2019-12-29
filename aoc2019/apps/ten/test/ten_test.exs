defmodule TenTest do
  use ExUnit.Case
  doctest Ten
  @big_asteroid_map """
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

    res = Ten.get_best_asteroid(input)
    assert res == {8, {3, 4}}
  end

  # test "can find astroids in big" do
  #   input = """
  #   ......#.#.
  #   #..#.#....
  #   ..#######.
  #   .#.#.###..
  #   .#..#.....
  #   ..#....#.#
  #   #..#....#.
  #   .##.#..###
  #   ##...#..#.
  #   .#....####
  #   """

  #   res = Ten.get_best_asteroid(input)
  #   assert res == {33, {5,8}}
  # end

  # test "can find astroids in bigg" do
  #   input = """
  #   #.#...#.#.
  #   .###....#.
  #   .#....#...
  #   ##.#.#.#.#
  #   ....#.#.#.
  #   .##..###.#
  #   ..#...##..
  #   ..##....##
  #   ......#...
  #   .####.###.
  #   """

  #   res = Ten.get_best_asteroid(input)
  #   assert res == {35, {1,2}}
  # end

  # test "can find astroids in biggg" do
  #   input = """
  #   .#..#..###
  #   ####.###.#
  #   ....###.#.
  #   ..###.##.#
  #   ##.##.#.#.
  #   ....###..#
  #   ..#.#..#.#
  #   #..#.#.###
  #   .##...##.#
  #   .....#.#..
  #   """

  #   res = Ten.get_best_asteroid(input)
  #   assert res == {41, {6,3}}
  # end

  # test "can find astroids in biggest" do
  #   input = """
  #   .#..##.###...#######
  #   ##.############..##.
  #   .#.######.########.#
  #   .###.#######.####.#.
  #   #####.##.#.##.###.##
  #   ..#####..#.#########
  #   ####################
  #   #.####....###.#.#.##
  #   ##.#################
  #   #####.##.###..####..
  #   ..######..##.#######
  #   ####.##.####...##..#
  #   .#####..#.######.###
  #   ##...#.##########...
  #   #.##########.#######
  #   .####.#.###.###.#.##
  #   ....##.##.###..#####
  #   .#.#.###########.###
  #   #.#.#.#####.####.###
  #   ###.##.####.##.#..##
  #   """

  #   res = Ten.get_best_asteroid(input)
  #   assert res == {210, {11,13}}
  # end

  # test "can find astroids in challenge" do
  #   res = Ten.get_best_asteroid()
  #   assert res == {276, {17, 22}}
  # end

  test "can find first asteroid to be vaporized in small example" do
    map = """
    .#....#####...#..
    ##...##.#####..##
    ##...#...#.#####.
    ..#.....#...###..
    ..#.#.....#....##
    .................
    .................
    .................
    .................
    .................
    .................
    .................
    .................
    .................
    .................
    .................
    .................
    """
    res = Ten.get_asteroid_vaporized(map, 17, {8, 3})
    assert res == {10, 4}
  end

  test "can find first asteroid to be vaporized" do
    res = Ten.get_asteroid_vaporized(@big_asteroid_map, 1)
    assert res == {11, 12}
  end

  test "can find the 2nd asteroid to be vaporized" do
    res = Ten.get_asteroid_vaporized(@big_asteroid_map, 2)
    assert res == {12, 1}
  end

  test "can find the 3rd asteroid to be vaporized" do
    res = Ten.get_asteroid_vaporized(@big_asteroid_map, 3)
    assert res == {12, 2}
  end

  test "can find the 10th asteroid to be vaporized" do
    res = Ten.get_asteroid_vaporized(@big_asteroid_map, 10)
    assert res == {12, 8}
  end

  test "can find the 20th asteroid to be vaporized" do
    res = Ten.get_asteroid_vaporized(@big_asteroid_map, 20)
    assert res == {16, 0}
  end

  test "can find the 50th asteroid to be vaporized" do
    res = Ten.get_asteroid_vaporized(@big_asteroid_map, 50)
    assert res == {16, 9}
  end

  test "can find the 100th asteroid to be vaporized" do
    res = Ten.get_asteroid_vaporized(@big_asteroid_map, 100)
    assert res == {10, 16}
  end

  test "can find the 199th asteroid to be vaporized" do
    res = Ten.get_asteroid_vaporized(@big_asteroid_map, 199)
    assert res == {9, 6}
  end

  test "can find the 200th asteroid to be vaporized" do
    res = Ten.get_asteroid_vaporized(@big_asteroid_map, 200)
    assert res == {8, 2}
  end

  test "can find the 201th asteroid to be vaporized" do
    res = Ten.get_asteroid_vaporized(@big_asteroid_map, 201)
    assert res == {10, 9}
  end

  test "can find the 299th asteroid to be vaporized" do
    res = Ten.get_asteroid_vaporized(@big_asteroid_map, 299)
    assert res == {11, 1}
  end

  test "can find the 200th asteroid to settle bet" do
    res = Ten.get_asteroid_vaporized()
    assert res == {13, 21}
  end

end
