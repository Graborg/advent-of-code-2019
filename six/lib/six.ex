defmodule Six do
  def get_puzzle_input do
    with {:ok, body} <- File.read("input.json"),
         {:ok, json} <- Poison.decode(body), do: json
  end

  def get_nr_orbits(data) do
    map = data
      |> Enum.reduce(%{}, &insert_in_map/2)
      |> IO.inspect()

    orbitees = Map.values(map) |> List.flatten()
    leaf_orbiter = Map.keys(map)
      |> IO.inspect()
      |> Enum.map( fn orbiter -> count_orbitees(orbiter, map)end)
      |> Enum.sum()
      |> IO.inspect()
  end

  def count_orbitees(orbiter, map) do
    Map.get(map, orbiter, [])
      |> Enum.map(fn orbiter -> count_orbitees(orbiter, map)end)
      |> Enum.sum()
      |> Kernel.+(Map.get(map, orbiter, []) |> Enum.count())
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
end
