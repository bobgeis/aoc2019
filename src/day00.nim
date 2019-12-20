
# std lib modules https://nim-lang.org/docs/lib.html
import algorithm, deques, math, options, os, sequtils, sets, strformat, strscans, strtabs, strutils, sugar, tables

# nimble pkgs
import itertools
# docs https://narimiran.github.io/itertools/index.html
# repo https://github.com/narimiran/itertools

# local modules
import helpers/[intcode, shenanigans, utils, vecna]

const
  dayNum = "00"
  inputFile = &"data/day{dayNum}.txt"


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

