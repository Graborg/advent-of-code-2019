defmodule FourTest do
  use ExUnit.Case
  doctest Four

  # test "111111 meets the criteria" do
  #   assert Four.get_amount_of_possible_passwords("111110-111112") == 1
  # end

  # test "223450 does not meet the criteria" do
  #   assert Four.get_amount_of_possible_passwords("223449-223451") == 0
  # end

  # test "123789 does not meet the criteria" do
  #   assert Four.get_amount_of_possible_passwords("123788-123790") == 0
  # end

  # test "111110 does not meet the criteria" do
  #   assert Four.get_amount_of_possible_passwords("111110-111115") == 4
  # end

  # test "111210 has 36 possible passwords" do
  #   assert Four.get_amount_of_possible_passwords("111219-111315") == 36
  # end

  test "357253-892942 has 530 possible passwords" do
    assert Four.get_amount_of_possible_passwords("357253-892942") == 530
  end

  # test "112232-112234 has 1 possible passwords" do
  #   assert Four.get_amount_of_possible_passwords("112232-112234") == 1
  # end

  # test "123443-123445 has 0 possible passwords" do
  #   assert Four.get_amount_of_possible_passwords("123443-123445") == 0
  # end

  test "111121-111123 has 1 possible passwords" do
    assert Four.get_amount_of_possible_passwords("111121-111123") == 1
  end

end
