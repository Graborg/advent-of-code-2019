defmodule FiveTest do
  use ExUnit.Case
  doctest Five

  test "3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9 with input 0 is zero" do
    assert Five.calculate([3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9], 0) == 0
  end

  test "3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9 with input 1 is not zero" do
    assert Five.calculate([3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9], 5) == 1
  end

  test "3,3,1105,-1,9,1101,0,0,12,4,12,99,1 with input 0 is zero" do
    assert Five.calculate([3,3,1105,-1,9,1101,0,0,12,4,12,99,1], 0) == 0
  end

  test "3,3,1105,-1,9,1101,0,0,12,4,12,99,1 with input 1 is not zero" do
    assert Five.calculate([3,3,1105,-1,9,1101,0,0,12,4,12,99,1], 5) == 1
  end

  test "longer input can handle less than" do
    assert Five.calculate([3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99], 7) == 999
  end

  test "longer input can handle equals" do
    assert Five.calculate([3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99], 8) == 1000
  end

  test "longer input can handle greater than" do
    assert Five.calculate([3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99], 50) == 1001
  end

  test "run_program_with_input 5" do
    assert Five.run_program_with_input(5) == 8834787
  end
end
