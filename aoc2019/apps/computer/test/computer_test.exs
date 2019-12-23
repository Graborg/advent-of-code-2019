defmodule ComputerTest do
  use ExUnit.Case

  test "3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9 with input 0 is zero" do
    assert elem(Computer.calculate([3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9], [0]), 1) == 0
  end

  test "3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9 with input 1 is not zero" do
    assert elem(Computer.calculate([3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9], [5]), 1) == 1
  end

  test "3,3,1105,-1,9,1101,0,0,12,4,12,99,1 with input 0 is zero" do
    assert elem(Computer.calculate([3,3,1105,-1,9,1101,0,0,12,4,12,99,1], [0]), 1) == 0
  end

  test "3,3,1105,-1,9,1101,0,0,12,4,12,99,1 with input 1 is not zero" do
    assert elem(Computer.calculate([3,3,1105,-1,9,1101,0,0,12,4,12,99,1], [5]), 1) == 1
  end

  test "longer input can handle less than" do
    assert elem(Computer.calculate([3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99], [7]), 1) == 999
  end

  test "longer input can handle equals" do
    assert elem(Computer.calculate([3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99], [8]), 1) == 1000
  end

  test "longer input can handle greater than" do
    assert elem(Computer.calculate([3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99], [50]), 1) == 1001
  end

  test "produces quine" do
    input_memory = [109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99]
    {computer, _} = Computer.calculate(input_memory, [])
    assert Enum.slice(computer[:memory], 0, Enum.count(input_memory)) == input_memory
  end

  test "produces 16 digit number" do
    { _, value } = Computer.calculate([1102,34915192,34915192,7,4,7,99,0], [])
    value
      |> Integer.digits()
      |> Enum.count()
      |> Kernel.==(16)
      |> assert()
  end

  test "produce biggest number in middle" do
    {_, value } = Computer.calculate([104,1125899906842624,99], [])
    assert value == 1125899906842624
  end
end
