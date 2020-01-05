defmodule Computer do
  def default_stop_condition(_), do: false
  defstruct memory: [], user_input: [], index: 0, relative_base: 0, outputs: [], stop_condition: &Computer.default_stop_condition/1

  def init_computer(memory, user_input, stop_conditon) do
    %Computer{}
      |> Map.put(:memory, memory |> RAM.extend_memory())
      |> Map.put(:user_input, user_input)
      |> Map.put(:stop_condition, stop_conditon)
  end

  def init_computer(memory, user_input) do
    %Computer{}
      |> Map.put(:memory, memory |> RAM.extend_memory())
      |> Map.put(:user_input, user_input)
  end

  def check_stop_condition(computer) do
    stop_condition = Map.get(computer, :stop_condition)
    case stop_condition.(computer) do
      true -> :exit
      false -> :ok
    end
  end

  def run(%Computer{} = computer, user_input), do: Map.put(computer, :user_input, user_input) |> do_run()
  def run(memory, user_input), do: do_run(init_computer(memory, user_input))

  def do_run(computer) do
    with :ok <- check_stop_condition(computer)
      do
        computer
        |> RAM.get_next_instruction()
        |> CPU.execute()
        |> (fn
          %{ :status => :ok, :computer => computer } -> do_run(computer)
          %{ :status => :exit, :computer => computer} -> {:halt, computer}
        end).()
      else
        :exit -> {:stopped_with_condition, computer}
      end
  end
end

