defmodule SevenTest do
  use ExUnit.Case
  doctest Seven

  test "3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0 with phase_settings 4,3,2,1,0 gives output 43210" do
    computer = [3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0]
    phase_settings = [4,3,2,1,0]
    assert Seven.run_amplifiers(computer, phase_settings) == 43210
  end

  test "3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0 with phase_settings 0,1,2,3,4 gives output 54321" do
    computer = [3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0]
    phase_settings = [0,1,2,3,4]
    assert Seven.run_amplifiers(computer, phase_settings) == 54321
  end

  test "3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0 with phase_settings 1,0,4,3,2 gives output 43210" do
    computer = [3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0]
    phase_settings = [1,0,4,3,2]
    assert Seven.run_amplifiers(computer, phase_settings) == 65210
  end

  test "get settings for max thruster" do
    Seven.get_max_thruster_settings() == 65464
  end
end
