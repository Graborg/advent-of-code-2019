defmodule Computer do
  def execute({:exit, memory}, _, _, _), do: %{:status => :exit, :memory => memory}

  def execute({:add, arg1, arg2, storage_pos, index}, memory, _, _) do
    # IO.puts("inserting #{arg1 + arg2} at #{storage_pos}, currently at that position is: #{Enum.at(memory, storage_pos)} \n ")
    ans = arg1 + arg2
    store(memory, ans, storage_pos, index)
  end

  def execute({:multiply, arg1, arg2, storage_pos, index}, memory, _, _) do
    # IO.puts("inserting #{arg1 * arg2} at #{storage_pos}, currently at that position is: #{Enum.at(memory, storage_pos)} \n ")
    ans = arg1 * arg2
    store(memory, ans, storage_pos, index)
  end

  # Take user input and store at storage_pos
  def execute({:store_user_input, storage_pos, index}, memory, [user_instruction | rest_of_instructions], _) do
    memory
      |> List.replace_at(storage_pos, user_instruction)
      |> case do updated_list ->
        # IO.inspect("inserted user input #{Enum.at(updated_list, storage_pos)} at #{storage_pos}")
        %{ :status => :ok, :memory => updated_list, :index => index, :user_input => rest_of_instructions}
      end
  end

  # print the value
  def execute({:output, value, updated_index}, memory, _, _) do
    IO.puts("OUTPUT! #{value}\n\n\n")
    %{ :status => :output, :memory => memory, :index => updated_index, :value => value}
  end


  # jump to jump_position if value is non-zero
  def execute({:jump_if_non_zero, 0, _jump_position, index}, memory, _, _), do: %{ :status => :ok, :memory => memory, :index => index}
  def execute({:jump_if_non_zero, _value, jump_position, _index}, memory, _, _), do: %{ :status => :ok, :memory => memory, :index => jump_position}

  # jump to jump_position if value1 is zero
  def execute({:jump_if_zero, 0, jump_position, _index}, memory, _, _), do: %{ :status => :ok, :memory => memory, :index => jump_position}
  def execute({:jump_if_zero, _value, _jump_position, index}, memory, _, _), do: %{ :status => :ok, :memory => memory, :index => index}

  # 1 in memory if v1 less than v2 (otherwise 0)
  def execute({:store_1_if_lt, v1, v2, storage_pos, index}, memory, _, _) when v1 < v2, do: store(memory, 1, storage_pos, index)
  def execute({:store_1_if_lt, _, _, storage_pos, index}, memory, _, _), do: store(memory, 0, storage_pos, index)

  # 1 in memory v1 equals v2 (otherwise 0)
  def execute({:store_1_if_eq, v1, v2, storage_pos, index}, memory, _, _) when v1 == v2, do: store(memory, 1, storage_pos, index)
  def execute({:store_1_if_eq, _, _, storage_pos, index}, memory, _, _), do: store(memory, 0, storage_pos, index)

  def execute({:increment_relative_base, value, index}, memory, _, relative_base), do: %{ :status => :ok, :memory => memory, :index => index, :relative_base => relative_base + value }

  def store(memory, value, storage_pos, index) do
    memory
    |> List.replace_at(storage_pos, value)
    |> case do updated_list ->
      # IO.puts("inserted #{Enum.at(updated_list, storage_pos)} at #{storage_pos}")
      %{:status => :ok, :memory => updated_list, :index => index}
    end
  end

  def opcode_to_readable(1), do: :add
  def opcode_to_readable(2), do: :multiply
  def opcode_to_readable(3), do: :store_user_input
  def opcode_to_readable(4), do: :output
  def opcode_to_readable(5), do: :jump_if_non_zero
  def opcode_to_readable(6), do: :jump_if_zero
  def opcode_to_readable(7), do: :store_1_if_lt
  def opcode_to_readable(8), do: :store_1_if_eq
  def opcode_to_readable(9), do: :increment_relative_base
  def opcode_to_readable(99), do: :exit

  def get_arguments(memory, index, relative_base) do
    {modes, opcode} = memory
      |> Enum.at(index)
      |> Integer.digits()
      |> Enum.split(-2)
    index = index + 1

    opcode
    |> Integer.undigits()
    # |> IO.inspect(label: "OPcode")
    |> opcode_to_readable()
    |> case do
      code when code in [:add, :multiply, :store_1_if_lt, :store_1_if_eq] ->
        # IO.inspect(Enum.slice(memory, index-1, 4), label: "grabbing 4")
        no_of_input_arguments = 2
        [arg1, arg2] = Enum.slice(memory, index, no_of_input_arguments) |> arguments_to_values(Enum.slice(modes, -no_of_input_arguments, no_of_input_arguments), memory, relative_base)
        index = index + no_of_input_arguments
        store_in_position = memory
          |> Enum.at(index)
          |> arguments_to_output_pos(Enum.at(modes, -3, 0), relative_base)

        {code, arg1, arg2, store_in_position, index + 1}
      code when code in [:store_user_input] ->
        no_of_input_arguments = 1
        store_in_position = memory
          |> Enum.at(index)
          |> arguments_to_output_pos(List.first(modes), relative_base)
        # IO.inspect(Enum.slice(memory, index-1, 2), label: "grabbing 2 without using modes")

        {code, store_in_position, index + no_of_input_arguments}
      code when code in [:output, :increment_relative_base] ->
        # IO.inspect(Enum.slice(memory, index-1, 2), label: "grabbing 2")
        [value] = Enum.slice(memory, index, 1) |> arguments_to_values(Enum.slice(modes, -1, 1), memory, relative_base)

        {code, value, index + 1}
      code when code in [:jump_if_non_zero, :jump_if_zero] ->
        [number_to_compare, jump_pos] = Enum.slice(memory, index, 2) |> arguments_to_values(Enum.slice(modes, -2, 2), memory, relative_base)

        {code, number_to_compare, jump_pos, index + 2}
      :exit -> {:exit, memory}
      end
  end

  def arguments_to_output_pos(arg, nil, relative_base), do: arguments_to_output_pos(arg, 0, relative_base)
  def arguments_to_output_pos(arg, mode, relative_base) do
    # IO.inspect(mode, label: "arrggz")
    case mode do
      0 -> arg
      2 -> relative_base + arg
    end
  end

  def arguments_to_values(args, [], memory, relative_base), do: arguments_to_values(args, [0], memory, relative_base)

  def arguments_to_values(args, modes, memory, relative_base) do
    # IO.inspect(Enum.count(args) - Enum.count(modes), charlists: :as_lists)
    List.duplicate(0, Enum.count(args) - Enum.count(modes))
      |> Enum.concat(modes)
      |> Enum.reverse()
      |> Enum.zip(args)
      # |> IO.inspect(label: "Modes and values")
      |> Enum.map(fn
        {0 = _mode, digit} -> Enum.at(memory, digit)
        {1 = _mode, digit} -> digit
        {2 = _mode, digit} -> Enum.at(memory, digit + relative_base)
      end)
  end

  def extend_memory(memory), do: Enum.concat(memory, List.duplicate(0, 10000000))

  def calculate(memory, user_input), do: calculate(memory |> extend_memory(), user_input, 0, 0)

  def calculate(memory, user_input, index, relative_base) do
    # IO.inspect(user_input, label: "user_input", charlists: :as_lists)
    # IO.inspect(relative_base, label: "relative_base", charlists: :as_lists)
    memory
      |> get_arguments(index, relative_base)
      # |> IO.inspect(label: "{op, arg1, (arg2), (output-arg), index}")
      |> execute(memory, user_input, relative_base)
      |> (fn
        %{ :status => :ok, :memory => updated_memory, :index => updated_index, :user_input => updated_user_input } -> calculate(updated_memory, updated_user_input, updated_index, relative_base)
        %{ :status => :ok, :memory => updated_memory, :index => updated_index, :relative_base => updated_relative_base } -> calculate(updated_memory, user_input, updated_index, updated_relative_base)
        %{ :status => :ok, :memory => updated_memory, :index => updated_index } -> calculate(updated_memory, user_input, updated_index, relative_base)
        %{ :status => :output} = output -> {output[:memory], output[:value]}
        %{ :status => :exit} = output -> output[:memory]
      end).()
  end
end

