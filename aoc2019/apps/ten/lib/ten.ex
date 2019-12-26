defmodule Ten do
  def asteroid_map_size(asteroid_map), do: asteroid_map |> String.split("\n") |> List.first() |> String.length()

  def get_best_asteroid(), do: Utilities.get_puzzle_input() |> get_best_asteroid()
  def get_best_asteroid(input) do
    map_size = asteroid_map_size(input)
    asteroids = input |> get_asteroid_coordinates(map_size)
    asteroids
      |> get_asteroids_blocked_asteroids(map_size)
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

  def get_asteroids_blocked_asteroids(asteroids, map_size) do
    asteroids
      |> Enum.map(fn {x_1, y_1} ->
        # IO.inspect(asteroid_1, label: "\nasteroid")
        asteroids
          |> Enum.map( fn {x_2, y_2} -> {x_2 - x_1, y_2 - y_1}  end)
          |> Enum.filter(fn e -> e != {0, 0} end)
          # |> IO.inspect()
          |> Enum.map(fn {x_changer, y_changer} ->
            gcd = Integer.gcd(x_changer, y_changer)
            smallest_x_changer = Integer.floor_div(x_changer, gcd)
            smallest_y_changer = Integer.floor_div(y_changer, gcd)
            # IO.inspect({smallest_x_changer, smallest_y_changer}, label: "changer")
            # IO.inspect({x_1 + x_changer + smallest_x_changer, y_1 + y_changer + smallest_y_changer }, label: "startpos")
            get_asteroids_in_blockable_paths(asteroids, {x_1 + x_changer + smallest_x_changer, y_1 + y_changer + smallest_y_changer }, {smallest_x_changer, smallest_y_changer}, [], map_size)
            |> Enum.filter(fn e -> e != nil end)
          end)
          |> Enum.filter(fn e -> !Enum.empty?(e) end)
          |> List.flatten()
          # |> IO.inspect(label: "blocking things")
          |> Enum.into(MapSet.new())
          # |> IO.inspect(label: "blocking things")
          |> Enum.count()
        end)

  end

  def get_asteroids_in_blockable_paths(_asteroids, {x, y}, _, asteroids, map_size) when x < 0 or y < 0 or x >= map_size or y >= map_size, do: asteroids
  def get_asteroids_in_blockable_paths(asteroids, {x, y}, {x_changer, y_changer} = changer, asteroids_blocked, map_size) do
    new_asteroid_blocked = asteroids_in_position(asteroids, {x, y}, map_size)
    asteroids
      |> get_asteroids_in_blockable_paths({x + x_changer, y + y_changer}, changer, List.insert_at(asteroids_blocked, -1, new_asteroid_blocked), map_size)
  end

  def asteroids_in_position(asteroids, coordinates, map_size) do
    Enum.any?(asteroids, fn asteroid -> asteroid == coordinates end)
      |> case do
        true -> coordinates
        false -> nil
      end
  end

  def coordinates_to_index({x, y}, map_size), do: x + y * map_size
  def index_to_coordinates(index, map_size), do: {rem(index, map_size), div(index, map_size)}
end
