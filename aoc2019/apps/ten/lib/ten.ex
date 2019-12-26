defmodule Ten do
  def asteroid_map_size(asteroid_map), do: asteroid_map |> String.split("\n") |> List.first() |> String.length()

  def get_best_asteroid(), do: Utilities.get_puzzle_input() |> get_best_asteroid()
  def get_best_asteroid(input) do
    map_size = asteroid_map_size(input)
    asteroids = input |> get_asteroid_coordinates(map_size)
    asteroids
      |> Enum.map(&(get_blocked_asteroids(&1, asteroids, map_size)))
      |> Enum.map(fn blocked_asteroids -> Enum.count(asteroids) - 1 - blocked_asteroids end)
      |> Enum.zip(asteroids)
      |> Enum.sort(fn {v1, _}, {v2, _} -> v1 > v2 end)
      |> List.first()
  end

  def get_asteroid_coordinates(asteroid_map, map_size) do
    asteroid_map
      |> String.replace(~r{\s}, "")
      |> String.split("", trim: true)
      |> Enum.with_index()
      |> Enum.filter(fn {sign, _index} -> sign == "#" end)
      |> Enum.map(fn {_, index} -> index end)
      |> Enum.map(fn index ->
        index_to_coordinates(index, map_size)
      end)
  end

  def get_trajectory_between({x_1, y_1}, {x_2, y_2}) do
    {x_path, y_path} = {x_2 - x_1, y_2 - y_1}
    gcd = Integer.gcd(x_path, y_path)
    smallest_x_changer = Integer.floor_div(x_path, gcd)
    smallest_y_changer = Integer.floor_div(y_path, gcd)

    {smallest_x_changer, smallest_y_changer}
  end

  def get_blocked_asteroids({x_1, y_1} = asteroid_1, asteroids, map_size) do
    asteroids
      |> Enum.filter(fn e -> e != {x_1, y_1} end)
      |> Enum.map(fn {x_2, y_2} = asteroid_2 ->
        {x_trajectory, y_trajectory} = get_trajectory_between(asteroid_1, asteroid_2)
        get_asteroids_in_blockable_paths(asteroids, {x_2 + x_trajectory, y_2 + y_trajectory }, {x_trajectory, y_trajectory}, [], map_size)
        |> Enum.filter(fn e -> e != nil end)
      end)
      |> Enum.filter(fn e -> !Enum.empty?(e) end)
      |> List.flatten()
      |> Enum.into(MapSet.new())
      |> Enum.count()
  end

  def get_asteroids_in_blockable_paths(_asteroids, {x, y}, _, asteroids, map_size) when x < 0 or y < 0 or x >= map_size or y >= map_size, do: asteroids
  def get_asteroids_in_blockable_paths(asteroids, {x, y}, {x_changer, y_changer} = changer, asteroids_blocked, map_size) do
    new_asteroid_blocked = asteroids_in_position(asteroids, {x, y})
    asteroids
      |> get_asteroids_in_blockable_paths({x + x_changer, y + y_changer}, changer, List.insert_at(asteroids_blocked, -1, new_asteroid_blocked), map_size)
  end

  def asteroids_in_position(asteroids, coordinates), do: Enum.find(asteroids, &(&1 == coordinates))

  def coordinates_to_index({x, y}, map_size), do: x + y * map_size
  def index_to_coordinates(index, map_size), do: {rem(index, map_size), div(index, map_size)}
end
