defmodule Three do

  def get_puzzle_input do
    with {:ok, body} <- File.read("input.json"),
         {:ok, json} <- Poison.decode(body), do: json

  end

  def get_proximity_to_closest_intersection(wire_one, wire_two) do
    p1 = get_wire_positions(wire_one)
    p2 = get_wire_positions(wire_two)

    get_intersections(p1, p2)
      |> get_closest_intersection()
  end

  def get_closest_intersection(intersections) do
    intersections
      |> Enum.map(&Enum.map(&1, fn x -> Kernel.abs(x) end))
      |> Enum.map(&Enum.sum/1)
      |> Enum.min()
  end

  def get_steps_to_closest_intersection(wire_one, wire_two) do
    p1 = get_wire_positions(wire_one)
    p2 = get_wire_positions(wire_two)

    intersections = get_intersections(p1, p2)

    get_closest_intersection_from_steps(intersections, p1, p2)
  end

  def get_closest_intersection_from_steps(intersections, positions1, positions2) do
    intersections
      |> Enum.map(fn position -> [get_steps_to_position(positions1, position), get_steps_to_position(positions2, position)] end)
      |> Enum.map(&Enum.sum/1)
      |> Enum.min()
  end

  def get_steps_to_position(wire, position) do
    Enum.find_index(wire, fn wire_pos -> position == wire_pos end)
    |> Kernel.+(1)
  end

  def get_intersections(wire_one, wire_two) do
    set_1 = Enum.into(wire_one, MapSet.new())

    wire_two
    |> Enum.into(MapSet.new())
    |> MapSet.intersection(set_1)
  end

  def get_wire_positions(wire) do
    wire
    |> String.split(",")
    |> Enum.reduce([[0,0]], &move_wire/2)
    |> List.delete([0,0])
  end

  def move_wire("R" <> steps, positions) do
    steps_int = String.to_integer(steps)
    positions
      |> List.last()
      |> (fn [x, y] -> positions ++ Enum.map(x+1..(x + steps_int), &([&1, y])) end).()
  end

  def move_wire("L" <> steps, positions) do
    steps_int = String.to_integer(steps)
    positions
      |> List.last()
      |> (fn [x, y] -> positions ++ Enum.map(x-1..(x - steps_int), &([&1, y])) end).()
  end

  def move_wire("U" <> steps, positions) do
    steps_int = String.to_integer(steps)
    positions
      |> List.last()
      |> (fn [x, y] -> positions ++ Enum.map(y+1..(y + steps_int), &([x, &1])) end).()
  end

  def move_wire("D" <> steps, positions) do
    steps_int = String.to_integer(steps)
    positions
      |> List.last()
      |> (fn [x, y] -> positions ++ Enum.map(y-1..(y - steps_int), &([x, &1])) end).()
  end

  def run do
    [wire1, wire2] = get_puzzle_input()
    get_proximity_to_closest_intersection(wire1, wire2)
  end

  def run2 do
    [wire1, wire2] = get_puzzle_input()

    get_steps_to_closest_intersection(wire1, wire2)
  end
end

# IO.inspect(Three.run())
# IO.inspect(Three.run2())
