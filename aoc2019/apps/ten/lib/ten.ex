defmodule Ten do
  defp asteroid_map_size(asteroid_map), do: asteroid_map |> String.split("\n") |> List.first() |> String.length()

  defp inc_coordinates({x_1, y_1}, {x_2, y_2}), do: {x_1 + x_2, y_1 + y_2}

  defp asteroid_at_coordinate(asteroids, coordinates), do: [Enum.find(asteroids, &(&1 == coordinates))] |> Enum.filter(&(&1))

  def coordinates_to_index({x, y}, map_size), do: x + y * map_size
  def index_to_coordinates(index, map_size), do: {rem(index, map_size), div(index, map_size)}

  defguard is_inside_map?(x, y, map_size) when x < 0 or y < 0 or x >= map_size or y >= map_size

  def get_asteroids_in_trajectory({x, y}, _, _, res, map_size) when is_inside_map?(x, y, map_size), do: res
  def get_asteroids_in_trajectory(asteroid_1, trajectory, asteroids, asteroids_blocked, map_size) do
    updated_asteroids_blocked = asteroids
      |> asteroid_at_coordinate(asteroid_1)
      |> Kernel.++(asteroids_blocked)

    asteroid_1
      |> inc_coordinates(trajectory)
      |> get_asteroids_in_trajectory(trajectory, asteroids, updated_asteroids_blocked, map_size)
  end

  def get_blocked_asteroids(asteroid_1, asteroids, map_size) do
    asteroids
      |> Enum.filter(fn asteroid_2 -> asteroid_2 != asteroid_1 end)
      |> Enum.map(fn asteroid_2 ->
        trajectory = get_trajectory_between(asteroid_1, asteroid_2)
        trajectory
          |> inc_coordinates(asteroid_2)
          |> get_asteroids_in_trajectory(trajectory, asteroids, [], map_size)
      end)
  end

  def get_trajectory_between({x_1, y_1}, {x_2, y_2}) do
    {x_path, y_path} = {x_2 - x_1, y_2 - y_1}
    gcd = Integer.gcd(x_path, y_path)
    smallest_x_changer = Integer.floor_div(x_path, gcd)
    smallest_y_changer = Integer.floor_div(y_path, gcd)

    {smallest_x_changer, smallest_y_changer}
  end

  defp get_asteroid_coordinates(asteroid_map, map_size) do
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

  def get_best_asteroid(), do: Utilities.get_puzzle_input() |> get_best_asteroid()
  def get_best_asteroid(input) do
    map_size = asteroid_map_size(input)
    asteroids = input |> get_asteroid_coordinates(map_size)

    asteroids
      |> Enum.map(&(get_blocked_asteroids(&1, asteroids, map_size)))
      |> Enum.map(&List.flatten/1)
      |> Enum.filter(fn e -> !Enum.empty?(e) end)
      |> Enum.map(&Enum.into(&1, MapSet.new()))
      |> Enum.map(&Enum.count/1)
      |> Enum.map(fn blocked_asteroids -> Enum.count(asteroids) - 1 - blocked_asteroids end)
      |> Enum.zip(asteroids)
      |> Enum.sort(fn {v1, _}, {v2, _} -> v1 > v2 end)
      |> List.first()
  end

  def get_asteroid_vaporized(), do: Utilities.get_puzzle_input() |> get_asteroid_vaporized(200, {17, 22})
  def get_asteroid_vaporized(input, nr, laser_asteroid \\ {11,13}) do
    map_size = asteroid_map_size(input)
    asteroids = input |> get_asteroid_coordinates(map_size)

    asteroids
      |> Enum.map(&(get_blocked_asteroids(&1, asteroids, map_size)))
      |> Enum.zip(asteroids)
      |> Enum.find(fn {_asteroids, asteroid} -> asteroid == laser_asteroid end)
      |> elem(0)
      |> Enum.filter(&(!Enum.empty?(&1)))
      |> Enum.concat(asteroids |> Enum.map(&List.wrap/1))
      |> filter_astroids_in_subsets()
      |> Enum.filter(&(&1 != [laser_asteroid]))
      |> Enum.map(&(add_trajectory_from_laser(&1, laser_asteroid)))
      |> Enum.map(&calculate_angle/1)
      |> Enum.group_by(&(elem(&1, 0)), fn {_angle, asteroids} -> asteroids end )
      |> Enum.sort(fn {angle_1, _}, {angle_2, _} -> angle_1 < angle_2 end)
      |> Enum.map(fn {angle, asteroids} -> {angle, List.flatten(asteroids)} end)
      |> Enum.map(fn {angle, asteroids} -> {angle, Enum.sort_by(asteroids, &distance_to_laser(laser_asteroid, &1), &<=/2)} end)
      |> shoot_them_all()
      |> Enum.at(nr - 1)
  end

  defp distance_to_laser({laser_x, laser_y}, {asteroid_x, asteroid_y}) do
    abs(laser_x + laser_y - asteroid_x - asteroid_y)
  end

  def calculate_angle({{x, y}, asteroids_coordinates}) do
    angle = case y do
      0 when x >= 0 -> 90
      y when y > 0 and x == 0 -> 180
      0 when x < 0 -> 270
      y when y < 0 and x == 0 -> 0
      y when x > 0 and y > 0 -> ElixirMath.atan(abs(y/ x)) * 180 / ElixirMath.pi() |> Kernel.+(90) # second q
      y when x < 0 and y < 0 -> ElixirMath.atan(abs(y/ x)) * 180 / ElixirMath.pi() |> Kernel.+(270) # fourth q
      y when x < 0 and y > 0 -> ElixirMath.atan(abs(x/ y)) * 180 / ElixirMath.pi() |> Kernel.+(180) # third q
      y when x > 0 and y < 0 -> ElixirMath.atan(abs(x/ y)) * 180 / ElixirMath.pi() # first q
    end
    {angle, asteroids_coordinates}
  end

  def add_trajectory_from_laser([asteroid | _rest] = asteroids_in_trajectory, laser_asteroid) do
    trajectory = get_trajectory_between(laser_asteroid, asteroid)

    {trajectory, asteroids_in_trajectory}
  end

  def shoot_them_all(asteroids), do: shoot_them_all(asteroids, 0, [])
  def shoot_them_all([], _, res), do: res
  def shoot_them_all(asteroids, index, res) do
    with {{angle, asteroids}, popped_list} <- List.pop_at(asteroids, index),
                      [in_crosshair|rest]  <- asteroids,
                      lasered_asteroids    <- List.insert_at(res, -1, in_crosshair)
      do
        case Enum.count(rest) do
          x when x > 0 -> List.insert_at(popped_list, index, {angle, rest})
            |> shoot_them_all(index + 1, lasered_asteroids)
          _ -> shoot_them_all(popped_list, index, lasered_asteroids)
        end
      else
        {nil, asteroids} ->
          shoot_them_all(asteroids, 0, res) # end of list, restart
      end
  end

  def filter_astroids_in_subsets(asteroids) do
    asteroid_mapsets = asteroids |> Enum.map(&MapSet.new/1)

    Enum.filter(asteroid_mapsets, fn blocked_asteroids ->
      asteroid_mapsets
        |> Enum.filter(&(&1 != blocked_asteroids))
        |> Enum.any?(&(MapSet.subset?(blocked_asteroids, &1)))
        |> Kernel.not()
      end)
      |> Enum.map(&MapSet.to_list/1)
      |> Enum.uniq()
  end
end
