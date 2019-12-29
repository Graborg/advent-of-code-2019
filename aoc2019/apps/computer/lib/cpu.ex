defmodule CPU do
  def execute({:exit, computer}), do: %{:status => :exit, :computer => computer}
  def execute({:add, arg1, arg2, storage_pos, computer}), do: store(computer, arg1 + arg2, storage_pos)
  def execute({:multiply, arg1, arg2, storage_pos, computer}), do: store(computer, arg1 * arg2, storage_pos)

  # Take user input and store at storage_pos
  def execute({:store_user_input, storage_pos, computer}) do
    [user_instruction | rest_of_instructions] = computer[:user_input]

    computer
      |> store(user_instruction, storage_pos)
      |> Map.put(:user_input, rest_of_instructions)
  end

  # print the value
  def execute({:output, value, computer}) do
    value |> IO.inspect(label: "OUTPUT!")
    %{ :status => :ok, :computer => Map.update!(computer, :outputs, &(&1 ++ [value]))}
  end


  # jump to jump_position if value is non-zero
  def execute({:jump_if_non_zero, 0, _jump_position, computer}), do: %{ :status => :ok, :computer => computer}
  def execute({:jump_if_non_zero, _value, jump_position, computer}), do: %{ :status => :ok, :computer => Map.update!(computer, :index, fn _ -> jump_position end)}

  # jump to jump_position if value is zero
  def execute({:jump_if_zero, 0, jump_position, computer}), do: %{ :status => :ok, :computer => Map.update!(computer, :index, fn _ -> jump_position end)}
  def execute({:jump_if_zero, _value, _jump_position, computer}), do: %{ :status => :ok, :computer => computer}

  # 1 in memory if v1 less than v2 (otherwise 0)
  def execute({:store_1_if_lt, v1, v2, storage_pos, computer}) when v1 < v2, do: store(computer, 1, storage_pos)
  def execute({:store_1_if_lt, _, _, storage_pos, computer}), do: store(computer, 0, storage_pos)

  # 1 in memory v1 equals v2 (otherwise 0)
  def execute({:store_1_if_eq, v1, v2, storage_pos, computer}) when v1 == v2, do: store(computer, 1, storage_pos)
  def execute({:store_1_if_eq, _, _, storage_pos, computer}), do: store(computer, 0, storage_pos)

  def execute({:incr_relative_base, value, computer}), do: %{ :status => :ok, :computer => Map.update!(computer, :relative_base, &(&1 + value))}

  defp store(computer, value, storage_pos) when is_integer(value) and is_integer(storage_pos) do
    updated_computer = Map.update!(computer, :memory, fn memory -> List.replace_at(memory, storage_pos, value) end)
    %{:status => :ok, :computer => updated_computer}
  end
end
