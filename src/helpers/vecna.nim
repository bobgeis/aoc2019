
## Vectors of N dimensions and Any type.  AKA: Yet Another Simple Vector Lib, but "yasvl" is harder to pronounce.  This was made with my convenience and learning in mind while I did Advent of Code and other exercises.

# std
import std/[math, tables]

# nimble

# local
import utils

type
  Vec*[N: static[int]; A] = array[N,A]

  # commonly used vectors
  Vec2i* = Vec[2,int]
  Vec2f* = Vec[2,float]
  Vec3i* = Vec[3,int]
  Vec3f* = Vec[3,float]
  Vec4i* = Vec[4,int]
  Vec4f* = Vec[4,float]

  Vec2i64* = Vec[2,int64]

  # commonly used tables
  Tab2i*[T] = TableRef[Vec2i,T]
  Tab2f*[T] = TableRef[Vec2f,T]
  Tab3i*[T] = TableRef[Vec3i,T]
  Tab3f*[T] = TableRef[Vec3f,T]
  Tab4i*[T] = TableRef[Vec3i,T]
  Tab4f*[T] = TableRef[Vec3f,T]

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
template `[]`[N,A,T](t:TableRef[Vec[N,A],T],x,y:A):T = t[[x,y]]
template `[]=`[N,A,T](t:var TableRef[Vec[N,A],T],x,y:A,val:T) = t[[x,y]] = val
template `[]`[N,A,T](t:TableRef[Vec[N,A],T],x,y,z:A):T = t[[x,y,z]]
template `[]=`[N,A,T](t:var TableRef[Vec[N,A],T],x,y,z:A,val:T) = t[[x,y,z]] = val
template `[]`[N,A,T](t:TableRef[Vec[N,A],T],x,y,z,w:A):T = t[[x,y,z,w]]
template `[]=`[N,A,T](t:var TableRef[Vec[N,A],T],x,y,z,w:A,val:T) = t[[x,y,z,w]] = val

proc origin*[N,A]():Vec[N,A] = result

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

proc aabb*[A](a,c1,c2:Vec[2,A]):bool =
  ## Is point `a` within a aabb/rectangle described by two opposing corners `c1` and `c2`?
  a.x.bt(c1.x,c2.x) and a.y.bt(c1.y,c2.y)

proc onseg*[A](a,p1,p2:Vec[2,A]):bool =
  ## Is the point `a` on the line segment `p1` to `p2`?
  a.aabb(p1,p2) and ((a.x - p1.x)/(p2.x - p1.x) == (a.y - p1.y)/(p2.y - p1.y))



proc getMinMax*[T](t:Tab2i[T]):(Vec2i,Vec2i) =
  ## Given a table with Vec2i keys, get a tuple of (mins,maxs) where mins and maxs are Vec2i of the lowest and highest of each coordinate.  Useful for iterating over all the Vec2i in a table in order.
  var
    mins = [int.high,int.high]
    maxs = [int.low,int.low]
  for k,v in t:
    mins.min= k
    maxs.max= k
  return (mins,maxs)


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

  var t = newTable[Vec2i,int]()
  t[0,1] = 1
  assert 1 == t[0,1]

  echo "All vecna asserts passed!"
