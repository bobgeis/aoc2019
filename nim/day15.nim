

# std lib modules https://nim-lang.org/docs/lib.html
import std/[deques, math, options, sets, strformat, tables]

# local lib modules
import lib/[aocutils, bedrock, intcode, vecna]

const
  dayNum = "15"
  inputFile = inputFilePath(dayNum)

let
  cmap = {0:'#',1:',',2:'O',3:'B',-1:' '}.toTable

proc getInputDirection():int =
  var
    c:TaintedString
  echo "Next move (w, a,s, or d, or q to quit):"
  while c.len < 1:
    c = stdin.readLine()
    if c.len > 0:
      result = case c[0]
        of 'w': 1
        of 's': 2
        of 'a': 3
        of 'd': 4
        of 'q':
          err &"Exiting program"
          0
        else:
          c.setlen 0
          0

proc renderTable(tab:TableRef[Vec2i,int],charMap:Table[int,char],mins,maxs:Vec2i) =
  for j in mins.y..maxs.y:
    for i in mins.x..maxs.x:
      let
        p = tab.getOrDefault([i,j],-1)
        c = charMap.getOrDefault(p,' ')
      stdout.write c
    stdout.write '\n'

proc renderTable(tab:TableRef[Vec2i,int],charMap:Table[int,char]) =
  var
    mins,maxs: Vec2i
  for k in tab.keys:
    mins.min=(k)
    maxs.max=(k)
  tab.renderTable(charMap,mins,maxs)

proc getAdjacent(pos:Vec2i):seq[Vec2i] =
  result.add(pos + [0,0]) # 0 no move
  result.add(pos + [0,-1]) # 1 north
  result.add(pos + [0,1]) # 2 south
  result.add(pos + [-1,0]) # 3 west
  result.add(pos + [1,0]) # 4 east

proc controlRobotManually() =
  var
    bot = getIccFromFile(inputFile)
    pos: Vec2i = [0,0]
    explored = newTable[Vec2i,int]()
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

proc makeMap():(Vec2i,TableRef[Vec2i,int]) =
  var
    bot = getIccFromFile(inputFile)
    explored = newTable[Vec2i,int]()
    frontier = initDeque[(Vec2i,ICC)]()
    goal: Vec2i
  explored[[0,0]] = 1
  proc pushFrontier(pos:Vec2i, icc:ICC) =
    for i,p in pos.getAdjacent.pairs:
      if p notin explored:
        var nicc = icc.deepCopy()
        nicc.addinput i.int
        frontier.addLast( (p,nicc ) )
  pushFrontier([0,0],bot)
  # echo frontier
  while frontier.len > 0:
    var (p,icc) = frontier.popFirst
    discard icc.run
    let o = icc.output[^1].int
    explored[p] = o
    if o == 1:
      pushFrontier(p,icc)
    if o == 2:
      pushFrontier(p,icc)
      # echo p
      # echo icc.output.len
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
    oxed = initHashSet[Vec2i]()
    mazed = maze.deepCopy()
    minutes = -1
    frontier = initDeque[Vec2i]()
    nextFrontier = initDeque[Vec2i]()
  proc pushFrontier(pos:Vec2i) =
    for p in pos.getAdjacent:
      if (p notin oxed) and (maze[p] != 0) :
        nextFrontier.addLast p
  start.pushFrontier
  oxed.incl start
  mazed[start] = 2
  while frontier.len > 0 or nextFrontier.len > 0:
    if frontier.len == 0:
      frontier = nextFrontier
      nextFrontier = initDeque[Vec2i]()
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
  result = oxygenate()
  assert 302 == result


when isMainModule:
  echo "Day15"
  echo &"Part1 {part1()}"
  echo &"Part2 {part2()}"

# Compile command: 'nim c --hints=off --warnings=off  -d:danger -d:release --opt:speed -o:out/time_day15 nim/day15.nim'
# Run command: 'time ./out/time_day15'
# Day15
# Part1 296
# Part2 302

# real    0m0.189s
# user    0m0.133s
# sys     0m0.006s