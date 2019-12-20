
# std lib modules https://nim-lang.org/docs/lib.html
import sequtils, strformat, strutils

# local modules
import helpers/[intcode64, point2d, utils]

const
  inputFile = "data/day11.txt"

proc readtext():seq[int64] =
  toSeq(inputFile.lines)[0].split(',').mapIt(parseBiggestInt(it).int64)

type
  EHPR = object
    icc:IntcodeComputer
    x,y,facing: int64
    path:seq[Point[int64]]
    painted:seq[int64]

proc newEHPR(icc:IntcodeComputer):EHPR = EHPR(icc:icc,x:0,y:0,facing:0, path: @[], painted: @[])

proc getEHPR():EHPR = readtext().newIcc().newEHPR()

proc turn(ehpr:var EHPR,i:int64) =
  let i = if i == 0: 3 else: 1
  ehpr.facing = (ehpr.facing + i) mod 4

proc move(ehpr:var EHPR) =
  ehpr.path.add (ehpr.x,ehpr.y)
  case ehpr.facing
  of 0: ehpr.y -= 1
  of 1: ehpr.x += 1
  of 2: ehpr.y += 1
  of 3: ehpr.x -= 1
  else: err &"unknown facing: {ehpr.facing}"

proc paint(ehpr:var EHPR,i:int64) = ehpr.painted.add i

proc getPanelColor(ehpr:EHPR):int64 =
  let i = ehpr.path.findb((ehpr.x,ehpr.y))
  if i == -1: return 0'i64
  else: return ehpr.painted[i]

proc doPaintAndMove(ehpr:var EHPR,outputs:seq[int64]) =
  ehpr.paint(outputs[0])
  ehpr.turn(outputs[1])
  ehpr.move()

proc runEHPR(ehpr:var EHPR,i:int64=0) =
  var outputs = ehpr.icc.run(@[i])
  ehpr.doPaintAndMove(outputs[^2..^1])
  while ehpr.icc.state != skHalt:
    outputs = ehpr.icc.run(@[ehpr.getPanelColor])
    ehpr.doPaintAndMove(outputs[^2..^1])

var test = getEHPR()
test.runEHPR()

### part 1 ###

proc part1*():int =
  var ehpr = getEHPR()
  ehpr.runEHPR
  result = ehpr.path.deduplicate.len
  assert 2339 == result

### part 2 ###

proc part2*():string =
  var ehpr = getEHPR()
  ehpr.runEHPR(1'i64)
  let
    xs = ehpr.path.mapIt(it.x)
    ys = ehpr.path.mapit(it.y)
    maxs = (x:xs.max,y:ys.max)
    mins = (x:xs.min,y:ys.min)
  var img: seq[string]
  for y in mins.y..maxs.y:
    var s = ""
    for x in mins.x..maxs.x:
      s &= '.'
    img.add s
  for i,p in ehpr.path.pairs:
    let c = if ehpr.painted[i] == 0: '.' else: '#'
    img[p.y - mins.y][p.x - mins.x] = c
  for s in img:
    echo s
  result = "PGUEPLPR"
  assert "PGUEPLPR" == result


when isMainModule:
  echo "Day11"
  echo &"Part1 {part1()}"
  echo &"Part2 {part2()}"

