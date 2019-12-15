defmodule IntComputer do
  def execute({99, memory}, _, _), do: {:exit, memory}

  def execute({1, arg1, arg2, storage_pos, index}, memory, _) do
    IO.puts("inserting #{arg1 + arg2} at #{storage_pos}, currently at that position is: #{Enum.at(memory, storage_pos)} \n ")
    ans = arg1 + arg2
    memory
      |> List.replace_at(storage_pos, ans)
      |> case do updated_list ->
        {:ok, updated_list, index}
      end
  end

  def execute({2, arg1, arg2, storage_pos, index}, memory, _) do
    IO.puts("inserting #{arg1 * arg2} at #{storage_pos}, currently at that position is: #{Enum.at(memory, storage_pos)} \n ")
    ans = arg1 * arg2
    memory
      |> List.replace_at(storage_pos, ans)
      |> case do updated_list ->
        {:ok, updated_list, index}
      end
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

defmodule Seven do
  def get_puzzle_input do
    with {:ok, body} <- File.read("input.json"),
         {:ok, json} <- Poison.decode(body), do: json
  end

  def get_permutations(%Range{} = amp_setting_range), do: get_permutations(Enum.to_list amp_setting_range)
  def get_permutations([]), do: [[]]
  def get_permutations(list), do: for elem <- list, rest <- get_permutations(list--[elem]), do: [elem|rest]

  defmodule AmplificationCircuit do
    def run_amplifiers(memory, phase_settings) do
      Enum.reduce(0..4, 0, fn
        amp_number, output -> run_amplifier(memory, output, Enum.at(phase_settings, amp_number))
      end)
    end

    def run_amplifier(memory, input, phase_setting) do
      IntComputer.calculate(memory, [phase_setting, input])
        |> case do
          { _, _, output } -> output
        end
    end

    def get_max_thruster_settings() do
      memory = Seven.get_puzzle_input()
      Seven.get_permutations(0..4)
        |> Enum.map(fn phase_settings -> run_amplifiers(memory, phase_settings) end)
        |> Enum.max()
    end
  end

  defmodule FeedbackAmplificationCircuit do
    alias Seven.Amplifier

    def get_max_thruster_feedback do
      memory = Seven.get_puzzle_input()
      Seven.get_permutations(5..9)
        |> get_max_thruster_feedback(memory)
    end

    def get_max_thruster_feedback(possible_phase_settings, memory) do
      possible_phase_settings
        |> Enum.map(&(get_amplifiers(memory, &1)))
        |> Enum.map(&run_amplifiers/1)
        |> Enum.max()
    end

    defp get_amplifiers(memory, phase_settings) do
      phase_settings
        |> Enum.map(fn phase_setting -> Amplifier.start_link(memory, phase_setting) end)
    end

    def run_amplifiers(amplifiers), do: run_amplifiers(0, amplifiers, 0)
    def run_amplifiers(input, amplifiers, amp_index) do
      Enum.at(amplifiers, amp_index)
        |> Amplifier.run(input)
        |> Amplifier.get_output()
        |> case do
          {:halt, output} when amp_index == 4 -> IO.inspect(output, label: "finished")
          {_status, output} -> run_amplifiers(output, amplifiers, Integer.mod(amp_index + 1, 5))
        end
    end
  end

  defmodule Amplifier do
    use Agent

    def start_link(memory, phase_setting) do
      Agent.start_link(fn -> {memory, [phase_setting], 0, nil} end)
        |> case do
          {:ok, amplifier} -> amplifier
        end
    end

    def run(amplifier, input) do
      amplifier
        |> Agent.update(fn {memory, phase_setting, i, latest_output} ->
          case IntComputer.calculate(memory, Enum.concat(phase_setting, [input]), i) do
            {:exit, _} -> {memory, [], -1, latest_output}
            { updated_memory, updated_index, output } -> { updated_memory, [], updated_index, output }
          end
        end)

        amplifier
    end

    def get_output(amplifier) do
      Agent.get(amplifier, fn
        {_,_,-1, latest_output } -> {:halt, latest_output}
        {_,_,_, latest_output } -> {:cont, latest_output}
      end)
    end
  end
end

