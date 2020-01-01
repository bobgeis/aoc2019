
# std lib modules https://nim-lang.org/docs/lib.html
import std/[sequtils, strformat, strutils]

# local lib modules
import lib/[aocutils, bedrock, intcode, vecna]

const
  dayNum = "11"
  inputFile = inputFilePath(dayNum)

proc readtext():seq[int] =
  toSeq(inputFile.lines)[0].split(',').mapIt(parseBiggestInt(it).int)

type
  EHPR = object
    icc:ICC
    x,y,facing: int
    path:seq[Vec[2,int]]
    painted:seq[int]

proc newEHPR(icc:ICC):EHPR = EHPR(icc:icc,x:0,y:0,facing:0, path: @[], painted: @[])

proc getEHPR():EHPR = readtext().newIcc().newEHPR()

proc turn(ehpr:var EHPR,i:int) =
  let i = if i == 0: 3 else: 1
  ehpr.facing = (ehpr.facing + i) mod 4

proc move(ehpr:var EHPR) =
  ehpr.path.add [ehpr.x,ehpr.y]
  case ehpr.facing
  of 0: ehpr.y -= 1
  of 1: ehpr.x += 1
  of 2: ehpr.y += 1
  of 3: ehpr.x -= 1
  else: err &"unknown facing: {ehpr.facing}"

proc paint(ehpr:var EHPR,i:int) = ehpr.painted.add i

proc getPanelColor(ehpr:EHPR):int =
  let i = ehpr.path.findb([ehpr.x,ehpr.y])
  if i == -1: return 0
  else: return ehpr.painted[i]

proc doPaintAndMove(ehpr:var EHPR,outputs:seq[int]) =
  ehpr.paint(outputs[0])
  ehpr.turn(outputs[1])
  ehpr.move()

proc runEHPR(ehpr:var EHPR,i:int=0) =
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
  ehpr.runEHPR(1)
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

# Compile command: 'nim c --hints=off --warnings=off  -d:danger -d:release --opt:speed -o:out/time_day11 nim/day11.nim'
# Run command: 'time ./out/time_day11'
# Day11
# Part1 2339
# .###...##..#..#.####.###..#....###..###....
# .#..#.#..#.#..#.#....#..#.#....#..#.#..#...
# .#..#.#....#..#.###..#..#.#....#..#.#..#...
# .###..#.##.#..#.#....###..#....###..###....
# .#....#..#.#..#.#....#....#....#....#.#....
# .#.....###..##..####.#....####.#....#..#...
# Part2 PGUEPLPR

# real    0m1.569s
# user    0m1.527s
# sys     0m0.014s