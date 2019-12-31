defmodule RAM do
  defp opcode_to_readable(1), do: {:add, 2}
  defp opcode_to_readable(2), do: {:multiply, 2}
  defp opcode_to_readable(3), do: {:store_user_input, 0}
  defp opcode_to_readable(4), do: {:output, 1}
  defp opcode_to_readable(5), do: {:jump_if_non_zero, 2}
  defp opcode_to_readable(6), do: {:jump_if_zero, 2}
  defp opcode_to_readable(7), do: {:store_1_if_lt, 2}
  defp opcode_to_readable(8), do: {:store_1_if_eq, 2}
  defp opcode_to_readable(9), do: {:incr_relative_base, 1}
  defp opcode_to_readable(99), do: {:exit, 0}

  def get_args_from_computer(%{:memory => memory, :index => index} = computer, no_of_args) do
    IO.inspect(index, label: "index", charlists: :as_lists)
    args = memory |> Enum.slice(index, no_of_args)
    IO.inspect(args, label: "args", charlists: :as_lists)
    {args, inc_cursor(computer, no_of_args)}
  end

  def inc_cursor(computer, step), do: Map.update!(computer, :index, &(&1 + step))

  def get_next_instruction(computer) do
    # IO.inspect(Map.get(computer, :memory), charlists: :as_lists)
    {modes, opcode} = Map.get(computer, :memory)
      |> Enum.at(Map.get(computer, :index))
      |> Integer.digits()
      |> Enum.split(-2)
    computer = inc_cursor(computer, 1)
    opcode
      |> Integer.undigits()
      |> opcode_to_readable()
      |> IO.inspect(label: "OPcode", charlists: :as_lists)
      |> case do
        {code, no_of_input_args} when code in [:add, :multiply, :store_1_if_lt, :store_1_if_eq] ->
          {[arg1, arg2], computer} = computer
            |> get_args_from_computer(2)
            |> arguments_to_values(Enum.slice(modes, -no_of_input_args, no_of_input_args))

          {store_in_position, computer} = computer
            |> get_args_from_computer(1)
            |> arguments_to_output_pos(Enum.at(modes, -3, 0))

          {code, arg1, arg2, store_in_position, computer}
        {:store_user_input, _} ->
          {store_in_position, computer} = computer
            |> get_args_from_computer(1)
            |> arguments_to_output_pos(List.first(modes))

            {:store_user_input, store_in_position, computer}
        {code, no_of_input_args} when code in [:output, :incr_relative_base] ->
          {[value], computer} = computer
            |> get_args_from_computer(no_of_input_args)
            |> arguments_to_values(Enum.slice(modes, -no_of_input_args, no_of_input_args))

          {code, value, computer}
        {code, no_of_input_args} when code in [:jump_if_non_zero, :jump_if_zero] ->
          {[number_to_compare, jump_pos], computer} = computer
            |> get_args_from_computer(no_of_input_args)
            |> arguments_to_values(Enum.slice(modes, -no_of_input_args, no_of_input_args))

          {code, number_to_compare, jump_pos, computer}
        {:exit, _} -> {:exit, computer}
        end
  end

  def arguments_to_output_pos({[arg], computer}, nil), do: arguments_to_output_pos({[arg], computer}, 0)
  def arguments_to_output_pos({[arg], computer}, mode) do
    case mode do
      0 -> {arg, computer}
      2 -> {computer[:relative_base] + arg, computer}
    end
    |> (fn u ->
      IO.inspect(elem(u, 0), label: "output pos")
      u
    end).()
  end

  def arguments_to_values({args, computer}, []), do: arguments_to_values({args, computer}, [0])
  def arguments_to_values({args, computer}, modes) do
    IO.inspect(args, label: "args", charlists: :as_lists)
    IO.inspect(modes, label: "modes", charlists: :as_lists)
    values = List.duplicate(0, Enum.count(args) - Enum.count(modes))
      |> Enum.concat(modes)
      |> Enum.reverse()
      |> Enum.zip(args)
      # |> IO.inspect(label: "Modes and values", charlists: :as_lists)
      |> Enum.map(fn
        {0 = _mode, digit} -> Enum.at(Map.get(computer, :memory, :none), digit)
        {1 = _mode, digit} -> digit
        {2 = _mode, digit} -> Enum.at(Map.get(computer, :memory), digit + Map.get(computer, :relative_base))
      end)
    IO.inspect(values, label: "vaalues", charlists: :as_lists)
    {values, computer}
  end

  def extend_memory(memory), do: Enum.concat(memory, List.duplicate(0, 10000000))
  # def extend_memory(memory), do: Enum.concat(memory, List.duplicate(0, 100000))
end
