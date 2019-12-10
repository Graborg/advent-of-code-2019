defmodule Five do
  # Support opcode 3 - input (param: address)
  # Support opcode 4 - output (param: address)
  # Param mode 1-3 digits
  #   support positionmode 0
  #   support immediate mode 1


  def get_puzzle_input do
    with {:ok, body} <- File.read("input.json"),
         {:ok, json} <- Poison.decode(body), do: json
  end

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
  def execute({3, storage_pos, index}, all_ints, user_input) do
    all_ints
      |> List.replace_at(storage_pos, user_input)
      |> case do updated_list ->
        IO.puts("inserted #{Enum.at(updated_list, storage_pos)} at #{storage_pos}")
        {:ok, updated_list, index}
      end
  end

  # print the value
  def execute({4, value, index}, all_ints, _) do
    IO.puts("OUTPUT! #{value}\n\n\n")
    if value != 0 do
      if (Enum.at(all_ints, index) == 99) do
        exit("nice")
      end
      exit("wrong")
    end

    {:ok, all_ints, index}
  end

  def execute({99, all_ints}, _, _), do: {:exit, all_ints}

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
      code when code in [02, 01] ->
        IO.inspect(Enum.slice(all_ints, index-1, 4), label: "grabbing 4")
        [arg1, arg2] = Enum.slice(all_ints, index, 2) |> arguments_to_values(modes, all_ints)
        output = Enum.at(all_ints, index + 2)

        {code, arg1, arg2, output, index + 3}
      3 -> {3, Enum.at(all_ints, index), index + 1}
      4 ->
        IO.inspect(Enum.slice(all_ints, index-1, 2), label: "grabbing 2")
        [arg] = Enum.slice(all_ints, index, 1) |> arguments_to_values(modes, all_ints)
        {4, arg, index + 1}
      9 -> {99, all_ints}
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
    memory
      |> get_arguments(index)
      |> IO.inspect(label: "{op, arg1, (arg2), (output-arg), index}")
      |> execute(memory, user_input)
      |> (fn
        { :ok, updated_memory, updated_index } -> calculate(updated_memory, user_input, updated_index)
        { :exit, memory } -> memory
      end).()
  end

  def run_program_with_input(diagnostic_program, user_input) do
    calculate(diagnostic_program, user_input)
  end

end
