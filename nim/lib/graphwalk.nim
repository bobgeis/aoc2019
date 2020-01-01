
import std/[algorithm, deques, heapqueue, math, sets, tables]

import shenanigans


proc bfs*[T](start:T,adjs:proc(n:T):seq[T]):Table[T,(int,T)] =
  var
    marked = initHashSet[T]()
    q = initDeque[(int,T)]()
    paths = initTable[T,(int,T)]()
  paths[start] = (0,start)
  q.addLast((0,start))
  while q.len > 0 :
    let (cost,n) = q.popFirst
    if paths.cb(n): return
    else:
      marked.incl n
    for m in n.adjs:
      if m in marked: continue
      paths[m] = (cost + 1, n)
      q.addLast((cost + 1, m))
  return paths

proc bfs*[T](start:T,adjs:proc(n:T):seq[T],cb:proc(paths:Table[T,(int,T)],n:T):bool) =
  var
    marked = initHashSet[T]()
    q = initDeque[(int,T)]()
    paths = initTable[T,(int,T)]()
  paths[start] = (0,start)
  q.addLast((0,start))
  while q.len > 0 :
    let (cost,n) = q.popFirst
    if paths.cb(n): return
    else:
      marked.incl n
    for m in n.adjs:
      if m in marked: continue
      paths[m] = (cost + 1, n)
      q.addLast((cost + 1, m))

type
  DjEnum = enum djSing ## This is used only to disambiguate which `<` is used by the heapqueue..  Likely a bug in my code somewhere, but works for now.  See if it can be eliminated in the future.
proc djPair[A,T](a:A,t:T):(A,DjEnum,T) {.inline.} = (a,djSing,t)
proc `<`*[A,T](a,b:(A,DjEnum,T)):bool = a[0] < b[0]

proc dijkstra*[A:SomeNumber;T](start:T,adjs:proc(n:T):seq[(A,T)]):Table[T,(A,T)] =
  var
    marked = initHashSet[T]()
    q = initHeapQueue[(A,DjEnum,T)]()
    paths = initTable[T,(A,T)]()
  paths[start] = (A.default,start)
  q.push(djPair(A.default,start))
  while q.len > 0:
    let (cost,_,n) = q.pop
    if n in marked: continue
    elif paths.cb(n): return
    else:
      marked.incl n
    for (c,m) in n.adjs:
      let
        newCost = cost + c
        (oldCost,_) = paths.getOrDefault(m,(A.high,start))
      if newCost < oldCost:
        paths[m] = (newCost,n)
        q.push(djPair(newCost,m))
  return paths

proc dijkstra*[A:SomeNumber;T](start:T,adjs:proc(n:T):seq[(A,T)],cb:proc(paths:Table[T,(A,T)],n:T):bool) =
  var
    marked = initHashSet[T]()
    q = initHeapQueue[(A,DjEnum,T)]()
    paths = initTable[T,(A,T)]()
  paths[start] = (A.default,start)
  q.push(djPair(A.default,start))
  while q.len > 0:
    let (cost,_,n) = q.pop
    if n in marked: continue
    elif paths.cb(n): return
    else:
      marked.incl n
    for (c,m) in n.adjs:
      let
        newCost = cost + c
        (oldCost,_) = paths.getOrDefault(m,(A.high,start))
      if newCost < oldCost:
        paths[m] = (newCost,n)
        q.push(djPair(newCost,m))

proc walkPath*[A:SomeNumber;T](paths:Table[T,(A,T)],stop:T):seq[T] =
  if stop notin paths: return @[]
  result.add stop
  var (_,curr) = paths[stop]
  while true:
    (_, curr) ..=! paths[curr]
    if curr == result[^1]: break
    result.add curr
  result.reverse
