defmodule Eight do
  def get_number_of_1_digits_mul_by_number_of_2_digits_of_layer_with_smallest_amount_of_zeroes() do
    Utilities.get_puzzle_input()
      |> create_layers(25, 6)
      |> (fn layers -> Enum.at(layers, find_layer_with_fewest_zeroes(layers)) end).()
      |> (fn layer -> [count_n_in_layer(layer, "2"), count_n_in_layer(layer, "1")] end).()
      |> Enum.reduce(fn first, res -> first * res end)
    end

  def count_n_in_layer(rows, n) do
    rows
      |> Enum.map(fn column -> Enum.count(column, &(&1 == n)) end)
      |> Enum.sum()
  end

  def find_layer_with_fewest_zeroes(layers) do
    layers
      |> Enum.map(&count_n_in_layer(&1, "0"))
      |> (fn counts ->
        Enum.find_index(counts, fn count -> count == Enum.min(counts) end)
      end).()
  end

  def create_layers(input, columns, rows) do
    input
    |> String.split("", trim: true)
    |> Enum.chunk_every(columns*rows)
    |> Enum.map(&(create_layer(&1, columns)))
  end

  def create_layer(layer_ints, columns) do
    layer_ints
      |> Enum.chunk_every(columns)
      |> List.wrap()
  end
end
