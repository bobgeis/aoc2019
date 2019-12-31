
## Vectors of N dimensions and Any type.  AKA: Yet Another Simple Vector Lib, but "yasvl" is harder to pronounce.  This was made with my convenience and learning in mind while I did Advent of Code and other exercises.  If you are interested in performance, then you should probably look at something like arraymancer.

# std
import std/[math, sets, strformat, tables]

# nimble

# local
import utils, shenanigans

type
  Vec*[N: static[int]; A] = array[N,A]

  # common vectors
  Vec2i* = Vec[2,int]
  Vec2f* = Vec[2,float]
  Vec3i* = Vec[3,int]
  Vec3f* = Vec[3,float]
  Vec4i* = Vec[4,int]
  Vec4f* = Vec[4,float]

  Vec2i64* = Vec[2,int64]

  # common tables
  Tab2i*[T] = Table[Vec2i,T]
  Tab2f*[T] = Table[Vec2f,T]
  Tab3i*[T] = Table[Vec3i,T]
  Tab3f*[T] = Table[Vec3f,T]
  Tab4i*[T] = Table[Vec4i,T]
  Tab4f*[T] = Table[Vec4f,T]
  # TabR2i*[T] = TableRef[Vec2i,T]
  # TabR2f*[T] = TableRef[Vec2f,T]
  # TabR3i*[T] = TableRef[Vec3i,T]
  # TabR3f*[T] = TableRef[Vec3f,T]
  # TabR4i*[T] = TableRef[Vec4i,T]
  # TabR4f*[T] = TableRef[Vec4f,T]

  # common hashsets
  Set2i* = HashSet[Vec2i]
  Set2f* = HashSet[Vec2f]
  Set3i* = HashSet[Vec3i]
  Set3f* = HashSet[Vec3f]
  Set4i* = HashSet[Vec4i]
  Set4f* = HashSet[Vec4f]

# TODO: eliminate some of the below repetition using a cool macro like: `DistributeSymbol` from https://github.com/Kaynato/AdventOfCode/blob/master/graphlib/copymacro.nim For usage example see https://github.com/Kaynato/AdventOfCode/blob/master/pair.nim

# convenience getters & setters for x,y,z,w
template x*[N,A](a:Vec[N,A]):untyped = a[0]
template y*[N,A](a:Vec[N,A]):untyped = a[1]
template z*[N,A](a:Vec[N,A]):untyped = a[2]
template w*[N,A](a:Vec[N,A]):untyped = a[3]
template `x=`*[N,A](a:Vec[N,A],b:A):untyped = a[0]= b
template `y=`*[N,A](a:Vec[N,A],b:A):untyped = a[1]= b
template `z=`*[N,A](a:Vec[N,A],b:A):untyped = a[2]= b
template `w=`*[N,A](a:Vec[N,A],b:A):untyped = a[3]= b

# convenience getters and setters for tables
template `[]`*[A,T](t:TableRef[Vec[2,A],T],x,y:A):T = t[[x,y]]
template `[]=`*[A,T](t:var TableRef[Vec[2,A],T],x,y:A,val:T) = t[[x,y]] = val
template `[]`*[A,T](t:TableRef[Vec[3,A],T],x,y,z:A):T = t[[x,y,z]]
template `[]=`*[A,T](t:var TableRef[Vec[3,A],T],x,y,z:A,val:T) = t[[x,y,z]] = val
template `[]`*[A,T](t:TableRef[Vec[4,A],T],x,y,z,w:A):T = t[[x,y,z,w]]
template `[]=`*[A,T](t:var TableRef[Vec[4,A],T],x,y,z,w:A,val:T) = t[[x,y,z,w]] = val

proc origin*[N,A]():Vec[N,A] = result
proc lowest*[N,A]():Vec[N,A] =
  for i in 0..result.high:
    result[i] = A.low
proc highest*[N,A]():Vec[N,A] =
  for i in 0..result.high:
    result[i] = A.high

# basic vector arithmetic
proc `+`*[N,A](a,b:Vec[N,A]):Vec[N,A] =
  for i in 0..a.high:
    result[i] = a[i] + b[i]
proc `-`*[N,A](a,b:Vec[N,A]):Vec[N,A] =
  for i in 0..a.high:
    result[i] = a[i] - b[i]
proc `*`*[N,A](a,b:Vec[N,A]):Vec[N,A] =
  for i in 0..a.high:
    result[i] = a[i] * b[i]
proc `+=`*[N,A](a:var Vec[N,A],b:Vec[N,A]) =
  for i in 0..a.high:
    a[i] = a[i] + b[i]
proc `-=`*[N,A](a:var Vec[N,A],b:Vec[N,A]) =
  for i in 0..a.high:
    a[i] = a[i] - b[i]
proc `*=`*[N,A](a:var Vec[N,A],b:Vec[N,A]) =
  for i in 0..a.high:
    a[i] = a[i] * b[i]

# scalar arithmetic
proc `+`*[N,A](a:Vec[N,A],s:A):Vec[N,A] =
  for i in 0..a.high:
    result[i] = a[i] + s
proc `-`*[N,A](a:Vec[N,A],s:A):Vec[N,A] =
  for i in 0..a.high:
    result[i] = a[i] - s
proc `*`*[N,A](a:Vec[N,A],s:A):Vec[N,A] =
  for i in 0..a.high:
    result[i] = a[i] * s
proc `/`*[N,A](a:Vec[N,A],s:A):Vec[N,A] =
  for i in 0..a.high:
    result[i] = a[i] / s
proc `div`*[N,A](a:Vec[N,A],s:A):Vec[N,A] =
  for i in 0..a.high:
    result[i] = a[i] div s
proc `mod`*[N,A](a:Vec[N,A],s:A):Vec[N,A] =
  for i in 0..a.high:
    result[i] = a[i] mod s
proc `+=`*[N,A](a:var Vec[N,A],s:A) =
  for i in 0..a.high:
    a[i] += s
proc `-=`*[N,A](a:var Vec[N,A],s:A) =
  for i in 0..a.high:
    a[i] -= s
proc `*=`*[N,A](a:var Vec[N,A],s:A) =
  for i in 0..a.high:
    a[i] *= s
proc `/=`*[N,A](a:var Vec[N,A],s:A) =
  for i in 0..a.high:
    a[i] /= s

proc `max=`*[N,A](a:var Vec[N,A],b:Vec[N,A]) =
  for i in 0..a.high:
    a[i] = a[i].max(b[i])
proc `min=`*[N,A](a:var Vec[N,A],b:Vec[N,A]) =
  for i in 0..a.high:
    a[i] = a[i].min(b[i])

proc `*.`*[N,A](a,b:Vec[N,A]):A =
  ## dot product
  for i in 0..a.high:
    result += a[i] * b[i]
proc dot*[N,A](a,b:Vec[N,A]):A = a *. b

proc mdist*[N,A](a:Vec[N,A]):A =
  ## Manhattan distance to origin
  for i in 0..a.high:
    result += a[i].abs
proc mdist*[N,A](a,b:Vec[N,A]):A =
  for i in 0..a.high:
    result += (b[i] - a[i]).abs

proc mag*[A](a:Vec[2,A]):A =
  ## Find the magnitude of a vector.
  ## Note this uses hypot which is only defined for float32 and float64.
  hypot(a.x,a.y)

proc mag*[N,A](a:Vec[N,A]):A =
  ## Find the magnitude of a vector
  ## Note this uses sqrt which is only defined for float32 and float64.
  sqrt( a *. a )

proc dist*[N,A](a,b:Vec[N,A]):A =
  ## distance between two points represented as vectors.
  mag(b-a)

proc normed*[N,A](a:Vec[N,A]):Vec[N,A] =
  ## Get a new unit vector in the direction of a.
  a / a.mag

proc norm*[N,A](a:var Vec[N,A])=
  ## Normalize `a` to have length 1
  a /= a.mag

proc reversed*[N,A](a:Vec[N,A]):Vec[N,A] =
  ## Create a vector that is the reverse of the arg.
  for i in 1..a.len:
    result[i-1] = a[^1]

proc reverse*[N,A](a:var Vec[N,A]) =
  ## reverse a var vector in place
  var swap:A
  for i in 1..(a.len div 2):
    swap = a[i-1]
    a[i-1] = a[^i]
    a[^i]= swap

proc angle*[A](a:Vec[2,A]):float = arctan2(a.y.float,a.x.float)
proc angle*[A](a,b:Vec[2,A]):float = arctan2((b.y-a.y).float, (b.x-a.x).float)
proc angle*[N,A](a,b:Vec[N,A]):float = arccos( (a *. b) / ( a.mag * b.mag) )

proc aabb*[N,A](a,c1,c2:Vec[N,A]):bool =
  ## Is point `a` within an axis-aligned bounding box described by two opposing corners `c1` and `c2`?
  for i in 0..a.high:
    if not a[i].bt(c1[i],c2[i]): return false
  return true

proc onseg*[A](a,p1,p2:Vec[2,A]):bool =
  ## Is the point `a` on the line segment `p1` to `p2`?
  a.aabb(p1,p2) and ((a.x - p1.x)/(p2.x - p1.x) == (a.y - p1.y)/(p2.y - p1.y))

proc getMinMax*[N,T](t:TableRef[Vec[N,int],T]):(Vec[N,int],Vec[N,int]) =
  ## Get a vector of all the minimum values for each coordinate and a vector of all the maximum values for each coordinate among the keys of the given vector table.
  var
    mins = highest[N,int]()
    maxs = lowest[N,int]()
  for k in t.keys:
    mins.min= k
    maxs.max= k
  return (mins,maxs)

proc getMinMax*[N,T](t:Table[Vec[N,int],T]):(Vec[N,int],Vec[N,int]) =
  ## Get a vector of all the minimum values for each coordinate and a vector of all the maximum values for each coordinate among the keys of the given vector table.
  var
    mins = highest[N,int]()
    maxs = lowest[N,int]()
  for k in t.keys:
    mins.min= k
    maxs.max= k
  return (mins,maxs)

proc getMinMax*[N](hs:HashSet[Vec[N,int]]):(Vec[N,int],Vec[N,int]) =
  ## Get a vector of all the minimum values for each coordinate and a vector of all the maximum values for each coordinate among the keys of the given vector hashset.
  var
    mins = highest[N,int]()
    maxs = lowest[N,int]()
  for item in hs.items:
    mins.min= item
    maxs.max= item
  return (mins,maxs)

iterator grid*[T](t:Tab2i[T]):Vec2i =
  let (mins,maxs) = t.getMinMax
  for y in mins.y..maxs.y:
    for x in mins.x..maxs.x:
      yield [x,y]

iterator grid*[T](t:Tab3i[T]):Vec3i =
  let (mins,maxs) = t.getMinMax
  for z in mins.z..maxs.z:
    for y in mins.y..maxs.y:
      for x in mins.x..maxs.x:
        yield [x,y,z]

iterator grid*[T](t:Tab4i[T]):Vec4i =
  let (mins,maxs) = t.getMinMax
  for w in mins.w..maxs.w:
    for z in mins.z..maxs.z:
      for y in mins.y..maxs.y:
        for x in mins.x..maxs.x:
          yield [x,y,z,w]

proc drawTab*[T](t:Tab2i[T],p:proc(v:Vec2i):char):string =
  var yPrev = int.high
  for v in t.grid():
    if v.y != yPrev:
      yPrev = v.y
      result.add '\n'
    result.add p(v)

proc drawTab*[T](t:Tab3i[T],p:proc(v:Vec3i):char):string =
  var zPrev, yPrev = int.high
  for v in t.grid():
    if v.z != zPrev:
      zPrev = v.z
      result.add &"\n\nz={v.z}"
    if v.y != yPrev:
      yPrev = v.y
      result.add '\n'
    result.add p(v)

proc toVec2*[A](v: openArray[A]):Vec[2,A] =
  ## Trim a longer vec, array, or seq to a Vec2
  for i in 0..1:
    result[i] = v[i]
proc toVec3*[A](v: openArray[A]):Vec[3,A] =
  ## Trim a longer vec, array, or seq to a Vec3
  for i in 0..2:
    result[i] = v[i]
proc toVec4*[A](v: openArray[A]):Vec[4,A] =
  ## Trim a longer vec, array, or seq to a Vec4
  for i in 0..3:
    result[i] = v[i]

proc toVec2*[A](v: openArray[A],default:A):Vec[2,A] =
  ## Expand a shorter vec, array or seq to a Vec2 using a default value
  for i in 0..1:
    result[i] = v.getOr(i,default)
proc toVec3*[A](v: openArray[A],default:A):Vec[3,A] =
  ## Expand a shorter vec, array or seq to a Vec3 using a default value
  for i in 0..2:
    result[i] = v.getOr(i,default)
proc toVec4*[A](v: openArray[A],default:A):Vec[4,A] =
  ## Expand a shorter vec, array or seq to a Vec4 using a default value
  for i in 0..3:
    result[i] = v.getOr(i,default)


# TODO
# cross product
# lerp & lerped or lerp & lerp= ?
# rotate
# ra to xy (polar coords it cart coords)
# xy to ra (cart coords to polar coords)
# set magnitude (norm * scalar mult)
# clamp magnitude
# vector table slicing
# make `grid` generic across vector lengths (template/macro)

when isMainModule:

  assert 18 == ([1,2,3] + [3,4,5]).mdist

  assert 77 == [4,5,6] *. [2,3,9]

  assert 1 == [1,2,3,4].x
  assert 2 == [1,2,3,4].y
  assert 3 == [1,2,3,4].z
  assert 4 == [1,2,3,4].w

  var a = [1,2,3,4]
  a.x += 2
  a.y = a.z + 5
  a.w *= a.x
  assert 3 == a.x
  assert 8 == a.y
  assert 6 == a.z + a.z
  assert 12 == a.w

  assert [0,0] == origin[2,int]()

  var t = newTable[Vec2i,int]()
  t[0,1] = 1
  assert 1 == t[0,1]

  echo "vecna asserts passed"
