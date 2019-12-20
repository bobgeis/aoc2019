
# std lib modules https://nim-lang.org/docs/lib.html
import algorithm, deques, math, options, os, sequtils, sets, strformat, strscans, strtabs, strutils, sugar, tables

# nimble pkgs
import itertools
# docs https://narimiran.github.io/itertools/index.html
# repo https://github.com/narimiran/itertools

# local modules
import helpers/[intcode, shenanigans, utils, vecna]

const
  inputFile = "data/day17.txt"


### part 1 ###

# echo [35,10,35].mapit(it.char).join
# "#\n#"

# echo @['.','#','^','>','<','v','\n',','].mapit(it.int)
# @[46, 35, 94, 62, 60, 118, 10, 44]

var bot = getIccFromFile(inputFile)
let
  outs = bot.run
  outString = outs.mapit(it.char).join

# echo outString
# ..........................#########................
# ..........................#.......#................
# ..........................#.......#................
# ..........................#.......#................
# ......................#########...#................
# ......................#...#...#...#................
# ......................#...#...#...#................
# ......................#...#...#...#................
# ......................#.###########................
# ......................#.#.#...#....................
# ................#####.#.#.#####....................
# ................#...#.#.#..........................
# ................#...#.#########....................
# ................#...#...#.....#....................
# ................#...#...#.....#....................
# ................#...#...#.....#....................
# ................#########.....#....................
# ....................#.........#....................
# ....................#.........#...#######..........
# ....................#.........#...#.....#..........
# #########.###########.........#...#.....#..........
# #.......#.#...................#...#.....#..........
# #.......#.#...................###########..........
# #.......#.#.......................#................
# #.......#.#.......................#...#########....
# #.......#.#.......................#...........#....
# #.......#.#.......................#########...#....
# #.......#.#...............................#...#....
# ###########.............................###########
# ........#...............................#.#...#...#
# ........###########.....................#.#...#...#
# ..................#.....................#.#...#...#
# ..................#.....................#######...#
# ..................#.......................#.......#
# ..................#.......................#.......#
# ..................#.......................#.......#
# ..................#.......................#########
# ..................#................................
# ..................#................................
# ..................#................................
# ..................########^........................

proc toPath(ss:seq[string]):seq[seq[int]] =
  for s in ss:
    result.add( s.mapit(if it == '.': 0 elif it == '#': 1 else: 2) )
let
  path = outString.strip.split('\n').toPath

proc iscrossing(path:seq[seq[int]],x,y:int):bool =
  # the edges cannot have crossings
  if y == path.high or y == path.low or x == path[0].high or x == path[0].low:
    false
  elif path[y][x + 1] == 0 or path[y][x - 1] == 0 or path[y + 1][x] == 0 or path[y - 1][x] == 0:
    false
  else:
    true

proc findCrossings(path:seq[seq[int]]):seq[Vec2i] =
  for y,row in path.pairs:
    for x,i in row.pairs:
      if i == 1:
        if path.iscrossing(x,y):
          result.add [x,y]

# echo path.findCrossings
# @[[26, 4], [26, 8], [30, 8], [24, 12], [20, 16], [34, 22], [8, 28], [42, 28], [46, 28], [42, 32]]

proc part1*():int =
  result = path.findCrossings.mapit(it.x * it.y).sum
  assert 5940 == result

### part 2 ###

proc findStart(path:seq[seq[int]]):Vec2i =
  for y in 0..path.high:
    for x in 0..path[0].high:
      if path[y][x] == 2:
        return [x,y]

# echo path.findStart()
# [26,40]

const
  north = [0,-1]
  east = [1,0]
  south = [0,1]
  west = [-1,0]

type
  Turn = enum Left, Right, None
  Path = seq[seq[int]]

proc `$`(t:Turn):string =
  case t
  of Left: "L"
  of Right: "R"
  of None: "NONE"

proc get(path:Path,pos:Vec2i):int =
  path[pos.y][pos.x]

proc contains(path:Path,pos:Vec2i):bool =
  pos.x >= 0 and pos.y >= 0 and pos.y <= path.high and pos.x <= path[0].high

proc turn(dir:Vec2i,t:Turn):Vec2i =
  # [ xcos - ysin , xsin + ycos ]
  case t
  of Right: [-dir.y,dir.x]
  of Left: [dir.y,-dir.x]
  of None: dir

# echo "turn right, north east south west"
# echo north.turn(Right)
# echo east.turn(Right)
# echo south.turn(Right)
# echo west.turn(Right)

# echo "turn left, north east south west"
# echo north.turn(Left)
# echo east.turn(Left)
# echo south.turn(Left)
# echo west.turn(Left)

proc findTurn(path:Path,pos,dir:Vec2i):Turn =
  var newPos = pos + dir.turn(Right)
  if path.contains(newPos) and path.get(newPos) == 1: return Right
  newPos = pos + dir.turn(Left)
  if path.contains(newPos) and path.get(newPos) == 1: return Left
  return None

# echo path.findTurn([26,40],north)
# L

proc findRun(path:Path,start,dir:Vec2i):(Vec2i,int) =
  var
    count = 0
    pos = start
  while true:
    if not (path.contains(pos + dir)) or (path.get(pos + dir) != 1): return (pos,count)
    pos += dir
    count += 1

# echo path.findRun([26,40],west)
# ([18, 40], 8)

proc findAllCommands(path:seq[seq[int]],start,startDir:Vec2i):seq[string] =
  var
    pos = start
    dir = startDir
    commands:seq[string] = @[]
  while true:
    let t = path.findTurn(pos,dir)
    if t == None: return commands
    commands.add $t
    dir = dir.turn(t)
    let (p,n) = path.findRun(pos,dir)
    pos = p
    commands.add $n

# echo path.findAllCommands([26,40],north).join(",")
# L,8,R,10,L,10,R,10,L,8,L,8,L,10,L,8,R,10,L,10,L,4,L,6,L,8,L,8,R,10,L,8,L,8,L,10,L,4,L,6,L,8,L,8,L,8,R,10,L,10,L,4,L,6,L,8,L,8,R,10,L,8,L,8,L,10,L,4,L,6,L,8,L,8

const
  comAll = "L,8,R,10,L,10,R,10,L,8,L,8,L,10,L,8,R,10,L,10,L,4,L,6,L,8,L,8,R,10,L,8,L,8,L,10,L,4,L,6,L,8,L,8,L,8,R,10,L,10,L,4,L,6,L,8,L,8,R,10,L,8,L,8,L,10,L,4,L,6,L,8,L,8"
  comA = "L,8,R,10,L,10"
  comB = "R,10,L,8,L,8,L,10"
  comC = "L,4,L,6,L,8,L,8"

# echo comAll
assert comAll == &"{comA},{comB},{comA},{comC},{comB},{comC},{comA},{comC},{comB},{comC}" #  A,B,A,C,B,C,A,C,B,C

const
  cmdString = "A,B,A,C,B,C,A,C,B,C\nL,8,R,10,L,10\nR,10,L,8,L,8,L,10\nL,4,L,6,L,8,L,8\nn\n"
  cmdSeq = cmdString.mapit(it.int)

# echo cmdString
# echo cmdSeq


var bot2 = getIccFromFile(inputFile)
bot2[0] = 2 # override move logic
bot2.addInputs(cmdSeq)

# while bot2.state != skHalt:
#   echo bot2.run.mapit(it.char).join
  # echo bot2.run

# echo "A,B,C,B,A,C\nR,8,R,8\nR,4,R,4,R,8\nL,6,L,2\n".mapit(it.int)
# @[65, 44, 66, 44, 67, 44, 66, 44, 65, 44, 67, 10, 82, 44, 56, 44, 82, 44, 56, 10, 82, 44, 52, 44, 82, 44, 52, 44, 82, 44, 56, 10, 76, 44, 54, 44, 76, 44, 50, 10]

# each line can have at most 20 characters, counting commas, but not the newline at the end
# After the main routine and 3 functions, you need to provide 'y'.int or 'n'.int to indicate video feed


proc part2*():int =
  while bot2.state != skHalt:
    discard bot2.run
  result = bot2.readLastOutput
  assert 923795 == result


when isMainModule:
  echo "Day17"
  echo &"Part1 {part1()}"
  echo &"Part2 {part2()}"

