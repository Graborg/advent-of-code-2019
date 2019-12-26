defmodule Ten do

  def map_to_detections() do
    Utilities.get_puzzle_input()
      |> map_to_detections(36)
  end
  def map_to_detections(input, map_size) do
    input
    |> String.replace(~r{\s}, "")
    |> String.split("", trim: true)
    |> get_asteroids_in_blockable_paths(map_size)
  end

  def get_asteroid_coordinates(asteroid_map, map_size) do
    asteroid_map
    |> Enum.with_index()
    |> Enum.filter(fn {sign, _index} -> sign == "#" end)
    |> Enum.map(fn {_, index} -> index end)
    |> Enum.map(&(index_to_coordinates(&1, map_size)))
  end

  def get_asteroids_in_blockable_paths(asteroid_map, map_size) do
    asteroids = get_asteroid_coordinates(asteroid_map, map_size)

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
            get_asteroids_in_blockable_paths(asteroid_map, {x_1 + x_changer + smallest_x_changer, y_1 + y_changer + smallest_y_changer }, {smallest_x_changer, smallest_y_changer}, [], map_size)
            |> Enum.filter(fn e -> e != nil end)
          end)
          |> Enum.filter(fn e -> !Enum.empty?(e) end)
          |> List.flatten()
          # |> IO.inspect(label: "blocking things")
          |> Enum.into(MapSet.new())
          # |> IO.inspect(label: "blocking things")
          |> Enum.count()
        end)
        |> Enum.map(fn blocked_asteroids -> Enum.count(asteroids) - 1 - blocked_asteroids end)
        |> Enum.zip(asteroids)
        # |> IO.inspect()
        |> Enum.sort(fn {v1, _}, {v2, _} -> v1 > v2 end)
        |> List.first()
  end

  def get_asteroids_in_blockable_paths(_asteroid_map, {x, y}, _, asteroids, map_size) when x < 0 or y < 0 or x >= map_size or y >= map_size, do: asteroids
  def get_asteroids_in_blockable_paths(asteroid_map, {x, y}, {x_changer, y_changer} = changer, asteroids_blocked, map_size) do
    new_asteroid_blocked = asteroids_in_position(asteroid_map, {x, y}, map_size)
    # IO.inspect(new_asteroid_blocked, label: "found")
    # IO.inspect({x, y}, label: "cords")
    # IO.inspect(changer, label: "cords")
    asteroid_map
      |> get_asteroids_in_blockable_paths({x + x_changer, y + y_changer}, changer, List.insert_at(asteroids_blocked, -1, new_asteroid_blocked), map_size)
  end

  def asteroids_in_position(asteroid_map, coordinates, map_size) do
    Enum.at(asteroid_map, coordinates_to_index(coordinates, map_size))
      |> Kernel.==("#")
      |> case do
        true -> coordinates
        false -> nil
      end
  end

  def coordinates_to_index({x, y}, map_length), do: x + y * map_length
  def index_to_coordinates(index, map_length), do: {rem(index, map_length), div(index, map_length)}
end
