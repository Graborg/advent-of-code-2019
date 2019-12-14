defmodule Seven do
  def get_puzzle_input do
    with {:ok, body} <- File.read("input.json"),
         {:ok, json} <- Poison.decode(body), do: json
  end

  def execute({99, all_ints}, _, _), do: {:exit, all_ints}

  def execute({1, arg1, arg2, storage_pos, index}, all_ints, _) do
    IO.puts("inserting #{arg1 + arg2} at #{storage_pos}, currently at that position is: #{Enum.at(all_ints, storage_pos)} \n ")
    ans = arg1 + arg2
    all_ints
      |> List.replace_at(storage_pos, ans)
      |> case do updated_list ->
        {:ok, updated_list, index}
      end
  end

  def execute({2, arg1, arg2, storage_pos, index}, all_ints, _) do
    IO.puts("inserting #{arg1 * arg2} at #{storage_pos}, currently at that position is: #{Enum.at(all_ints, storage_pos)} \n ")
    ans = arg1 * arg2
    all_ints
      |> List.replace_at(storage_pos, ans)
      |> case do updated_list ->
        {:ok, updated_list, index}
      end
  end

  # Take user input and store at storage_pos
  def execute({3, storage_pos, index}, all_ints, [user_instruction | rest_of_instructions]) do
    all_ints
      |> List.replace_at(storage_pos, user_instruction)
      |> case do updated_list ->

        IO.puts("inserted user input #{Enum.at(updated_list, storage_pos)} at #{storage_pos}")
        {:ok, updated_list, index, rest_of_instructions}
      end
  end

  # print the value
  def execute({4, value, _index}, _all_ints, _) do
    IO.puts("OUTPUT! #{value}\n\n\n")

    {:exit, value}
  end


  # jump to jump_position if value is non-zero
  def execute({5, 0, _jump_position, index}, all_ints, _), do: {:ok, all_ints, index}
  def execute({5, _value, jump_position, _index}, all_ints, _), do: {:ok, all_ints, jump_position}

  # jump to jump_position if value1 is zero
  def execute({6, 0, jump_position, _index}, all_ints, _), do: {:ok, all_ints, jump_position}
  def execute({6, _value, _jump_position, index}, all_ints, _), do: {:ok, all_ints, index}

  # 1 in memory if v1 less than v2 (otherwise 0)
  def execute({7, v1, v2, storage_pos, index}, all_ints, _) when v1 < v2, do: store(all_ints, 1, storage_pos, index)
  def execute({7, _, _, storage_pos, index}, all_ints, _), do: store(all_ints, 0, storage_pos, index)

  # 1 in memory v1 equals v2 (otherwise 0)
  def execute({8, v1, v2, storage_pos, index}, all_ints, _) when v1 == v2, do: store(all_ints, 1, storage_pos, index)
  def execute({8, _, _, storage_pos, index}, all_ints, _), do: store(all_ints, 0, storage_pos, index)

  def store(memory, value, storage_pos, index) do
    memory
    |> List.replace_at(storage_pos, value)
    |> case do updated_list ->
      IO.puts("inserted #{Enum.at(updated_list, storage_pos)} at #{storage_pos}")
      {:ok, updated_list, index}
    end
  end


  def get_arguments(all_ints, index) do
    {modes, opcode} = all_ints
      |> Enum.at(index)
      |> Integer.digits()
      |> Enum.split(-2)
    index = index + 1

    opcode
    |> Integer.undigits()
    |> IO.inspect(label: "OPcode")
    |> case do
      code when code in [1, 2, 7, 8] ->
        IO.inspect(Enum.slice(all_ints, index-1, 4), label: "grabbing 4")
        [arg1, arg2] = Enum.slice(all_ints, index, 2) |> arguments_to_values(modes, all_ints)
        output = Enum.at(all_ints, index + 2)

        {code, arg1, arg2, output, index + 3}
      3 -> {3, Enum.at(all_ints, index), index + 1}
      4 ->
        IO.inspect(Enum.slice(all_ints, index-1, 2), label: "grabbing 2")
        [arg] = Enum.slice(all_ints, index, 1) |> arguments_to_values(modes, all_ints)
        {4, arg, index + 1}
      code when code in [5, 6] ->
        IO.inspect(Enum.slice(all_ints, index-1, 3), label: "grabbing 3p")
        [number_to_compare, jump_pos] = Enum.slice(all_ints, index, 3) |> arguments_to_values(modes, all_ints)
        {code, number_to_compare, jump_pos, index + 2}
      99 -> {99, all_ints}
      end
  end

  def arguments_to_values(args, [], all_ints), do: arguments_to_values(args, [0], all_ints)

  def arguments_to_values(args, modes, all_ints) do
    List.duplicate(0, 2 - Enum.count(modes))
      |> Enum.concat(modes)
      |> Enum.reverse()
      |> Enum.zip(args)
      |> IO.inspect(label: "Modes and values")
      |> Enum.map(fn
        {0 = _mode, digit} -> Enum.at(all_ints, digit)
        {1 = _mode, digit} -> digit
      end)
  end

  def calculate(ints, user_input), do: calculate(ints, user_input, 0)

  def calculate(memory, user_input, index) do
    IO.inspect(user_input, label: "user_input")
    memory
      |> get_arguments(index)
      |> IO.inspect(label: "{op, arg1, (arg2), (output-arg), index}")
      |> execute(memory, user_input)
      |> (fn
        { :ok, updated_memory, updated_index, updated_user_input } -> calculate(updated_memory, updated_user_input, updated_index)
        { :ok, updated_memory, updated_index } -> calculate(updated_memory, user_input, updated_index)
        { :exit, memory } -> memory
      end).()
  end

  def run_amplifiers(computer, phase_settings) do
    Enum.reduce(0..4, 0, fn
      amp_number, output -> run_amplifier(computer, output, Enum.at(phase_settings, amp_number))
    end)
  end

  def run_amplifier(computer, input, phase_setting) do
    IO.inspect([phase_setting, input], label: "running amplifier")
    calculate(computer, [phase_setting, input])
  end

  def get_max_thruster_settings() do
    computer = get_puzzle_input()
    get_permutations()
      |> Enum.map(fn phase_settings -> run_amplifiers(computer, phase_settings) end)
      |> Enum.max()
  end

  def get_permutations(), do: get_permutations(Enum.to_list 0..4)
  def get_permutations([]), do: [[]]
  def get_permutations(list), do: for elem <- list, rest <- get_permutations(list--[elem]), do: [elem|rest]

end
