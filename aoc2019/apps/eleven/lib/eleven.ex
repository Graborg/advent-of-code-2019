defmodule Eleven do
  # Eleven.paint_hull()
  def paint_hull() do
    hull = {{0, 0}, "N", %{}}
    computer = Utilities.get_puzzle_input() |> Computer.init_computer([], fn computer -> Enum.count(Map.get(computer, :outputs)) == 2 end)
    with {:stopped_with_condition, upd_computer} <- Computer.run(computer, [1])
      do
        upd_computer
          |> interpret_output(hull)
          |> update_input()
          |> paint_hull()
          # |> visualize_hull()
      end
  end

  def paint_hull({computer, {position, _, hull_map} = hull}) do
    # Process.sleep(300)
    # IO.puts("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n")
    input = hull_map |> Map.get(position, 0) |> List.wrap()
    with {:stopped_with_condition, computer} <- Computer.run(computer, input)
      do
        computer
        |> interpret_output(hull)
        # |> visualize_hull()
        |> update_input()
        |> paint_hull()
      else
        {:halt, _} ->
          hull_map
          visualize_hull({computer, hull})
      end
  end

  def update_input({computer, {pos, dir, hull_map}}) do
    color_in_pos = Map.get(hull_map, pos, 0)
    computer
      |> Map.put(:user_input, [color_in_pos])
      |> Map.put(:outputs, [color_in_pos])
    # if color_in_pos == 0, do: IO.puts("\n IT IS BLACK"), else: IO.puts("\n IT IS WHITE")
    {computer, {pos, dir, hull_map}}
  end
  def visualize_hull({_, {pos, _dir, hull_map}} = hull) do
    # IO.inspect(hull_map)
    # Enum.reduce(0..6, [], fn mul, acc  -> Enum.map(0..42, &(&1 + 100*mul)) |> Enum.map(fn i -> {i, 0} end) |> Enum.concat(acc) end)
    missing = Enum.reduce(0..6, [], fn mul, acc  -> Enum.map(0..42, &(&1 + 100*mul)) |> Enum.concat(acc) end) |> MapSet.new()
    |> MapSet.difference(hull_map |> Enum.to_list() |> Enum.map(fn {{x, y}, _color} -> x + 100*y end) |> MapSet.new())
    |> Enum.map(fn i -> {i, 0} end)
    hull_map
    |> Enum.to_list()
    |> Enum.map(fn {{x, y}, color} -> {x + 100*y, color} end)
    |> Enum.concat(missing)
    |> Enum.sort(fn {coord1, _}, {coord2, _} -> coord1 < coord2 end)
    # |> Enum.each(&IO.inspect/1)
    |> Enum.map(fn {_, color} -> color end)
    |> Enum.map(&black_or_white/1)
    |> Enum.chunk_every(43)
    |> IO.inspect(label: "lol")
    |> Enum.map(&Enum.join/1)
    |> Enum.join("\n")
      # |> List.insert_at(-1, {pos, 2})
      # |> Enum.group_by(fn {pos, _} -> pos |> elem(1) end, fn {pos, color} -> {elem(pos, 0), color} end)
      # |> Map.values()
      # |> (fn values -> Enum.map(values, &fill_indices(values, &1)) end).()
      # |> IO.inspect()
      # |> Enum.map(fn row -> Enum.sort(row, &(elem(&1, 0) < elem(&2, 0))) end)
      # |> Enum.map(fn row -> Enum.map(row, &(%{elem(&1, 0) => elem(&1, 1)})) end)
      # |> Enum.map(fn row -> Enum.reduce(row, %{}, &Map.merge/2) end)
      # |> IO.inspect()
      # |> Enum.map(fn row -> Map.values(row) |> Enum.map(&black_or_white/1) end)
      |> (fn str -> IO.write(str) end).()
      # |> Enum.map(&Enum.into(&1, Map.new()))
    hull
  end

  def fill_indices(enum, row) do
    {min, max} = enum
    |> List.flatten()
    |> Enum.map(&(elem(&1, 0)))
    |> Enum.min_max()
    min..max
      |> Enum.filter(fn filler_x -> Enum.find(row, &(elem(&1, 0) != filler_x)) end)
      |> Enum.map(fn x -> {x, 0} end)
      |> MapSet.new()
      |> MapSet.union(MapSet.new(row))
      |> Enum.to_list()
  end

  def black_or_white(0), do: IO.ANSI.blue_background() <> IO.ANSI.black() <> "[]" <> IO.ANSI.reset()
  def black_or_white(1), do: IO.ANSI.blue_background() <> IO.ANSI.white() <> "[]" <> IO.ANSI.reset()
  def black_or_white(2), do: IO.ANSI.blue_background() <> IO.ANSI.green() <> "[]" <> IO.ANSI.reset()



  def interpret_output(computer, {position, direction, hull_map}) do
    {[color | turn], upd_computer} = Map.get_and_update(computer, :outputs, fn current -> {current, []} end)

    # if color == 0, do: IO.puts("\n I HAVE PAINTED IT BLACK"), else: IO.puts("\n I HAVE PAINTED IT WHITE")
    {upd_position, upd_direction} = update_position(position, direction, turn)
    # if turn == [0], do: IO.puts("\n turn LEFT"), else: IO.puts("\n turn RIGHT")
    {upd_computer, {upd_position, upd_direction, Map.put(hull_map, position, color)}}
  end

  def update_position({x, y}, "N", [0]), do: {{x - 1, y}, "W"}
  def update_position({x, y}, "W", [0]), do: {{x, y + 1}, "S"}
  def update_position({x, y}, "S", [0]), do: {{x + 1, y}, "E"}
  def update_position({x, y}, "E", [0]), do: {{x, y - 1}, "N"}

  def update_position({x, y}, "N", [1]), do: {{x + 1, y}, "E"}
  def update_position({x, y}, "E", [1]), do: {{x, y + 1}, "S"}
  def update_position({x, y}, "S", [1]), do: {{x - 1, y}, "W"}
  def update_position({x, y}, "W", [1]), do: {{x, y - 1}, "N"}
end
