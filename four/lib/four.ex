defmodule Four do
  def get_amount_of_possible_passwords(input) do
    input
      |> String.split("-")
      |> (fn [start, stop] ->
        {get_input_as_list(start), get_input_as_list(stop)}
      end).()
      |> increase()
      |> Enum.count()
  end

  def get_input_as_list(input) do
    input
      |> String.split("", trim: true)
      |> Enum.map(&String.to_integer/1)
  end

  def insert_password_if_eligible(passwords, possible_password, stop) do
    with true <- adjacent_digits_same?(possible_password),
         true <- always_increasing?(possible_password),
         true <- within_bounds?(possible_password, stop)
          do
            List.insert_at(passwords, -1, possible_password)
         else
            _ -> passwords
         end
  end

  def always_increasing?(possible_password) do
    possible_password == Enum.sort(possible_password)
  end

  def adjacent_digits_same?(possible_password) do
    Enum.reduce_while(possible_password, {false, 0}, fn digit, {false, repeated} ->
      if digit == repeated do
        {:halt, {true, digit}}
      else
        {:cont, {false, digit}}
      end
    end)
    |> elem(0)
  end

  def within_bounds?(possible_password, stop) when possible_password < stop, do: true
  def within_bounds?(_, _), do: false

  def increase(input, passwords \\ [])
  def increase({counter, stop}, passwords) when counter >= stop, do: passwords

  def increase({[preceding, 9, _, _, _, _] = counter, stop}, passwords) do
    counter
    |> bump_trailing_digits(0, preceding + 1)
    |> (fn possible_password -> increase({possible_password, stop}, insert_password_if_eligible(passwords, possible_password, stop)) end).()
  end


  def increase({[_, preceding, 9, _, _, _] = counter, stop}, passwords) do
    counter
    |> bump_trailing_digits(1, preceding + 1)
    |> (fn possible_password -> increase({possible_password, stop}, insert_password_if_eligible(passwords, possible_password, stop)) end).()
  end

  def increase({[_, _, preceding, 9, _, _] = counter, stop}, passwords) do
    counter
      |> bump_trailing_digits(2, preceding + 1)
      |> (fn possible_password -> increase({possible_password, stop}, insert_password_if_eligible(passwords, possible_password, stop)) end).()
  end

  def increase({[_, _, _, preceding, 9, _] = counter, stop}, passwords) do
    counter
      |> bump_trailing_digits(3, preceding + 1)
      |> (fn possible_password -> increase({possible_password, stop}, insert_password_if_eligible(passwords, possible_password, stop)) end).()
  end

  def increase({[_, _, _, _, preceding, 9] = counter, stop}, passwords) do
    counter
      |> bump_trailing_digits(4, preceding + 1)
      |> (fn possible_password -> increase({possible_password, stop}, insert_password_if_eligible(passwords, possible_password, stop)) end).()
  end

  def increase({counter, stop}, passwords) do
    counter
      |> List.update_at(5, &(&1 + 1))
      |> (fn possible_password -> increase({possible_password, stop}, insert_password_if_eligible(passwords, possible_password, stop)) end).()
  end

  def bump_trailing_digits(counter, start_index, value) do
    Enum.reduce(start_index..5, counter, fn cursor, updated_list ->
      updated_list
      |> List.replace_at(cursor, value)
    end)
  end
end

