
# std lib modules https://nim-lang.org/docs/lib.html
import  math, strformat, strutils, tables

# nimble pkgs

# local modules
import helpers/[intcode64, utils, vecna]

const
  inputFileHacked = "data/day13.txt"
  inputFileOriginal = "data/day13origin.txt"

proc countBlocks():int =
  var icc = getIccFromFile(inputFileOriginal)
  let pxs = icc.run.groupsOf(3)
  var blockCount = 0
  for px in pxs:
    if px[2] == 2: blockCount += 1
  return blockCount

### part 1 ###

proc part1*():int =
  result = countBlocks()
  assert 200 == result

### part 2 ###

proc getGame():IntcodeComputer =
  # result = getIccFromFile(inputFileHacked)
  result = getIccFromFile(inputFileOriginal)
  # set mem[0] = 2 to play for free with no quarters
  result.mem[0] = 2

proc renderOutput(output:seq[int64]) =
  let pxs = output.groupsOf(3)
  var
    pxTab = newTable[Vec2i64,int64]()
    mins: Vec2i64
    maxs: Vec2i64
    ball: Vec2i64
    paddle: Vec2i64
  for px in pxs:
    for i in 0..maxs.high:
      if maxs[i] < px[i]: maxs[i] = px[i]
    pxTab[[px[0],px[1]]] = px[2]
  for j in mins.y..maxs.y:
    for i in mins.x..maxs.x:
      let
        p = pxTab.getOrDefault([i,j],0)
        c = case p
          of 0: ' '
          of 1: '|'
          of 2: '#'
          of 3: '='
          of 4: '@'
          else: '!'
      if p == 4: ball = [i,j]
      if p == 3: paddle = [i,j]
      stdout.write c
    stdout.write '\n'
  echo &"Score: {pxTab.getOrDefault([-1'i64,0],0)}"
  # echo &"Paddle {paddle},  Ball {ball}"

proc playGame*() =
  var
    n: int64
    c:TaintedString
    g = getGame()
    i:seq[int64] = @[]
  while g.state != skHalt:
    g.run(i).renderOutput
    # discard g.run(i) # to make the hacked mode run faster
    echo "Next move (a,s, or d):"
    c = stdin.readLine()
    if c.len == 0:
      n = 0'i64
    elif c.len > 0:
      n = case c[0]
        of 'a': -1'i64
        of 's': 0'i64
        of 'd': 1'i64
        else: 0'i64
    i = @[n]
  g.readAllOutputs.renderOutput

proc part2*():int =
  playGame()
  result = 9803
  assert 9803 == result


when isMainModule:
  echo "Day13"
  echo &"Part1 {part1()}"
  echo &"Part2 {part2()}"

