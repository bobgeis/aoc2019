
## Vectors of N dimensions and Any type.  AKA: Yet Another Simple Vector Lib, but "yasvl" is harder to pronounce.

# std
import math

# nimble

# local
import utils

type
  Vec*[N: static[int]; SomeNumber] = array[N,SomeNumber]
  Vec2i* = Vec[2,int]
  Vec2i64* = Vec[2,int64]
  Vec3i* = Vec[3,int]

# convenience getters & setters for x,y,z,w
template x*[N,A](a:Vec[N,A]):untyped = a[0]
template y*[N,A](a:Vec[N,A]):untyped = a[1]
template z*[N,A](a:Vec[N,A]):untyped = a[2]
template w*[N,A](a:Vec[N,A]):untyped = a[3]
template `x=`*[N,A](a:Vec[N,A],b:A):untyped = a[0]= b
template `y=`*[N,A](a:Vec[N,A],b:A):untyped = a[1]= b
template `z=`*[N,A](a:Vec[N,A],b:A):untyped = a[2]= b
template `w=`*[N,A](a:Vec[N,A],b:A):untyped = a[3]= b

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
proc mdist*[N,A](a:Vec[N,A]):A =
  ## Manhattan distance to origin
  for i in 0..a.high:
    result += a[i].abs
proc mdist*[N,A](a,b:Vec[N,A]):A =
  for i in 0..a.high:
    result += (b[i] - a[i]).abs



proc angle*[A](a:Vec[2,A]):float = arctan2(a.y.float,a.x.float)
proc angle*[A](a,b:Vec[2,A]):float = arctan2((b.y-a.y).float, (b.x-a.x).float)

proc aabb*[A](a,c1,c2:Vec[2,A]):bool =
  ## Is point `a` within a aabb/rectangle described by two opposing corners `c1` and `c2`?
  a.x.bt(c1.x,c2.x) and a.y.bt(c1.y,c2.y)

proc onseg*[A](a,p1,p2:Vec[2,A]):bool =
  ## Is the point `a` on the line segment `p1` to `p2`?
  a.aabb(p1,p2) and ((a.x - p1.x)/(p2.x - p1.x) == (a.y - p1.y)/(p2.y - p1.y))



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

  echo "All vecna asserts passed!"
