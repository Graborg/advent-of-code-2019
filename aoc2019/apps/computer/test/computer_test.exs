defmodule ComputerTest do
  use ExUnit.Case

  test "produces quine" do
    input_memory = [109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99]
    {output_memory, _} = Computer.calculate(input_memory, [])
    assert Enum.slice(output_memory, 0, Enum.count(input_memory)) == input_memory
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
