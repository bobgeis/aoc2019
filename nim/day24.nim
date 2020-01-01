
# std lib modules https://nim-lang.org/docs/lib.html
import std/[math, sequtils, sets, strformat, strutils, tables]

# local lib modules
import lib/[aocutils, bedrock, vecna]

const
  dayNum = "24"
  inputFile = inputFilePath(dayNum)

const
  adjacencies = @[[1,0],[-1,0],[0,1],[0,-1]]
  blank = """.....
.....
.....
.....
....."""

# Initial state:
let s0 = """....#
#..#.
#..##
..#..
#...."""

# After 1 minute:
let s1 = """#..#.
####.
###.#
##.##
.##.."""

# After 2 minutes:
let s2 = """#####
....#
....#
...#.
#.###"""

# After 3 minutes:
let s3 = """#....
####.
...##
#.##.
.##.#"""

# After 4 minutes:
let s4 = """####.
....#
##..#
.....
##..."""


### part 1 ###

let
  inputString =  inputFile.readFile.toString

proc setSpot(s:var string,v:Vec2i, c:char) =
  s[v.x + 6 * v.y] = c

proc checkSpot(s:string,v:Vec2i):char =
  if not v.aabb([0,0],[4,4]): return '.'
  else: return s[v.x + 6 * v.y]

proc checkAdjacent(s:string,pos:Vec2i):int =
  adjacencies.mapit(s.checkSpot(pos + it)).filterIt(it == '#').len

proc nextString(s:string):string =
  result = blank
  for y in 0..4:
    for x in 0..4:
      let
        v = [x,y]
        adj = s.checkAdjacent(v)
        c = case s.checkSpot(v)
          of '.':
            if adj.bt(1,2): '#' else: '.'
          of '#':
            if adj == 1: '#' else: '.'
          else:
            '.'
      result.setSpot(v,c)

assert s1 == s0.nextString
assert s2 == s1.nextString
assert s3 == s2.nextString
assert s4 == s3.nextString

proc compareAndAdd(tab:var TableRef[int,seq[string]],s:string):bool =
  let c = s.count('#')
  if not tab.hasKey(c): tab[c] = @[s]
  else:
    var ss = tab[c]
    if s in ss: return true
    ss.add s
    tab[c] = ss
  return false

proc bioScore(s:string):int =
  var f = 0.float
  for x in 0..4:
    for y in 0..4:
      if s.checkSpot([x,y]) == '#':
        f += pow(2.0,x.float + 5.0 * y.float)
  result = f.int

let scoreTest = """.....
.....
.....
#....
.#..."""

assert 2129920 == scoreTest.bioScore

proc part1*():int =
  var
    swap:string = inputString
    tab = newTable[int,seq[string]]()
  for i in 0..1000:
    swap = swap.nextString
    if tab.compareAndAdd(swap):
      result = swap.bioScore.int
      break
  assert 32776479 == result

### part 2 ###

# -_-
# z=1 is inside z=0, z=-1 surrounds z=0


proc getAdj(v:Vec3i):seq[Vec3i] =
  ## my god this is ugly code
  result = @[]
  # horizontally adjacent
  if v.x == 0: # bordering left edge
    result.add [1,2,v.z-1]
    result.add [1,v.y,v.z]
  elif v.x == 4: # bordering right edge
    result.add [3,2,v.z-1]
    result.add [3,v.y,v.z]
  elif v.y == 2: # bordering inner edge
    if v.x == 1:
      result.add [0,v.y,v.z]
      for y in 0..4:
        result.add [0,y,v.z+1]
    elif v.x == 3:
      result.add [4,v.y,v.z]
      for y in 0..4:
        result.add [4,y,v.z+1]
  else: # not bordering anything
    result.add [v.x+1,v.y,v.z]
    result.add [v.x-1,v.y,v.z]
  # vertically adjacent
  if v.y == 0: # bordering top edge
    result.add [2,1,v.z-1]
    result.add [v.x,1,v.z]
  elif v.y == 4: # bordering bottom edge
    result.add [2,3,v.z-1]
    result.add [v.x,3,v.z]
  elif v.x == 2: # bordering inner edge
    if v.y == 1:
      result.add [v.x,0,v.z]
      for x in 0..4:
        result.add [x,0,v.z+1]
    elif v.y == 3:
      result.add [v.x,4,v.z]
      for x in 0..4:
        result.add [x,4,v.z+1]
  else: # not bordering anything
    result.add [v.x,v.y+1,v.z]
    result.add [v.x,v.y-1,v.z]

# Tile 19 has four adjacent tiles: 14, 18, 20, and 24.
# Tile G has four adjacent tiles: B, F, H, and L.
# Tile D has four adjacent tiles: 8, C, E, and I.
# Tile E has four adjacent tiles: 8, D, 14, and J.
# Tile 14 has eight adjacent tiles: 9, E, J, O, T, Y, 15, and 19.
# Tile N has eight adjacent tiles: I, O, S, and five tiles within the sub-grid marked ?.
assert [3,3,0].getAdj == @[[4, 3, 0], [2, 3, 0], [3, 4, 0], [3, 2, 0]]
assert [1,1,1].getAdj == @[[2, 1, 1], [0, 1, 1], [1, 2, 1], [1, 0, 1]]
assert [3,0,1].getAdj == @[[4, 0, 1], [2, 0, 1], [2, 1, 0], [3, 1, 1]]
assert [4,0,1].getAdj == @[[3, 2, 0], [3, 0, 1], [2, 1, 0], [4, 1, 1]]
assert [3,2,0].getAdj == @[[4, 2, 0], [4, 0, 1], [4, 1, 1], [4, 2, 1], [4, 3, 1], [4, 4, 1], [3, 3, 0], [3, 1, 0]]
assert [3,2,1].getAdj == @[[4, 2, 1], [4, 0, 2], [4, 1, 2], [4, 2, 2], [4, 3, 2], [4, 4, 2], [3, 3, 1], [3, 1, 1]]

proc stringToSet(s:string): HashSet[Vec3i] =
  result = initHashSet[Vec3i]()
  for y in 0..4:
    for x in 0..4:
      if s.checkSpot([x,y]) == '#':
        result.incl [x,y,0]

proc setToString(s:HashSet[Vec3i]):string =
  var minz,maxz = 0
  for k in s:
    minz = min(k.z,minz)
    maxz = max(k.z,maxz)
  for z in minz..maxz:
    result.add &"z={z}\n"
    for y in 0..4:
      for x in 0..4:
        if x == 2 and y == 2: result.add '?'
        elif [x,y,z] in s: result.add '#'
        else: result.add '.'
      result.add '\n'
    result.add '\n'
  result.add &"bug count: {s.len}\n"

proc checkSpot(s:HashSet[Vec3i],v:Vec3i):bool =
  let adj = v.getAdj
  var n = 0
  for a in adj:
    if a in s: n += 1
  if v in s: return n == 1
  else: return n.bt(1,2)

proc tick(s:HashSet[Vec3i]):HashSet[Vec3i] =
  result = initHashSet[Vec3i]()
  var allAdj = initHashSet[Vec3i]()
  for k in s:
    for v in k.getAdj:
      allAdj.incl v
  for v in allAdj:
    if s.checkSpot(v):
      result.incl v

let
  testStr = """....#
#..#.
#.?##
..#..
#...."""
  testSet = testStr.stringToSet
  inSet = inputString.stringToSet

# echo testSet.setToString
# echo inSet.setToString
# echo testSet.tick.setToString

proc tick(s:HashSet[Vec3i],n:int):HashSet[Vec3i] =
  result = s
  for i in 0..<n:
    result = result.tick

# echo testSet.tick(10).setToString

proc part2*():int =
  # echo inSet.tick(200).setToString
  result = inSet.tick(200).len
  assert 2017 == result


when isMainModule:
  echo &"Day{dayNum}"
  echo &"Part1 {part1()}"
  echo &"Part2 {part2()}"

# Compile command: 'nim c --hints=off --warnings=off  -d:danger -d:release --opt:speed -o:out/time_day24 nim/day24.nim'
# Run command: 'time ./out/time_day24'
# Day24
# Part1 32776479
# Part2 2017

# real    0m0.232s
# user    0m0.214s
# sys     0m0.005s