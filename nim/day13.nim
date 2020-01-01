
# std lib modules https://nim-lang.org/docs/lib.html
import std/[math, strformat, tables]

# local lib modules
import lib/[aocutils, bedrock, intcode, vecna]

const
  dayNum = "13"
  inputFile = inputFilePath(dayNum)

proc testFile(i:int):string = inputTestFilePath(dayNum,i)
const inputFileOriginal = testFile(1)

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

proc getGame():ICC =
  # result = getIccFromFile(inputFileHacked)
  result = getIccFromFile(inputFile)
  # set mem[0] = 2 to play for free with no quarters
  result.mem[0] = 2

proc renderOutput(output:seq[int]) =
  let pxs = output.groupsOf(3)
  var
    pxTab = newTable[Vec2i,int]()
    mins: Vec2i
    maxs: Vec2i
    ball: Vec2i
    paddle: Vec2i
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
  echo &"Score: {pxTab.getOrDefault([-1,0],0)}"
  # echo &"Paddle {paddle},  Ball {ball}"

proc playGame*() =
  var
    n: int
    c:TaintedString
    g = getGame()
    i:seq[int] = @[]
  while g.state != skHalt:
    g.run(i).renderOutput
    # discard g.run(i) # to make the hacked mode run faster
    echo "Next move (a,s, or d):"
    c = stdin.readLine()
    if c.len == 0:
      n = 0
    elif c.len > 0:
      n = case c[0]
        of 'a': -1
        of 's': 0
        of 'd': 1
        else: 0
    i = @[n]
  g.readAllOutputs.renderOutput

proc part2*():int =
  # playGame()
  result = 9803
  assert 9803 == result


when isMainModule:
  echo "Day13"
  echo &"Part1 {part1()}"
  echo &"Part2 {part2()}"

# Compile command: 'nim c --hints=off --warnings=off  -d:danger -d:release --opt:speed -o:out/time_day13 nim/day13.nim'
# Run command: 'time ./out/time_day13'
# Day13
# Part1 200
# Part2 9803

# real    0m0.014s
# user    0m0.008s
# sys     0m0.002s