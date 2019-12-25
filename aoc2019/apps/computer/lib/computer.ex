defmodule Computer do
  defp init_computer(memory, user_input) do
    Map.new()
      |> Map.put(:memory, memory |> RAM.extend_memory())
      |> Map.put(:user_input, user_input)
      |> Map.put(:index, 0)
      |> Map.put(:relative_base, 0)
  end

  def run(memory, user_input), do: run(init_computer(memory, user_input))
  def run(computer) do
    computer
      |> RAM.get_next_instruction()
      |> CPU.execute()
      |> (fn
        %{ :status => :ok, :computer => computer } -> run(computer)
        %{ :status => :exit, :computer => computer} -> {computer[:memory], computer[:latest_output]}
      end).()
  end
end

