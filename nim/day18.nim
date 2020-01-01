
# std lib modules https://nim-lang.org/docs/lib.html
import std/[algorithm, deques, heapqueue, options, sequtils, sets, strformat, strutils, tables]

# nimble pkgs
import pkg/[memo, stint]

# local lib modules
import lib/[aocutils, bedrock, graphwalk, shenanigans, vecna]

const
  dayNum = "18"
  inputFile = inputFilePath(dayNum)

proc testFile(i:int):string = inputTestFilePath(dayNum,i)

# std lib modules https://nim-lang.org/docs/lib.html
# import algorithm, deques, heapqueue, math, options, os, sequtils, sets, strformat, strscans, strtabs, strutils, sugar, tables

# nimble pkgs https://nimble.directory/
# import pkg/[itertools, memo, stint]

# local modules
# import helpers/[intcode, shenanigans, utils, vecna]

const
  dirs = @[[0,-1],[0,1],[1,0],[-1,0]] ## directions

  # 1 is 8 steps
  # 2 is 86 steps
  # 3 is 132 steps
  # 4 is 136 steps
  # 5 is 81 steps


### part 1 ###

# start is: [40,40] # looks right: exactly in the middle

# . is open space, # is wall, @ is entrance
# a is a key to the door A
# Length of shortest path to get all the keys?

### part 2 ###

# okay now we have four robots instead of one...
# test6 -> 8
# test7 -> 24
# test8 -> 32
# test9 -> 72

# trying this approach https://github.com/ephemient/aoc2019/blob/py/src/aoc2019/day18.py

proc doit(file:string):int =
  var
    map:seq[seq[char]] = cast[seq[seq[char]]](file.readFile.split('\n'))
    # map = initTable[Vec2i,char]() # map of coordinates to the char at that coordiant
    allkeys = initTable[Vec2i,char]() # coordinates of all the keys
    starts = initTable[Vec2i,char]() # all the start positions for the BFS
    bots = newSeq[char]() # the start or key that each bot is currently on, needed for the Dijkstras search
    distdoorsGraph = initTable[char,Table[char,(int,set[char])]]()
    finalResult = 0 # ultimately, we only want the final cost/distance
  # parse the map lines into allkeys, bots, and starts
  for y,l in map:
    for x,c in l:
      if c in 'a'..'z':
        allkeys[x,y] = c
        starts[x,y] = c
      if c == '@':
        let b = bots.len.char
        starts[x,y] = b
        bots.add b
        map[x,y] = b
  # next BFS to find paths between start positions and keys with doors in between
  for startV,startC in starts:
    var pathsForStart = initTable[char,(int,set[char])]()
    proc adjsBFS(n:Vec2i):seq[Vec2i] =
      for dir in dirs:
        let newV = n + dir
        if map[newV] == '#': continue
        result.add newV
    proc cbBFS(paths:Table[Vec2i,(int,Vec2i)],n:Vec2i):bool =
      result = false
      let c = map[n]
      if c != startC and c.isLowerAscii:
        let doors = paths.walkPath(n).mapit(map[it]).filterit(it.isUpperAscii).mapit(it.toLowerAscii).toSystemSet
        pathsForStart[c] = (paths[n][0],doors)
    bfs(startV,adjsBFS,cbBFS)
    distdoorsGraph[startC] = pathsForStart
  # now we dijkstras through the graph of possibilities O_O
  type
    DijNode = (seq[char],set[char]) ## [0] is the current state of the bot(s) represented as the char of the key/start that they are on, [1] represents what keys have been acquired so far.
  proc adjsDij(n:DijNode):seq[(int,DijNode)] =
    let (items,keys) = n
    for i,item in items:
      for item2,distdoors in distdoorsGraph[item].pairs:
        let (dist,doors) = distdoors
        if (doors - keys).len > 0: continue
        var items2 = items
        items2[i] = item2
        result.add((dist,(items2,keys + {item2})))
  proc cbDij(costs:Table[DijNode,(int,DijNode)],n:DijNode):bool =
    let (_,keys) = n
    if keys.len == allkeys.len:
      finalResult = costs[n][0]
      return true
    else: return false
  let n:DijNode = (bots,{})
  dijkstra(n,adjsDij,cbDij)
  return finalResult

proc part1*():int =
  timeit("Part1"):
    result = inputFile.doit() # 5858 √
  assert 5858 == result

proc part2*():int =
  let
    inputFile2 = testFile(10)
  timeit("Part2"):
    result = inputFile2.doit() # 2144 √
  assert 2144 == result

when isMainModule:
  echo &"Day{dayNum}"
  echo &"Part1 {part1()}"
  echo &"Part2 {part2()}"

# Compile command: 'nim c --hint[Conf]=off  -d:danger -d:release --opt:speed -o:out/time_day18 nim/day18.nim'
# Run command: 'time ./out/time_day18'
# Day18
# Part1 in 781 milliseconds, 586 microseconds, and 142 nanoseconds
# Part1 5858
# Part2 in 1 second, 402 milliseconds, 720 microseconds, and 95 nanoseconds
# Part2 2144

# real    0m2.194s
# user    0m2.164s
# sys     0m0.020s
