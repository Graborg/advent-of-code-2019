defmodule EightTest do
  use ExUnit.Case
  doctest Eight

  test "creates layers" do
    Eight.create_layers("123456789012", 3, 2)
      |> List.last()
      |> List.last()
      |> Kernel.==(["0","1","2"])
      |> assert()
  end

  test "find layer with fewest zeroes" do
    Eight.get_number_of_1_digits_mul_by_number_of_2_digits_of_layer_with_smallest_amount_of_zeroes()
      |> Kernel.==(1548)
      |> assert()
  end

  test "count 0 in layer" do
    assert Eight.count_n_in_layer([["1","2", "0", "4"], ["1","0", "1", "4"]], "0") == 2
  end

  test "count 3 in layer" do
    assert Eight.count_n_in_layer([["1","2", "0", "3"], ["1","0", "1", "4"]], "3") == 1
  end

  test "gets visible pixels" do
    assert Eight.get_visible_pixels("02221122221200000000", 2, 2) == [["0", "1"], ["1","0"]]
  end

  test "gets visible pixels from input" do
    assert Eight.get_visible_pixels() == [["0", "1", "1", "0", "0", "1", "1", "1", "1", "0", "1", "0", "0", "1", "0", "1", "0", "0", "1", "0", "0", "1", "1", "0", "0"], ["1", "0", "0", "1", "0", "1", "0", "0", "0", "0", "1", "0", "1", "0", "0", "1", "0", "0", "1", "0", "1", "0", "0", "1", "0"], ["1", "0", "0", "0", "0", "1", "1", "1", "0", "0", "1", "1", "0", "0", "0", "1", "0", "0", "1", "0", "1", "0", "0", "1", "0"], ["1", "0", "0", "0", "0", "1", "0", "0", "0", "0", "1", "0", "1", "0", "0", "1", "0", "0", "1", "0", "1", "1", "1", "1", "0"], ["1", "0", "0", "1", "0", "1", "0", "0", "0", "0", "1", "0", "1", "0", "0", "1", "0", "0", "1", "0", "1", "0", "0", "1", "0"], ["0", "1", "1", "0", "0", "1", "1", "1", "1", "0", "1", "0", "0", "1", "0", "0", "1", "1", "0", "0", "1", "0", "0", "1", "0"]]
  end

end
