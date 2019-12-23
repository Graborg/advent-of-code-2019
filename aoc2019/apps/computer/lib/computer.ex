defmodule Computer do
  defp execute({:exit, computer}), do: %{:status => :exit, :computer => computer}
  defp execute({:add, arg1, arg2, storage_pos, computer}), do: store(computer, arg1 + arg2, storage_pos)
  defp execute({:multiply, arg1, arg2, storage_pos, computer}), do: store(computer, arg1 * arg2, storage_pos)

  # Take user input and store at storage_pos
  defp execute({:store_user_input, storage_pos, computer}) do
    [user_instruction | rest_of_instructions] = computer[:user_input]

    computer
      |> store(user_instruction, storage_pos)
      |> Map.put(:user_input, rest_of_instructions)
  end

  # print the value
  defp execute({:output, value, computer}) do
    value |> IO.inspect(label: "OUTPUT!")
    %{ :status => :ok, :computer => Map.put(computer, :latest_output, value)}
  end


  # jump to jump_position if value is non-zero
  defp execute({:jump_if_non_zero, 0, _jump_position, computer}), do: %{ :status => :ok, :computer => computer}
  defp execute({:jump_if_non_zero, _value, jump_position, computer}), do: %{ :status => :ok, :computer => Map.update!(computer, :index, fn _ -> jump_position end)}

  # jump to jump_position if value is zero
  defp execute({:jump_if_zero, 0, jump_position, computer}), do: %{ :status => :ok, :computer => Map.update!(computer, :index, fn _ -> jump_position end)}
  defp execute({:jump_if_zero, _value, _jump_position, computer}), do: %{ :status => :ok, :computer => computer}

  # 1 in memory if v1 less than v2 (otherwise 0)
  defp execute({:store_1_if_lt, v1, v2, storage_pos, computer}) when v1 < v2, do: store(computer, 1, storage_pos)
  defp execute({:store_1_if_lt, _, _, storage_pos, computer}), do: store(computer, 0, storage_pos)

  # 1 in memory v1 equals v2 (otherwise 0)
  defp execute({:store_1_if_eq, v1, v2, storage_pos, computer}) when v1 == v2, do: store(computer, 1, storage_pos)
  defp execute({:store_1_if_eq, _, _, storage_pos, computer}), do: store(computer, 0, storage_pos)

  defp execute({:incr_relative_base, value, computer}), do: %{ :status => :ok, :computer => Map.update!(computer, :relative_base, &(&1 + value))}

  defp store(computer, value, storage_pos) when is_integer(value) and is_integer(storage_pos) do
    updated_computer = Map.update!(computer, :memory, fn memory -> List.replace_at(memory, storage_pos, value) end)
    %{:status => :ok, :computer => updated_computer}
  end

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
    args = memory |> Enum.slice(index, no_of_args)
    {args, inc_cursor(computer, no_of_args)}
  end

  def inc_cursor(computer, step), do: Map.update!(computer, :index, &(&1 + step))

  def get_next_instruction(computer) do
    {modes, opcode} = computer[:memory]
      |> Enum.at(computer[:index])
      |> Integer.digits()
      |> Enum.split(-2)
    computer = inc_cursor(computer, 1)

    opcode
      |> Integer.undigits()
      |> opcode_to_readable()
      |> IO.inspect(label: "OPcode")
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
  end

  def arguments_to_values({args, computer}, []), do: arguments_to_values({args, computer}, [0])
  def arguments_to_values({args, computer}, modes) do
    values = List.duplicate(0, Enum.count(args) - Enum.count(modes))
      |> Enum.concat(modes)
      |> Enum.reverse()
      |> Enum.zip(args)
      # |> IO.inspect(label: "Modes and values")
      |> Enum.map(fn
        {0 = _mode, digit} -> Enum.at(computer[:memory], digit)
        {1 = _mode, digit} -> digit
        {2 = _mode, digit} -> Enum.at(computer[:memory], digit + computer[:relative_base])
      end)

    {values, computer}
  end

  defp extend_memory(memory), do: Enum.concat(memory, List.duplicate(0, 10000000))

  defp init_computer(memory, user_input) do
    Map.new()
      |> Map.put(:memory, memory |> extend_memory())
      |> Map.put(:user_input, user_input)
      |> Map.put(:index, 0)
      |> Map.put(:relative_base, 0)
  end

  def run(memory, user_input), do: run(init_computer(memory, user_input))
  def run(computer) do
    computer
      |> get_next_instruction()
      |> execute()
      |> (fn
        %{ :status => :ok, :computer => computer } -> run(computer)
        %{ :status => :exit, :computer => computer} -> {computer[:memory], computer[:latest_output]}
      end).()
  end
end

