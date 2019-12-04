defmodule Two do
  def get_puzzle_input do
    with {:ok, body} <- File.read("input.json"),
         {:ok, json} <- Poison.decode(body), do: json

  end

  def execute(99, _, _e) do
    {:exit, "finished"}
  end

  def execute(1, arg1, arg2) do
    {:ok, arg1 + arg2}
  end

  def execute(2, arg1, arg2) do
    {:ok, arg1 * arg2}
  end

  def calculate(ints), do: calculate(ints, 0)

  def calculate(all_ints, index) do
    with [op, arg_pos1, arg_pos2, output_pos] <- Enum.slice(all_ints, index, 4),
        {:ok, arg1} <- Enum.fetch(all_ints, arg_pos1),
        {:ok, arg2} <- Enum.fetch(all_ints, arg_pos2),
        {:ok, ans} <- execute(op, arg1, arg2)
      do
        all_ints
        |> List.replace_at(output_pos, ans)
        |> calculate(index + 4)
    else
      [99 | _rest] -> all_ints
      {:exit, _} -> all_ints
      _ -> IO.puts("Error")
    end
  end

  def run do
    get_puzzle_input()
    |> calculate()
  end

  def run2 do
    input = get_puzzle_input()
    for noun <- 1..99, verb <- 1..99 do
      ans = input
      |> List.replace_at(1, noun)
      |> List.replace_at(2, verb)
      |> calculate()
      |> List.first()

      if ans === 19690720, do: IO.inspect("#{noun} #{verb}")

    end
  end

end

