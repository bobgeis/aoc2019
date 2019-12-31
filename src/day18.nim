
# std lib modules https://nim-lang.org/docs/lib.html
import algorithm, deques, math, options, os, sequtils, sets, strformat, strscans, strtabs, strutils, sugar, tables

# nimble pkgs
import itertools
# docs https://narimiran.github.io/itertools/index.html
# repo https://github.com/narimiran/itertools

# local modules
import helpers/[intcode, shenanigans, utils, vecna]

const
  dayNum = "18"
  inputFile = &"data/day{dayNum}.txt"
  dirs = @[[0,-1],[0,1],[1,0],[-1,0]] ## directions


proc testFile(i:int):string = &"data/day{dayNum}test{i}.txt"
  # 1 is 8 steps
  # 2 is 86 steps
  # 3 is 132 steps
  # 4 is 136 steps
  # 5 is 81 steps

proc parseMaze(mazeString:string):(Table[Vec2i,char],Table[char,Vec2i],Table[char,Vec2i],Vec2i) =
  var
    y = 0
    map = initTable[Vec2i,char]()
    doors = initTable[char,Vec2i]()
    keys = initTable[char,Vec2i]()
    start: Vec2i
  for s in mazeString.readFile().split('\n'):
    for x,c in s.pairs:
      if c in 'A'..'Z':
        doors[c] = [x,y]
      elif c in 'a'..'z':
        keys[c] = [x,y]
      elif c == '@':
        start = [x,y]
      map[[x,y]] = c
    y += 1
  return (map,keys,doors,start)

# echo testFile(1).parseMaze()

proc walkMazeBFS(map:Tab2i[char],keys: Table[char,Vec2i], doors: Table[char,Vec2i],start:Vec2i,stepsSoFar:int,path:seq[char]):(int,seq[char]) =
  var
    q = initDeque[Vec2i]()
    remaining:int
    steps = 0
    marked = initHashSet[Vec2i]()
    paths:seq[(int,seq[char])] = @[]
  q.addLast start
  marked.incl start
  proc echoMap() =
    proc p(v:Vec2i):char =
      return if v == start: '@'
        elif v in marked: 'O'
        else: map[v]
    echo map.drawTab(p)
    discard stdin.readline()
  while q.len > 0:
    remaining = q.len
    steps += 1
    for i in 0..<remaining:
      let v = q.popFirst
      for dir in dirs:
        let
          vd = v + dir
          c = map[vd]
        if vd in marked: discard
        elif c == '.' or c == '@':
          q.addLast vd
          marked.incl vd
        elif c in 'a'..'z':
          if keys.len == 1:
            return (stepsSoFar + steps, path & c)
          else:
            var
              map2 = map
              keys2 = keys
              doors2 = doors
            map2[vd] = '.'
            if doors2.hasKey(c.toUpperAscii):
              map2[doors2[c.toUpperAscii]] = '.'
            keys2.del(c)
            # echoMap()
            paths.add walkMazeBFS(map2,keys2,doors2,vd,stepsSoFar + steps,path & c)
  # echo paths
  var pMin = paths[0]
  for p in paths:
    if p[0] < pMin[0]: pMin = p
  return pMin

proc walkMazeBFS(file:string):(int,seq[char]) =
  let
    (map,keys,doors,start) = file.parseMaze
  return walkMazeBFS(map,keys,doors,start,0,@[])

# 1 is 8 steps
# echo testFile(1).walkMaze() # √
# 2 is 86 steps
# echo testFile(2).walkMaze() # √
# 3 is 132 steps
# echo testFile(3).walkMaze() # √
# 4 is 136 steps
# echo testFile(4).walkMaze() # doesn't finish in a reasonable time! (BFS takes way too long)
# 5 is 81 steps
# echo testFile(5).walkMaze() # √

# echo inputFile.walkMaze()


### part 1 ###

# start is: [40,40] # looks right: exactly in the middle

# . is open space, # is wall, @ is entrance
# a is a key to the door A
# Length of shortest path to get all the keys?

# Note that for part1 we don't actually care about the path itself, just its length.
# we can do flood fill to find all the keys

# Nope!  Doesn't work!
# Let's find the distances between every pair of keys/start, and keep track of what doors are in between.  Then make it a simpler graph problem where you just move on a graph of accessible keys.  This should work because there are no loops, that is there is always an unambiguously shortest route to a key.

# let's walk from the start and each key to find all the distances.
# then lets walk from the start with all doors except one removed and see what doors each key requires
# then lets navigate the graph of accessible keys

proc findDistancesFrom(map:Tab2i[char],start:Vec2i):Table[char,int] =
  result = initTable[char,int]()
  var
    q = initDeque[Vec2i]()
    marked = initHashSet[Vec2i]()
    remaining:int
    steps = 0
  q.addLast start
  marked.incl start
  while q.len > 0:
    remaining = q.len
    steps += 1
    for i in 0..<remaining:
      let v = q.popFirst
      for dir in dirs:
        let
          vd = v + dir
          c = map[vd]
        if vd in marked: discard
        elif c == '.' or c in 'A'..'Z':
          q.addLast vd
          marked.incl vd
        elif c == '@' or c in 'a'..'z':
          q.addLast vd
          marked.incl vd
          result[c] = steps

proc findDistanceGraph(map:Tab2i[char],keys:Table[char,Vec2i],start:Vec2i):Table[char,Table[char,int]] =
  ## Get a table of distances between every key and every other key (and the start).
  result = initTable[char,Table[char,int]]()
  result['@'] = map.findDistancesFrom(start)
  for k,v in keys:
    result[k] = map.findDistancesFrom(v)

proc findRequirementsGraph(map:Tab2i[char],keys:Table[char,Vec2i],start:Vec2i):Table[char,set[char]] =
  ## Get a table of which doors block the each key
  result = initTable[char,set[char]]()
  for k in keys.keys:
    result[k] = {}
  for k in keys.keys:
    let K = k.toUpperAscii
    var
      q = initDeque[Vec2i]()
      marked = initHashSet[Vec2i]()
      keys2 = keys
    q.addLast start
    marked.incl start
    while q.len > 0:
      let v = q.popFirst
      for dir in dirs:
          let
            vd = v + dir
            c = map[vd]
          if vd in marked: discard
          elif c == K:
            discard
          elif c == '.' or c == '@' or c in 'A'..'Z':
            q.addLast vd
            marked.incl vd
          elif c in 'a'..'z':
            keys2.del c
            q.addLast vd
            marked.incl vd
    for k2 in keys2.keys:
      result[k2].incl k


proc findGraphs(file:string) =
  let
    (map,keys,doors,start) = file.parseMaze
    dists = map.findDistanceGraph(keys,start)
    reqs = map.findRequirementsGraph(keys,start)
  echo reqs


proc walkMazeDFS(file:string) =
  let
    (map,keys,doors,start) = file.parseMaze
    dists = map.findDistanceGraph(keys,start)
    reqs = map.findRequirementsGraph(keys,start)
  var
    allkeys:set[char]
    paths:seq[(int,seq[char])] = @[]
    minPath:(int,seq[char]) = (int.high,@[])
  for k in reqs.keys:
    allkeys.incl k
  paths.add (0,@['@'])
  proc accessibleKeys(p:seq[char]):seq[char] =
    var
      pathkeys:set[char]
    for k in p:
      pathkeys.incl k
    for k in allkeys - pathkeys:
      if reqs[k] <= pathkeys:
        result.add k
    result = result.sortedbyit(dists[p[^1]][it]).reversed
  while paths.len > 0:
    let
      (d,p) = paths.pop
    if d > minPath[0]: discard
    else:
      let ks = accessibleKeys(p)
      if ks.len > 0:
        for k in ks:
          paths.add (d + dists[p[^1]][k],p & k)
      else:
        minPath = (d,p)
        echo minPath
  echo minPath

# testFile(1).walkMaze2() # 8 √
# testFile(2).walkMaze2() # 86 √
# testFile(3).walkMaze2() # 132 √
# testFile(5).walkMaze2() # 81 √
# testFile(4).walkMazeDFS() # takes too long

# depth first search is also no good!  Dijkstras?

proc walkMazeDijkstra(file:string) =
  let
    (map,keys,doors,start) = file.parseMaze
    dists = map.findDistanceGraph(keys,start)
    reqs = map.findRequirementsGraph(keys,start)


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

