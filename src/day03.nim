
import options, sequtils, strformat, strutils

import helpers/utils

proc getData():seq[string] =
  let file = "data/day03.txt"
  for line in file.lines:
    var txt = line
    txt.stripLineEnd
    result.add txt

type
  Point = tuple
    x,y: int
  Segment = tuple
    start,stop: Point

proc directionsToSegments(dirs:seq[string]):seq[Segment] =
  var
    start = (0,0)
    stop = (0,0)
  for dir in dirs:
    start = stop
    let dist = dir[1..^1].parseInt
    case dir[0]
    of 'R':
      stop[0] += dist
    of 'L':
      stop[0] -= dist
    of 'D':
      stop[1] -= dist
    of 'U':
      stop[1] += dist
    else:
      err &"Unrecognized direction: {dir}"
    result.add (start,stop)

proc isThin(seg:Segment):bool =
  seg.start.x == seg.stop.x

proc invar(seg:Segment):int =
  if seg.isThin: seg.start.x
  else: seg.start.y

proc upper(seg:Segment):int =
  if seg.isThin: max(seg.start.y,seg.stop.y)
  else: max(seg.start.x,seg.stop.x)

proc lower(seg:Segment):int =
  if seg.isThin: min(seg.start.y,seg.stop.y)
  else: min(seg.start.x,seg.stop.x)

proc dist(seg:Segment):int=
  seg.upper - seg.lower

proc dist(seg:Segment,p:Point):Option[int] =
  if not seg.isThin:
    if seg.start.y != p.y:
      return none[int]()
    else:
      return some((p.x - seg.start.x).abs)
  else:
    if seg.start.x != p.x:
      return none[int]()
    else:
      return some((p.y - seg.start.y).abs)

proc intersect(s1,s2:Segment):Option[Point] =
  if s1.isThin == s2.isThin:
    return none[Point]()
  elif s1.invar < s2.lower or s1.invar > s2.upper:
    return none[Point]()
  elif s2.invar < s1.lower or s2.invar > s1.upper:
    return none[Point]()
  elif s1.isThin:
    return some( (s1.invar,s2.invar) )
  else:
    return some( (s2.invar,s1.invar) )

proc mdist(p:Point):int =
  ## manhattan distance from origin
  p.x.abs + p.y.abs

proc mdist(p1,p2:Point):int =
  ## mdist bt two points
  (p2.x-p1.x,p2.y-p1.y).mdist

proc getIntersections(segs1,segs2:seq[Segment]):seq[Point] =
  for s1 in segs1:
    for s2 in segs2:
      let i = intersect(s1,s2)
      if i.isSome and i.get.mdist>0:
        result.add i.get

proc minmdist(string1,string2:string):int =
  ## get the manhattan distance of the intersection closest to the origin (that's not the origin)
  let
    d1 = string1.strip().split(',').directionsToSegments()
    d2 = string2.strip().split(',').directionsToSegments()
  return getIntersections(d1,d2).map(mdist).foldl(min(a,b))

# R8,U5,L5,D3
# U7,R6,D4,L4
# = distance 6
let
  t10 = "R8,U5,L5,D3"
  t11 = "U7,R6,D4,L4"
assert minmdist(t10,t11) == 6

# R75,D30,R83,U83,L12,D49,R71,U7,L72
# U62,R66,U55,R34,D71,R55,D58,R83
# = distance 159

let
  t20 = "R75,D30,R83,U83,L12,D49,R71,U7,L72"
  t21 = "U62,R66,U55,R34,D71,R55,D58,R83"
assert minmdist(t20,t21) == 159

# R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51
# U98,R91,D20,R16,D67,R40,U7,R15,U6,R7
# = distance 135
let
  t30 = "R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51"
  t31 = "U98,R91,D20,R16,D67,R40,U7,R15,U6,R7"
assert minmdist(t30,t31) == 135

proc part1*():int =
  let data = getData()
  let answer = minmdist(data[0],data[1])
  assert 1264 == answer
  return answer

proc stepsTo(path:seq[Segment],p:Point):int =
  var
    steps = 0
  for s in path:
    let d = s.dist(p)
    if d.isSome:
      return steps + d.get
    else:
      steps += s.dist()
  err &"Point not on path! {p}"

proc minsteps(string1,string2:string):int =
  let
    d1 = string1.strip().split(',').directionsToSegments()
    d2 = string2.strip().split(',').directionsToSegments()
    inters = getIntersections(d1,d2)
  return inters.mapIt(d1.stepsTo(it) + d2.stepsTo(it)).foldl(min(a,b))

assert minsteps(t10,t11) == 30
assert minsteps(t20,t21) == 610
assert minsteps(t30,t31) == 410

proc part2*():int =
  let data = getData()
  let answer = minsteps(data[0],data[1])
  assert 37390 == answer
  return answer

when isMainModule:
  echo "Day03"
  echo &"Part1 {part1()}" # 1264 √
  echo &"Part2 {part2()}" # 37390 √
