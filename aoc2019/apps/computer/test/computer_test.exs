defmodule ComputerTest do
  use ExUnit.Case

  test "produces quine" do
    assert Computer.calculate([109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99], []) == [109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99]
  end

  # test "produces 16 digit number" do
  #   Computer.calculate([1102,34915192,34915192,7,4,7,99,0], [])
  #     |> Integer.digits(123)
  #     |> Enum.count()
  #     |> Kernel.==(16)
  # end

  # test "produce biggest number in middle" do
  #   assert Computer.calculate([104,1125899906842624,99], []) == 1125899906842624
  # end
end


## TODO
# Opcode 9 adjusts the relative base by the value of its only parameter.
# The relative base increases (or decreases, if the value is negative) by the value of the parameter.

# Parameters in mode 2, relative mode


# Fill memory with 0
