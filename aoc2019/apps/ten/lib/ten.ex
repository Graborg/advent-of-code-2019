defmodule Ten do
  def map_to_detections(input) do
    input
    |> String.replace(~r{\s}, "")
    |> String.split("", trim: true)
    |> get_asteroids_in_blockable_paths()
  end
  def get_asteroid_coordinates(asteroid_map) do
    asteroid_map
    |> Enum.with_index()
    |> Enum.filter(fn {sign, _index} -> sign == "#" end)
    |> Enum.map(fn {_, index} -> index end)
    |> Enum.map(&index_to_coordinates/1)
  end
  def get_asteroids_in_blockable_paths(asteroid_map) do
    get_asteroid_coordinates(asteroid_map)
      |> Enum.map(fn {x_1, y_1} = asteroid_1 ->
        IO.inspect(asteroid_1, label: "asteroid")
        get_asteroid_coordinates(asteroid_map)
          |> Enum.map( fn {x_2, y_2} -> {x_2 - x_1, y_2 - y_1}  end)
          |> Enum.filter(fn e -> e != {0, 0} end)
          # |> IO.inspect()
          |> Enum.map(fn {x_changer, y_changer} ->
            gcd = Integer.gcd(x_changer, y_changer)
            smallest_x_changer = Integer.floor_div(x_changer, gcd)
            smallest_y_changer = Integer.floor_div(y_changer, gcd)
            # IO.inspect({smallest_x_changer, smallest_y_changer}, label: "changer")
            # IO.inspect({x_1 + x_changer + smallest_x_changer, y_1 + y_changer + smallest_y_changer }, label: "startpos")
            get_asteroids_in_blockable_paths(asteroid_map, {x_1 + x_changer + smallest_x_changer, y_1 + y_changer + smallest_y_changer }, {x_changer, y_changer}, [])
            |> Enum.filter(fn e -> e != nil end)
          end)
          |> Enum.filter(fn e -> !Enum.empty?(e) end)
          |> List.flatten()
          |> Enum.into(MapSet.new())
          |> IO.inspect(label: "blocking things")
          |> Enum.count()
        end)
        |> Enum.map(fn blocked_asteroids -> 9 - blocked_asteroids end)
        |> IO.inspect()
  end

  def get_asteroids_in_blockable_paths(asteroid_map, {x, y}, _, asteroids) when x < 0 or y < 0 or x > 4 or y > 4, do: asteroids
  def get_asteroids_in_blockable_paths(asteroid_map, {x, y}, {x_changer, y_changer} = changer, asteroids_blocked) do
    new_asteroid_blocked = asteroids_in_position(asteroid_map, {x, y})
    asteroid_map
      |> get_asteroids_in_blockable_paths({x + x_changer, y + y_changer}, changer, List.insert_at(asteroids_blocked, -1, new_asteroid_blocked))
  end
  def asteroids_in_position(asteroid_map, coordinates) do
    Enum.at(asteroid_map, coordinates_to_index(coordinates))
      |> Kernel.==("#")
      |> case do
        true -> coordinates
        false -> nil
      end
  end

  def coordinates_to_index({x, y}), do: x + y * 5
  def index_to_coordinates(index), do: {rem(index, 5), div(index, 5)}
end
