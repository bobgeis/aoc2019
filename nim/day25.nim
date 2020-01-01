
# std lib modules https://nim-lang.org/docs/lib.html
import std/[sequtils, strformat, strutils]

# local lib modules
import lib/[aocutils, bedrock, intcode]

const
  dayNum = "25"
  inputFile = inputFilePath(dayNum)

proc getInput():seq[int] =
  var c = ""
  while c.len == 0:
    c = stdin.readLine()
  if c[0] == 'n':
    c = "north"
  elif c[0] == 's':
    c = "south"
  elif c[0] == 'e':
    c = "east"
  elif c[0] == 'w':
    c = "west"
  var s = c.mapit(it.int)
  s.add 10
  return s

let
  inpsToCheckPoint = @[115, 111, 117, 116, 104, 10, 101, 97, 115, 116, 10, 116, 97, 107, 101, 32, 119, 104, 105, 114, 108, 101, 100, 32, 112, 101, 97, 115, 10, 119, 101, 115, 116, 10, 110, 111, 114, 116, 104, 10, 110, 111, 114, 116, 104, 10, 101, 97, 115, 116, 10, 116, 97, 107, 101, 32, 111, 114, 110, 97, 109, 101, 110, 116, 10, 110, 111, 114, 116, 104, 10, 110, 111, 114, 116, 104, 10, 116, 97, 107, 101, 32, 100, 97, 114, 107, 32, 109, 97, 116, 116, 101, 114, 10, 115, 111, 117, 116, 104, 10, 101, 97, 115, 116, 10, 119, 101, 115, 116, 10, 115, 111, 117, 116, 104, 10, 119, 101, 115, 116, 10, 119, 101, 115, 116, 10, 119, 101, 115, 116, 10, 116, 97, 107, 101, 32, 99, 97, 110, 100, 121, 32, 99, 97, 110, 101, 10, 119, 101, 115, 116, 10, 115, 111, 117, 116, 104, 10, 110, 111, 114, 116, 104, 10, 119, 101, 115, 116, 10, 116, 97, 107, 101, 32, 116, 97, 109, 98, 111, 117, 114, 105, 110, 101, 10, 101, 97, 115, 116, 10, 101, 97, 115, 116, 10, 101, 97, 115, 116, 10, 110, 111, 114, 116, 104, 10, 116, 97, 107, 101, 32, 97, 115, 116, 114, 111, 108, 97, 98, 101, 10, 119, 101, 115, 116, 10, 101, 97, 115, 116, 10, 101, 97, 115, 116, 10, 116, 97, 107, 101, 32, 104, 111, 108, 111, 103, 114, 97, 109, 10, 101, 97, 115, 116, 10, 116, 97, 107, 101, 32, 107, 108, 101, 105, 110, 32, 98, 111, 116, 116, 108, 101, 10, 119, 101, 115, 116, 10, 115, 111, 117, 116, 104, 10, 119, 101, 115, 116, 10, 110, 111, 114, 116, 104, 10, 105, 110, 118, 10]
  dropStrs = @[
    "drop ornament\n",
    "drop klein bottle\n",
    "drop dark matter\n",
    "drop candy cane\n",
    "drop hologram\n",
    "drop astrolabe\n",
    "drop whirled peas\n",
    "drop tambourine\n",
  ]
  dropCmds = dropStrs.mapit(it.mapit(it.int)) # I'm impressed that nested mapits work...
  northCmd = "north\n".mapit(it.int)

type
  Cmd = 0..7

proc play() =
  var
    bot = getIccFromFile(inputFile)
    allInps: seq[seq[int]]
  while bot.state != skHalt:
    let outs = bot.run.mapit(it.char).join
    bot.clearOutput
    echo outs
    let
      inps = getInput()
    if inps[0] == 'a'.int:
      echo allInps.flatten
      echo allInps.flatten.mapit(it.char).join
    else: allInps.add inps
    bot.addInputs inps

# play()

let
  lighterStr = """A loud, robotic voice says "Alert! Droids on this ship are lighter than the detected value!" and you are ejected back to the checkpoint."""
  heavierStr = """A loud, robotic voice says "Alert! Droids on this ship are heavier than the detected value!" and you are ejected back to the checkpoint."""

proc autoPlay() =
  var
    initBot = getIccFromFile(inputFile)
  initBot.addInputs inpsToCheckPoint
  discard initBot.run
  initbot.clearOutput
  for i in 0..255:
    let cmds = cast[set[Cmd]](i)
    var bot = initBot.deepcopy
    for cmd in cmds:
      bot.addInputs dropCmds[cmd.ord]
    discard bot.run
    bot.clearOutput
    bot.addInputs northCmd
    let o = bot.run.mapit(it.char).join
    if o.contains(lighterStr):
      echo "too heavy"
    elif o.contains(heavierStr):
      echo "too light"
    else:
      echo o
      break

# autoplay()

### part 1 ###

proc part1*():int =
  result = 134349952
  assert 134349952 == result

### part 2 ###



proc part2*():int =
  result = 2
  # assert xxx == result


when isMainModule:
  echo &"Day{dayNum}"
  echo &"Part1 {part1()}"
  echo &"Part2 {part2()}"

# Compile command: 'nim c --hints=off --warnings=off  -d:danger -d:release --opt:speed -o:out/time_day25 nim/day25.nim'
# Run command: 'time ./out/time_day25'
# Day25
# Part1 134349952
# Part2 2

# real    0m0.008s
# user    0m0.002s
# sys     0m0.003s