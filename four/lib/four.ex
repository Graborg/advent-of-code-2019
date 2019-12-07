defmodule Four do
  def get_amount_of_possible_passwords(input) do
    input
      |> String.split("-")
      |> Enum.map(&get_input_as_list/1)
      |> increase()
      |> Enum.count()
  end

  def get_input_as_list(input) do
    input
      |> String.split("", trim: true)
      |> Enum.map(&String.to_integer/1)
  end

  def increase([counter, stop], passwords  \\ []) do
    with i when is_integer(i) <- Enum.find_index(counter, &(&1 == 9))
      do
        counter
          |> bump_trailing_digits(i - 1, Enum.at(counter, i - 1))
      else
        _ -> List.update_at(counter, 5, &(&1 + 1))
      end
      |> insert_password_if_eligible(passwords, stop)
      |> (fn
        {:halt, passwords} -> passwords
        {passwords, possible_password} -> increase([possible_password, stop], passwords)
      end).()
  end

  def bump_trailing_digits(counter, start_index, value) do
    Enum.reduce(start_index..5, counter, fn cursor, updated_list ->
      updated_list |> List.replace_at(cursor, value + 1)
    end)
  end

  def insert_password_if_eligible(possible_password, passwords, stop) do
    with {:match_found, _digit} <- adjacent_digits_same?(possible_password),
         true <- always_increasing?(possible_password),
         {:ok, :inside_bounds} <- within_bounds?(possible_password, stop)
          do
            passwords
              |> List.insert_at(-1, possible_password)
              |> case do updated_passwords ->
                {updated_passwords, possible_password}
              end
         else
            {:error, :outside_bounds} -> {:halt, passwords}
            _ -> {passwords, possible_password}
         end
  end

  def always_increasing?(possible_password), do: possible_password == Enum.sort(possible_password)

  def adjacent_digits_same?(possible_password) do
    Enum.reduce_while(possible_password, {:no_match, 0}, fn
      digit, {:match_found, previous_digit} when digit != previous_digit -> {:halt, {:match_found, digit}}
      digit, {:match_found, previous_digit} when digit == previous_digit -> {:cont, {:too_many_adjacent, digit}}
      digit, {:too_many_adjacent, previous_digit} when digit == previous_digit -> {:cont, {:too_many_adjacent, digit}}
      digit, {:no_match, previous_digit} when digit == previous_digit -> {:cont, {:match_found, digit}}
      digit, _ -> {:cont, {:no_match, digit}}
    end)
  end

  def within_bounds?(possible_password, stop) when possible_password < stop, do: {:ok, :inside_bounds}
  def within_bounds?(_, _), do: {:error, :outside_bounds}

end
