defmodule Computer do
  defp init_computer(memory, user_input) do
    Map.new()
      |> Map.put(:memory, memory |> RAM.extend_memory())
      |> Map.put(:user_input, user_input)
      |> Map.put(:index, 0)
      |> Map.put(:relative_base, 0)
      |> Map.put(:outputs, [])
  end

  def check_stop_condition(stop_condition, computer) do
    case stop_condition.(computer) do
      true -> :exit
      false -> :ok
    end
  end

  def run(memory, user_input, stop_condition \\ (fn e -> false end)), do: do_run(init_computer(memory, user_input), stop_condition)
  def do_run(computer, stop_condition) do
    with :ok <- check_stop_condition(stop_condition, computer)
      do
        computer
        |> RAM.get_next_instruction()
        |> CPU.execute()
        |> (fn
          %{ :status => :ok, :computer => computer } -> do_run(computer, stop_condition)
          %{ :status => :exit, :computer => computer} -> {computer[:memory], Enum.at(computer[:outputs], -1)}
        end).()
      else
        _ -> computer
      end
  end
end

