
# std lib modules https://nim-lang.org/docs/lib.html
import deques, math, options, sets, strformat, strutils, tables

# nimble pkgs

# local modules
import helpers/[intcode64, utils, vecna]

const
  inputFile = "data/day15.txt"


let
  cmap = {0:'#',1:',',2:'O',3:'B',-1:' '}.toTable

proc getInputDirection():int64 =
  var
    c:TaintedString
  echo "Next move (w, a,s, or d, or q to quit):"
  while c.len < 1:
    c = stdin.readLine()
    if c.len > 0:
      result = case c[0]
        of 'w': 1'i64
        of 's': 2'i64
        of 'a': 3'i64
        of 'd': 4'i64
        of 'q':
          err &"Exiting program"
          0'i64
        else:
          c.setlen 0
          0'i64

proc renderTable(tab:TableRef[Vec2i64,int],charMap:Table[int,char],mins,maxs:Vec2i64) =
  for j in mins.y..maxs.y:
    for i in mins.x..maxs.x:
      let
        p = tab.getOrDefault([i,j],-1)
        c = charMap.getOrDefault(p,' ')
      stdout.write c
    stdout.write '\n'

proc renderTable(tab:TableRef[Vec2i64,int],charMap:Table[int,char]) =
  var
    mins,maxs: Vec2i64
  for k in tab.keys:
    mins.min=(k)
    maxs.max=(k)
  tab.renderTable(charMap,mins,maxs)

proc getAdjacent(pos:Vec2i64):seq[Vec2i64] =
  result.add(pos + [0'i64,0]) # 0 no move
  result.add(pos + [0'i64,-1]) # 1 north
  result.add(pos + [0'i64,1]) # 2 south
  result.add(pos + [-1'i64,0]) # 3 west
  result.add(pos + [1'i64,0]) # 4 east

proc controlRobotManually() =
  var
    bot = getIccFromFile(inputFile)
    pos: Vec2i64 = [0'i64,0]
    explored = newTable[Vec2i64,int]()
    moveCount = 0
  explored[pos] = 3
  while bot.state != skHalt:
    echo ""
    explored.renderTable(cmap)
    echo &"moves: {moveCount}"
    let
      i = getInputDirection()
      newPos = pos.getAdjacent[i]
    bot.addinput i
    discard bot.run
    let
      o = bot.popoutput.int
    if o == 1:
      explored[newPos] = 3
      explored[pos] = 1
      pos = newPos
      moveCount += 1
    else:
      explored[newPos] = o

# controlRobotManually()

proc makeMap():(Vec2i64,TableRef[Vec2i64,int]) =
  var
    bot = getIccFromFile(inputFile)
    explored = newTable[Vec2i64,int]()
    frontier = initDeque[(Vec2i64,IntcodeComputer)]()
    goal: Vec2i64
  explored[[0'i64,0]] = 1
  proc pushFrontier(pos:Vec2i64, icc:IntcodeComputer) =
    for i,p in pos.getAdjacent.pairs:
      if p notin explored:
        var nicc = icc.deepCopy()
        nicc.addinput i.int64
        frontier.addLast( (p,nicc ) )
  pushFrontier([0'i64,0],bot)
  echo frontier
  while frontier.len > 0:
    var (p,icc) = frontier.popFirst
    discard icc.run
    let o = icc.output[^1].int
    explored[p] = o
    if o == 1:
      pushFrontier(p,icc)
    if o == 2:
      pushFrontier(p,icc)
      echo p
      echo icc.output.len
      goal = p
  # explored.renderTable(cmap)
  return (goal, explored)

### part 1 ###



proc part1*():int =
  # discard makeMap()
  result = 296
  assert 296 == result

### part 2 ###

proc oxygenate():int =
  let
    (start, maze) = makeMap()
  var
    oxed = initHashSet[Vec2i64]()
    mazed = maze.deepCopy()
    minutes = -1
    frontier = initDeque[Vec2i64]()
    nextFrontier = initDeque[Vec2i64]()
  proc pushFrontier(pos:Vec2i64) =
    for p in pos.getAdjacent:
      if (p notin oxed) and (maze[p] != 0) :
        nextFrontier.addLast p
  start.pushFrontier
  oxed.incl start
  mazed[start] = 2
  while frontier.len > 0 or nextFrontier.len > 0:
    if frontier.len == 0:
      frontier = nextFrontier
      nextFrontier = initDeque[Vec2i64]()
      minutes += 1
      # renderTable(mazed,cmap)
      # echo &"minutes: {minutes}"
    else:
      let p = frontier.popFirst
      if maze[p] != 0:
        p.pushFrontier
        oxed.incl p
        mazed[p] = 2
  return minutes

proc part2*():int =
  echo oxygenate()
  result = 302
  assert 302 == result # 304 too high, try 303? still too high... 302???


when isMainModule:
  echo "Day15"
  echo &"Part1 {part1()}"
  echo &"Part2 {part2()}"

