defmodule One do
  def get_puzzle_input do
    with {:ok, body} <- File.read("input.json"),
         {:ok, json} <- Poison.decode(body), do: json

  end

  def run do
    get_puzzle_input()
    |> Enum.map(&get_fuel_requirement/1)
    |> Enum.sum()
  end

  def run_part_two do
    get_puzzle_input()
    |> Enum.map(&get_fuel_requirement_including_fuel_of_fuel/1)
    |> Enum.sum()
  end

  # take its mass, divide by three, round down, and subtract 2.
  def get_fuel_requirement(mass) do
    mass
    |> Kernel.div(3)
    |> Decimal.round(0, :down)
    |> Decimal.to_integer()
    |> Kernel.-(2)
  end

  def get_fuel_requirement_including_fuel_of_fuel(mass) when mass <= 0, do: 0

  def get_fuel_requirement_including_fuel_of_fuel(mass) do
    get_fuel_requirement(mass)
    |> add_fuel_of_fuel()
  end

  defp add_fuel_of_fuel(fuel) when fuel <= 0, do: 0

  defp add_fuel_of_fuel(fuel) do
    fuel + get_fuel_requirement_including_fuel_of_fuel(fuel)
  end
end
# IO.inspect(One.run())
IO.inspect(One.run_part_two())
