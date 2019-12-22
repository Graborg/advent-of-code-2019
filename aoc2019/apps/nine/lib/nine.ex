defmodule Nine do
  def get_BOOST_keycode(input) do
    Utilities.get_puzzle_input()
      |> Computer.calculate([input])
  end
end
