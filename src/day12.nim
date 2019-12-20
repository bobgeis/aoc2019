
# std lib modules https://nim-lang.org/docs/lib.html
import math, sequtils, strformat, strutils

# nimble pkgs

# local modules
import helpers/[utils]

type # I just made a 2d point module, now to make a 3d XD
  Point = tuple
    x,y,z:int
  Moon = tuple
    pos,vel: Point

const
  origin  = (0,0,0)

proc `+`(a,b:Point):Point = (a.x+b.x, a.y+b.y, a.z+b.z)
proc `+=`(a:var Point, b:Point) =
  a.x += b.x
  a.y += b.y
  a.z += b.z

proc mdist(a:Point):int = a.x.abs + a.y.abs + a.z.abs
proc mdist(a,b:Point):int = (a + b).mdist

proc energy(a:Moon):int = a.pos.mdist * a.vel.mdist
proc energy(aa:seq[Moon]):int = aa.mapIt(it.energy).sum

proc move(a:var Moon) =
  a.pos += a.vel

proc move(ms:var seq[Moon]) =
  for m in ms.mitems: m.move

proc gravitate(a:var Moon,b:Moon) =
  a.vel.x += b.pos.x.cmp(a.pos.x)
  a.vel.y += b.pos.y.cmp(a.pos.y)
  a.vel.z += b.pos.z.cmp(a.pos.z)

proc gravitate(a:var Moon,bs:seq[Moon]) =
  for b in bs:
    a.gravitate(b)

proc gravitate(ms:var seq[Moon]) =
  for m in ms.mitems: m.gravitate(ms)

proc tick(ms:var seq[Moon]) =
  ms.gravitate
  ms.move


const
  inputFile = "data/day12.txt"

proc parseline(s:string):Point =
  var
    ss = s[1..^2].split(',') # separate each coord
  for c in ss.mitems:
    c.removePrefix(' ')
    c = c[2..^1]
  return (ss[0].parseInt,ss[1].parseInt,ss[2].parseInt)

proc parselines(ss:seq[string]):seq[Point] = ss.mapIt(it.parseline)


proc toMoon(p:Point):Moon = (p,origin)
proc toMoons(ps:seq[Point]):seq[Moon] = ps.mapIt(it.toMoon)

### part 1 ###

# <x=-1, y=0, z=2>
# <x=2, y=-10, z=-7>
# <x=4, y=-8, z=8>
# <x=3, y=5, z=-1>

let
  t1 = @[(-1, 0, 2),(2,-10,-7),(4,-8,8),(3,5,-1)]
var
  ms1 = t1.toMoons

for i in 0..<10:
  ms1.tick()
assert 179 == ms1.energy

proc part1*():int =
  var ms = inputFile.getLines.parselines.toMoons
  for i in 0..<1000:
    ms.tick
  result = ms.energy
  assert 13399 == result

### part 2 ###

proc getXs(ms:seq[Moon]):seq[int] =
  for m in ms:
    result.add m.pos.x
    result.add m.vel.x
proc getYs(ms:seq[Moon]):seq[int] =
  for m in ms:
    result.add m.pos.y
    result.add m.vel.y
proc getZs(ms:seq[Moon]):seq[int] =
  for m in ms:
    result.add m.pos.z
    result.add m.vel.z

proc lcm(ss:seq[int]):int = ss.foldl(lcm(a,b))

proc part2*():int =
  ## x, y, and z are independent, so search for cycles in each axis independently, then use math.lcm to find the least common multiple.
  ## Also remember that its deterministic, so if it ever repeats itself, that means it's a full circle, so we only need to compare with the start state, and not every state in between.
  let
    msStart = inputFile.getLines.parselines.toMoons
    xStart = msStart.getXs
    yStart = msStart.getYs
    zStart = msStart.getZs
  var ms = msStart
  var cycles = @[0,0,0]
  assert ms == msStart
  for i in 1..int.high:
    ms.tick
    if (cycles[0] == 0) and (ms.getXs == xStart):
      cycles[0] = i
    if (cycles[1] == 0) and (ms.getYs == yStart):
      cycles[1] = i
    if (cycles[2] == 0) and (ms.getZs == zStart):
      cycles[2] = i
    if cycles.allIt it>0:
      result = cycles.lcm
      break
  assert 312992287193064 == result

when isMainModule:
  echo "Day12"
  echo &"Part1 {part1()}"
  echo &"Part2 {part2()}"

