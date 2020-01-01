
# std lib modules https://nim-lang.org/docs/lib.html
import std/[sequtils, strformat, strutils]

# nimble pkgs
# import pkg/[itertools]

# local lib modules
import lib/[aocutils, intcode]

const
  dayNum = "21"
  inputFile = inputFilePath(dayNum)

let theIcc = getIccFromFile(inputFile)

proc toCmd(s:seq[string]):seq[int] =
  var s2 = s.join("\n").strip
  s2 &= "\n"
  return s2.mapit(it.int)

# echo @["OR A T","AND B T","AND C T","NOT T T","NOT D J", "NOT J J","AND T J"].toCmd # √

# echo @['.','#','^','>','<','v','\n',',','@'].mapit(it.int)
# @[46, 35, 94, 62, 60, 118, 10, 44]

### part 1 ###

# the bot will always jump over 3 spaces "#...#" it must have a place to land on the fourth space
# we only have 15 commands/lines total of springscript

let
  walkCmd = "WALK\n".mapIt(it.int)
  # jumpIf3Hole = "NOT A J\nNOT B T\nAND T J\nNOT C T\nAND T J\nAND D J\n".mapit(it.int) # example given
  # jumpIfHoleNext = "NOT A J\n".mapIt(it.int) # works great until you get something like this:  "#.#..##" then you get: "#.#.@#"
  # jumpIfLand3Away = "AND D J\nOR D J\n".mapIt(it.int)

# we want to jump if there is land 3 away, and a hole closer than that.  What's the code for that given we only have two temp vars?  If A B or C are holes, and D is land, we want to jump.
# OR A T
# AND B T
# AND C T
# NOT T T # T is true if there's a hole
# NOT D J
# NOT J J # J is true if there's land at D
# AND T J # J is true if we should jump
let
  jumpCmds = "OR A T\nAND B T\n AND C T\n NOT T T\n NOT D J\n NOT J J\n AND T J\n".mapit(it.int)

proc part1*():int =
  var icc = theIcc.deepCopy
  icc.addInputs jumpCmds
  icc.addInputs walkCmd
  let outs = icc.run
  if outs[^1] > 255:
    result = icc.readLastOutput
  else:
    result = -1
    echo outs.mapit(it.char).join
  assert 19349939 == result

### part 2 ###

let
  runCmd = "RUN\n".mapit(it.int)
  jumpCmds2 = "OR A T\nAND B T\n AND C T\n NOT T T\n NOT D J\n NOT J J\n AND T J\n".mapit(it.int)


# .................
# .................
# ..@..............
# #####.#.##.#.####

# .................
# ...@.............
# .................
# #####.#.##.#.####

# ....@............
# .................
# .................
# #####.#.##.#.####

# .................
# .....@...........
# .................
# #####.#.##.#.####

# .................
# .................
# ......@..........
# #####.#.##.#.####

# .................
# .................
# .................
# #####.#@##.#.####

# We didn't jump again, because the landing side didn't have a place it could jump to.  But by inspection we see that if we had waited a little we could have made multiple jumps later.


let
  jumpCmds3 = @[
    "OR A T",
    "AND B T",
    "AND C T",
    "NOT T T", # T = true means we should jump soon
    "OR E J",
    "OR H J",
    "AND D J", # J = true means if we jump we have place to land AND we can (walk forward OR jump again)
    "AND T J",
  ].toCmd

proc part2*():int =
  var icc = theIcc.deepCopy
  icc.addInputs jumpCmds3
  icc.addInputs runCmd
  let outs = icc.run
  if outs[^1] > 255:
    result = icc.readLastOutput
  else:
    result = -1
    echo outs.mapit(it.char).join
  assert 1142412777 == result


when isMainModule:
  echo &"Day{dayNum}"
  echo &"Part1 {part1()}"
  echo &"Part2 {part2()}"

# Compile command: 'nim c --hints=off --warnings=off  -d:danger -d:release --opt:speed -o:out/time_day21 nim/day21.nim'
# Run command: 'time ./out/time_day21'
# Day21
# Part1 19349939
# Part2 1142412777

# real    0m0.343s
# user    0m0.293s
# sys     0m0.007s