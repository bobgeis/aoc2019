
import math
import sequtils
import strformat
import strutils

proc calcFuel(mass:int):int =
  # Fuel required to launch a given module is based on its mass. Specifically, to find the fuel required for a module, take its mass, divide by three, round down, and subtract 2.

  # For example:

  # For a mass of 12, divide by 3 and round down to get 4, then subtract 2 to get 2.
  # For a mass of 14, dividing by 3 and rounding down still yields 4, so the fuel required is also 2.
  # For a mass of 1969, the fuel required is 654.
  # For a mass of 100756, the fuel required is 33583.
  mass div 3 - 2

assert calcFuel(12) == 2
assert calcFuel(14) == 2
assert calcFuel(1969) == 654
assert calcFuel(100756) == 33583

proc fromFile(filename: string):seq[string] =
  for line in filename.lines:
    # echo line
    result.add line

let data = fromFile("data/day01.txt").map(parseInt)

proc part1*():int =
  result = data.map(calcFuel).sum()
  assert result == 3226407

# For part two, we have to add the fuel for each module to its mass and recalc.  Repeating until the increase it 0 or negative

proc calcFuel2(mass:int):int =
  ##
  #   So, for each module mass, calculate its fuel and add it to the total. Then, treat the fuel amount you just calculated as the input mass and repeat the process, continuing until a fuel requirement is zero or negative. For example:

  # A module of mass 14 requires 2 fuel. This fuel requires no further fuel (2 divided by 3 and rounded down is 0, which would call for a negative fuel), so the total fuel required is still just 2.
  # At first, a module of mass 1969 requires 654 fuel. Then, this fuel requires 216 more fuel (654 / 3 - 2). 216 then requires 70 more fuel, which requires 21 fuel, which requires 5 fuel, which requires no further fuel. So, the total fuel required for a module of mass 1969 is 654 + 216 + 70 + 21 + 5 = 966.
  # The fuel required by a module of mass 100756 and its fuel is: 33583 + 11192 + 3728 + 1240 + 411 + 135 + 43 + 12 + 2 = 50346.
  var
    total = 0
    fuel = mass.calcFuel
  while fuel > 0:
    total += fuel
    fuel = fuel.calcFuel
  total

assert 14.calcFuel2 == 2
assert 1969.calcFuel2 == 966
assert 100756.calcFuel2 == 50346

proc part2*():int =
  result = data.map(calcFuel2).sum()
  assert result == 4836738

when isMainModule:
  echo "Day01"
  echo &"Part1 {part1()}" # 3226407 √
  echo &"Part2 {part2()}" # 4836738 √

