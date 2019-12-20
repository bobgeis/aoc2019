
# deprecated in favor of vecna

import math

import utils

type
  Point*[SomeNumber] = tuple
    x,y:SomeNumber

proc `-`*[T](a,b:Point[T]):Point[T] = (b.x - a.x, b.y - a.y)
proc `+`*[T](a,b:Point[T]):Point[T] = (b.x + a.x, b.y + a.y)
proc `*`*[T](a,b:Point[T]):Point[T] = (b.x * a.x, b.y * a.y)
proc `+=`*[T](a:var Point[T],b:Point[T]) =
  a.x += b.x
  a.y += b.y
proc `-=`*[T](a:var Point[T],b:Point[T]) =
  a.x -= b.x
  a.y -= b.y
proc `*=`*[T](a:var Point[T],b:Point[T]) =
  a.x *= b.x
  a.y *= b.y

proc angle*[T](a:Point[T]):float = arctan2(a.y.float,a.x.float)
proc angle*[T](a,b:Point[T]):float = arctan2((b.y-a.y).float, (b.x-a.x).float)

proc mdist*[T](a:Point[T]):T =
  ## Manhattan distance from origin to a.
  a.x.abs + a.y.abs

proc mdist*[T](a,b:Point[T]):T =
  ## Manhattan distance from a to b.
  (b.x - a.x).abs + (b.y - a.y).abs

proc aabb*[T](a,c1,c2:Point[T]):bool =
  ## Is point `a` within a aabb/rectangle described by two opposing corners `c1` and `c2`?
  a.x.bt(c1.x,c2.x) and a.y.bt(c1.y,c2.y)

proc onseg*[T](a,start,stop:Point[T]):bool =
  ## Is the point a on the line segment start to stop?
  a.aabb(start,stop) and ((a.x - start.x)/(stop.x - start.x) == (a.y - start.y)/(stop.y - start.y))

when isMainModule:
  echo "Ran point2d"
