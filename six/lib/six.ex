defmodule Six do
  def get_puzzle_input do
    with {:ok, body} <- File.read("input.json"),
         {:ok, json} <- Poison.decode(body), do: json
  end

  def get_nr_orbits(data) do
    map = data |> Enum.reduce(%{}, &insert_in_map/2)

    Map.keys(map)
      |> Enum.map( fn orbiter -> count_orbitees(orbiter, map)end)
      |> Enum.map(&List.last/1)
      |> Enum.map(&(elem(&1,0)))
      |> Enum.sum()
  end

  def count_orbitees(orbiter, map), do: count_orbitees(orbiter, map, 0)

  def count_orbitees(orbiter, map, counter) do
    Map.get(map, orbiter, [])
      |> Enum.flat_map(fn orbiter -> count_orbitees(orbiter, map, counter + 1) end)
      |> case do
        [] -> [{counter, orbiter}]
        list -> List.insert_at(list, 0, {counter, orbiter})
      end
  end

  def insert_in_map(orbit, map) do
    orbit
    |> String.split(")")
    |> (fn
      [orbitee, orbiter] -> Map.update(map, orbiter, [orbitee], fn
        prev -> List.insert_at(prev, 0, orbitee)
      end)
    end).()
  end

  def get_nr_orbits_for_map_data() do
    get_puzzle_input()
      |> get_nr_orbits()
  end

  def get_min_path_to_santa() do
    get_puzzle_input()
      |> get_min_path_to_santa()
  end

  def get_min_path_to_santa(orbit_map) do
    orbit_map
      |> Enum.reduce(%{}, &insert_in_map/2)
      |> get_denominator_orbitee("YOU", "SAN")
  end

  def get_denominator_orbitee(orbit_map, orbiter1, orbiter2) do
    orbits2 = count_orbitees(orbiter2, orbit_map)

    count_orbitees(orbiter1, orbit_map)
      |> Enum.reduce_while({nil, nil}, fn
          o1, {_, nil} ->
            Enum.find(orbits2, fn o2 -> elem(o2, 1) == elem(o1, 1) end)
              |> case do o2 -> {:cont, {o1, o2}} end
          _, ans -> {:halt, ans}
        end)
    |> Tuple.to_list()
    |> Enum.map(fn tuple -> elem(tuple, 0) end)
    |> Enum.map(&(&1 - 1)) # Remove own orbit
    |> Enum.sum()
  end

end
