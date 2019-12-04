defmodule Three do

  def get_puzzle_input do
    with {:ok, body} <- File.read("input.json"),
         {:ok, json} <- Poison.decode(body), do: json

  end

  def get_closest_intersection(wire_one, wire_two) do
    set_1 = wire_one
    |> get_wire_positions()
    |> List.delete([0,0])
    |> List.delete([0,0])
    |> Enum.into(HashSet.new())

    wire_two
    |> get_wire_positions()
    |> List.delete([0,0])
    |> List.delete([0,0])
    |> Enum.into(HashSet.new())
    |> Set.intersection(set_1)
    |> Enum.map(&Enum.map(&1, fn x -> Kernel.abs(x) end))
    |> Enum.map(&Enum.sum/1)
    |> Enum.min()
  end

  def get_wire_positions(wire) do
    wire
    |> String.split(",")
    |> Enum.reduce([[0,0]], &move_wire/2)
  end

  def move_wire("R" <> steps, positions) do
    steps_int = String.to_integer(steps)
    positions
      |> List.last()
      |> (fn [x, y] -> positions ++ Enum.map(x..(x + steps_int), &([&1, y])) end).()
  end

  def move_wire("L" <> steps, positions) do
    steps_int = String.to_integer(steps)
    positions
      |> List.last()
      |> (fn [x, y] -> positions ++ Enum.map(x..(x - steps_int), &([&1, y])) end).()
  end

  def move_wire("U" <> steps, positions) do
    steps_int = String.to_integer(steps)
    positions
      |> List.last()
      |> (fn [x, y] -> positions ++ Enum.map(y..(y + steps_int), &([x, &1])) end).()
  end

  def move_wire("D" <> steps, positions) do
    steps_int = String.to_integer(steps)
    positions
      |> List.last()
      |> (fn [x, y] -> positions ++ Enum.map(y..(y - steps_int), &([x, &1])) end).()
  end

  def run do
    [wire1, wire2] = get_puzzle_input()
    IO.inspect(get_closest_intersection(wire1, wire2))
  end
end

Three.run()
