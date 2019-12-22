defmodule NineTest do
  use ExUnit.Case
  doctest Nine

  test "finishes test suite" do
    assert Nine.get_BOOST_keycode(1) == 2662308295
  end

  test "gets distress coordinates" do
    assert Nine.get_BOOST_keycode(2) == 63441
  end
end
