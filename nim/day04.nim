
# std lib modules https://nim-lang.org/docs/lib.html
import std/[sequtils, strformat]

proc checkNumber(num:int):bool =
  let s = $num
  var repeat = false
  for i in 1..<s.len:
    if s[i].int < s[i-1].int: return false
    if not repeat: repeat = s[i] == s[i-1]
  return repeat

# 111111 meets these criteria (double 11, never decreases).
# 223450 does not meet these criteria (decreasing pair of digits 50).
# 123789 does not meet these criteria (no double).

assert 111111.checkNumber
assert not 223450.checkNumber
assert not 123789.checkNumber
assert not 822200.checkNumber

# input 278384-824795.

proc part1*():int =
  var count = 0
  for i in 278384..824795:
    if i.checkNumber:
      # echo i
      count += 1
  assert 921 == count
  return count

proc checkNumber2(num:int):bool =
  let
    s = $num
  var
    runs = @[(s[0],1)]
  for i in 1..<s.len:
    if s[i].int < s[i-1].int: return false
    if s[i] == s[i-1]:
      runs[^1][1] += 1
    else:
      runs.add (s[i],1)
  return runs.anyIt(it[1] == 2)

# 112233 meets these criteria because the digits never decrease and all repeated digits are exactly two digits long.
# 123444 no longer meets the criteria (the repeated 44 is part of a larger group of 444).
# 111122 meets the criteria (even though 1 is repeated more than twice, it still contains a double 22).

assert 112233.checkNumber2
assert not 123444.checkNumber2
assert 111122.checkNumber2

# input 278384-824795.

proc part2*():int =
  var count = 0
  for i in 278384..824795:
    if i.checkNumber2:
      # echo i
      count += 1
  assert 603 == count
  return count

when isMainModule:
  echo "Day04"
  echo &"Part1 {part1()}" # 921 √
  echo &"Part2 {part2()}" # 603 √

# Compile command: 'nim c --hint[Conf]=off  -d:danger -d:release --opt:speed -o:out/time_day04 nim/day04.nim'
# Run command: 'time ./out/time_day04'
# Day04
# Part1 921
# Part2 603

# real    0m0.147s
# user    0m0.112s
# sys     0m0.003s