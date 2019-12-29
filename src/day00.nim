
# std lib modules https://nim-lang.org/docs/lib.html
import std/[algorithm, deques, math, options, os, sequtils, sets, strformat, strscans, strtabs, strutils, sugar, tables]

# nimble pkgs
import pkg/[itertools, stint]

# local modules
import helpers/[intcode, shenanigans, utils, vecna]

const
  dayNum = "00"
  inputFile = &"data/day{dayNum}.txt"

proc testFile(i:int):string = &"data/day{dayNum}test{i}"

### part 1 ###



proc part1*():int =
  result = 1
  # assert xxx == result

### part 2 ###



proc part2*():int =
  result = 2
  # assert xxx == result


when isMainModule:
  echo &"Day{dayNum}"
  echo &"Part1 {part1()}"
  echo &"Part2 {part2()}"

