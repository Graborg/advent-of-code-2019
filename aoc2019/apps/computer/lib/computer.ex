defmodule Computer do
  def execute({99, memory}, _, _), do: {:exit, memory}

  def execute({1, arg1, arg2, storage_pos, index}, memory, _) do
    IO.puts("inserting #{arg1 + arg2} at #{storage_pos}, currently at that position is: #{Enum.at(memory, storage_pos)} \n ")
    ans = arg1 + arg2
    store(memory, ans, storage_pos, index)
  end

  def execute({2, arg1, arg2, storage_pos, index}, memory, _) do
    IO.puts("inserting #{arg1 * arg2} at #{storage_pos}, currently at that position is: #{Enum.at(memory, storage_pos)} \n ")
    ans = arg1 * arg2
    store(memory, ans, storage_pos, index)
  end

  # Take user input and store at storage_pos
  def execute({3, storage_pos, index}, memory, [user_instruction | rest_of_instructions]) do
    memory
      |> List.replace_at(storage_pos, user_instruction)
      |> case do updated_list ->

        IO.inspect("inserted user input #{Enum.at(updated_list, storage_pos)} at #{storage_pos}")
        {:ok, updated_list, index, rest_of_instructions}
      end
  end

  # print the value
  def execute({4, value, updated_index}, memory, _) do
    IO.puts("OUTPUT! #{value}\n\n\n")

    {:output, memory, updated_index, value}
  end


  # jump to jump_position if value is non-zero
  def execute({5, 0, _jump_position, index}, memory, _), do: {:ok, memory, index}
  def execute({5, _value, jump_position, _index}, memory, _), do: {:ok, memory, jump_position}

  # jump to jump_position if value1 is zero
  def execute({6, 0, jump_position, _index}, memory, _), do: {:ok, memory, jump_position}
  def execute({6, _value, _jump_position, index}, memory, _), do: {:ok, memory, index}

  # 1 in memory if v1 less than v2 (otherwise 0)
  def execute({7, v1, v2, storage_pos, index}, memory, _) when v1 < v2, do: store(memory, 1, storage_pos, index)
  def execute({7, _, _, storage_pos, index}, memory, _), do: store(memory, 0, storage_pos, index)

  # 1 in memory v1 equals v2 (otherwise 0)
  def execute({8, v1, v2, storage_pos, index}, memory, _) when v1 == v2, do: store(memory, 1, storage_pos, index)
  def execute({8, _, _, storage_pos, index}, memory, _), do: store(memory, 0, storage_pos, index)

  def store(memory, value, storage_pos, index) do
    memory
    |> List.replace_at(storage_pos, value)
    |> case do updated_list ->
      IO.puts("inserted #{Enum.at(updated_list, storage_pos)} at #{storage_pos}")
      {:ok, updated_list, index}
    end
  end

  def get_arguments(memory, index) do
    {modes, opcode} = memory
      |> Enum.at(index)
      |> Integer.digits()
      |> Enum.split(-2)
    index = index + 1

    opcode
    |> Integer.undigits()
    |> IO.inspect(label: "OPcode")
    |> case do
      code when code in [1, 2, 7, 8] ->
        IO.inspect(Enum.slice(memory, index-1, 4), label: "grabbing 4")
        [arg1, arg2] = Enum.slice(memory, index, 2) |> arguments_to_values(modes, memory)
        output = Enum.at(memory, index + 2)

        {code, arg1, arg2, output, index + 3}
      3 -> {3, Enum.at(memory, index), index + 1}
      4 ->
        IO.inspect(Enum.slice(memory, index-1, 2), label: "grabbing 2")
        [arg] = Enum.slice(memory, index, 1) |> arguments_to_values(modes, memory)
        {4, arg, index + 1}
      code when code in [5, 6] ->
        IO.inspect(Enum.slice(memory, index-1, 3), label: "grabbing 3")
        [number_to_compare, jump_pos] = Enum.slice(memory, index, 3) |> arguments_to_values(modes, memory)
        {code, number_to_compare, jump_pos, index + 2}
      99 -> {99, memory}
      end
  end

  def arguments_to_values(args, [], memory), do: arguments_to_values(args, [0], memory)

  def arguments_to_values(args, modes, memory) do
    List.duplicate(0, 2 - Enum.count(modes))
      |> Enum.concat(modes)
      |> Enum.reverse()
      |> Enum.zip(args)
      |> IO.inspect(label: "Modes and values")
      |> Enum.map(fn
        {0 = _mode, digit} -> Enum.at(memory, digit)
        {1 = _mode, digit} -> digit
      end)
  end

  def calculate(memory, user_input), do: calculate(memory, user_input, 0)

  def calculate(memory, user_input, index) do
    IO.inspect(user_input, label: "user_input", charlists: :as_lists)
    memory
      |> get_arguments(index)
      |> IO.inspect(label: "{op, arg1, (arg2), (output-arg), index}")
      |> execute(memory, user_input)
      |> (fn
        { :ok, updated_memory, updated_index, updated_user_input } -> calculate(updated_memory, updated_user_input, updated_index)
        { :ok, updated_memory, updated_index } -> calculate(updated_memory, user_input, updated_index)
        { :output, updated_memory, updated_index, value} -> { updated_memory, updated_index, value }
        { :exit, memory } -> { :exit, memory }
      end).()
  end
end

