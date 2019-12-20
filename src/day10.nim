
# std lib modules https://nim-lang.org/docs/lib.html
import algorithm, math, sequtils, strformat, sugar, tables

# local modules
import helpers/utils

type
  Point = tuple[x:int,y:int]

const
  inputFile = "data/day10.txt"
  inputTest1 = "data/day10test1.txt"
  inputTest2 = "data/day10test2.txt"
  inputTest3 = "data/day10test3.txt"

let
  inputData = getlines(inputFile)

proc mdist(a,b:Point):int =
  ## manhattan dist bt a & b
  (b.x - a.x).abs + (b.y - a.y).abs

proc onseg(a,start,stop:Point):bool =
  ## is the point a on the segment start:stop
  if not (a.x.bt(start.x,stop.x) and a.y.bt(start.y,stop.y)):
    return false
  return (a.x - start.x)/(stop.x - start.x) == (a.y - start.y)/(stop.y - start.y)

proc findRocks(ss:seq[string]):seq[Point] =
  result = @[]
  for y,s in ss:
    for x,c in s:
      if c != '.':
        result.add (x,y)

proc angleTo(a,b:Point):float =
  arctan2((b.y - a.y).float, (b.x - a.x).float)

proc getAngles(ps:seq[Point],a:Point):seq[float] =
  for p in ps:
    if p != a: result.add a.angleTo(p)

proc numVisible(ps:seq[Point],a:Point):int =
  ps.getAngles(a).deduplicate.len

proc numVisible(ps:seq[Point]):seq[int] =
  ps.mapIt(ps.numVisible(it))

proc offsetOfMax(nums:seq[int]):int =
  let m = nums.max
  return nums.find(m)

proc pointOfMax(ps:seq[Point]):Point =
  ps[ps.numVisible.offsetOfMax]

### part 1 ###

assert 8 == inputTest1.getlines().findRocks.numVisible.max
assert (x:3,y:4) == inputTest1.getlines().findRocks.pointOfMax
assert 210 == inputTest2.getlines().findRocks.numVisible.max
assert (x:11,y:13) == inputTest2.getlines().findRocks.pointOfMax
assert 30 == inputTest3.getlines().findRocks.numVisible.max
assert (x:8,y:3) == inputTest3.getlines().findRocks.pointOfMax

proc part1*():int =
  let
    rocks = inputData.findRocks
    nums = rocks.numVisible
  result = nums.max()
  assert 340 == result

### part 2 ###

proc clockTo(a,b:Point):float =
  ## Clockwise angle bt y-axis and a->b vector. Remember "up" is negative y!
  result = a.angleTo(b) + Tau/4
  if result < 0: result += Tau

proc killOrder(rs:seq[Point],pt:Point):seq[Point] =
  ## get the order in which rocks will be killed from the center point
  var
    a2rs = rs.binBy(r => pt.clockTo(r))
    angles = toSeq(a2rs.keys)
  angles.sort()
  for a in angles:
    var ps = a2rs[a]
    ps.sort(mdist)
    if pt != ps[0]: result.add ps[0]

let
  t2pt = (11,13)
  t2rocks = inputTest2.getlines().findRocks
  t2kill = t2rocks.killOrder(t2pt)

assert t2kill[0] == (11,12)
assert t2kill[1] == (12,1)
assert t2kill[2] == (12,2)
assert t2kill[9] == (12,8)
assert t2kill[199] == (8,2)

proc part2*():int =
  let rocks = inputData.findRocks
  let pt = rocks.pointOfMax
  let kill = rocks.killOrder(pt)
  let bet = kill[199]
  result = 100 * bet.x + bet.y
  assert 2628 == result

when isMainModule:
  echo "Day10"
  echo &"Part1 {part1()}" # √
  echo &"Part2 {part2()}"

