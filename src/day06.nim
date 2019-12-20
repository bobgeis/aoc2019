
import deques, math, sets, strformat, strutils, tables

import helpers/utils

type
  Orbits = TableRef[string,string]
  OrbitCache = TableRef[string,int]
  AdjacentOrbits = TableRef[string,seq[string]]

const
  input = "data/day06.txt"
  testInput = "data/day06test.txt"
  testInput2 = "data/day06test2.txt"

proc getData():seq[string] =
  input.getlines()

proc getTestData():seq[string] =
  testInput.getlines()

proc parselines(data:seq[string]):Orbits =
  var
    orbits = newTable[string,string](data.len.nextPowerOfTwo)
  for datum in data:
    let
      orbit = datum.split(')')
    orbits.add orbit[1], orbit[0]
  return orbits

proc walkorbit(orbits:Orbits,orbit:string,cache:OrbitCache):int =
  var
    o = orbit
    visited = @[o]
  while true:
    if cache.hasKey(o):
      let c = cache[o]
      for i in 1..visited.len:
        cache[visited[^i]] = i-1+c
      return cache[orbit]
    o = orbits[o]
    visited.add o

proc countorbits(orbits:Orbits):int =
  var
    cache = newTable[string,int](orbits.len.nextPowerOfTwo)
    c = 0
  cache.add "COM",0
  for o,v in orbits:
    c += orbits.walkorbit(o, cache)
  return c

# COM)B
# B)C
# C)D
# D)E
# E)F
# B)G
# G)H
# D)I
# E)J
# J)K
# K)L
# = direct + indirect orbits = 42

assert 42 == getTestData().parselines().countorbits()

proc part1*():int =
  result = getData().parselines.countorbits
  assert 147807 == result

proc getTestData2():seq[string] =
  getlines(testInput2)

proc getAdjacent(orbits:Orbits):AdjacentOrbits =
  result = newTable[string,seq[string]](orbits.len.nextPowerOfTwo)
  for k,v in orbits:
    var
      ks = result.getOrDefault(k,@[])
      vs = result.getOrDefault(v,@[])
    ks.add v
    vs.add k
    result[k] = ks
    result[v] = vs

proc bfs(adj:AdjacentOrbits,start = "YOU", stop = "SAN"):seq[string] =
  ## walk from start to stop or crash trying
  var
    q = initDeque[seq[string]]()
    marked = initHashSet[string]()
  q.addLast @[start]
  while q.len > 0:
    let
      path = q.popFirst
      orbit = path[^1]
    if orbit == stop: return path
    for o in adj[orbit]:
      if not marked.contains o:
        marked.incl o
        var newpath = path
        newpath.add o
        q.addLast newpath

assert 4 == getTestData2().parselines.getAdjacent.bfs.len - 3

proc part2*():int =
  result = getData().parselines.getAdjacent.bfs.len - 3
  assert 229 == result

when isMainModule:
  echo "Day06"
  echo &"Part1 {part1()}" # 147807 √
  echo &"Part2 {part2()}" # 229 √

