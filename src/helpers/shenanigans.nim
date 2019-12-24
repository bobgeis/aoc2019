
# import math, strutils
import std/[macros]

# import utils

proc getOr*[T](s: openArray[T], i:int, def:T):T =
  ## GetOrDefault for sequences
  if i < s.len: s[i] else: def

template liftToMap*(procName,newProcName) =
  ## Inspired by https://github.com/jlp765/seqmath/blob/master/src/seqmath/smath.nim#L55
  ## Creates a new mapping proc called `newProcName` that calls `procName` on every element of a sequence to produce new output.
  ## NOTE: `newProcName` and `procName` can have the same name, and if they do then calling the produced function on nested sequences will apply it recursively.
  ## This is essentially another way to do `mapIt(it.procName)`
  runnableExamples:
    abs.liftToMap(absMap)
    assert @[-1,-2,-3].absMap == @[1,2,3]
  proc newProcName*[T](x: openarray[T]): auto =
    var temp: T
    type outType = type(procName(temp))
    result = newSeq[outType](x.len)
    for i in 0..<x.len:
      result[i] = procName(x[i])

template liftToMap2*(procName,newProcName) =
  ## Inspired by https://github.com/jlp765/seqmath/blob/master/src/seqmath/smath.nim#L55
  ## Like liftToMap, this creates a new proc with the name `newProcName`, but the intention is to create a map function that takes TWO openarrays, instead of one, and the output is taken from calling the mapped proc with items from each array.
  runnableExamples:
    `+`.liftToMap2(plusMap)
    assert @[-1,-2,3].plusMap(@[4,6,2]) == @[3,4,5]
    assert @[-1,-2,3].plusMap2(@[4,6,2,2,3,4,5],pad=1) == @[3, 4, 5, 3, 4, 5, 6]
  proc newProcName*[T,U](x: openarray[T], y: openarray[U]): auto =
    ## Map two openarrays together to produce a seq.  The arguments can of different types and they will stop when the shortest arg runs out of items.  OR the arguments can be of the same type and an optional padding argument can be given.
    var temp: T
    var temp2: U
    let l = min(x.len,y.len)
    type outType = type(procName(temp,temp2))
    result = newSeq[outType](l)
    for i in 0..<l:
      result[i] = procName(x[i],y[i])
  proc newProcName*[T](x,y: openarray[T],pad:T): auto =
    ## Map two openarrays together to produce a seq.  The arguments can of different types and they will stop when the shortest arg runs out of items.  OR the arguments can be of the same type and an optional padding argument can be given.
    var temp: T
    let l = max(x.len,y.len)
    type outType = type(procName(temp,temp))
    result = newSeq[outType](l)
    for i in 0..<l:
      result[i] = procName(x.getOr(i,pad),y.getOr(i,pad))

template liftToMap3*(procName,newProcName) =
  ## Inspired by https://github.com/jlp765/seqmath/blob/master/src/seqmath/smath.nim#L55
  ## Like liftToMap, this creates a new proc with the name `newProcName`, but the intention is to create a map function that takes THREE openarrays, instead of one, and the output is taken from calling the mapped proc with items from each array.
  runnableExamples:
    bt[int].liftToMap3(btMap)
    assert @[1,2,3].btMap(@[4,6,2],@[-3,1,1]) == @[true, true, false]
    proc foo(x:string,y:int,z:float):int64 = (x.parseInt + y + z.floor.int).int64
    assert foo("3",2,3.0) == 8'i64
    foo.liftToMap3(fooMap)
    assert fooMap(@["3","5"],@[2,3],@[2.0,10.0]) == @[7'i64, 18]
  proc newProcName*[T,U,V](x: openarray[T],y: openarray[U],z: openarray[V]): auto =
    ## Map three openarrays together to produce a seq.  The arguments can of different types and they will stop when the shortest arg runs out of items.  OR the arguments can be of the same type and an optional padding argument can be given.
    var
      temp1: T
      temp2: U
      temp3: V
    let l = min(x.len,y.len)
    type outType = type(procName(temp1,temp2,temp3))
    result = newSeq[outType](l)
    for i in 0..<l:
      result[i] = procName(x[i],y[i],z[i])
  proc newProcName*[T](x,y,z: openarray[T],pad:T): auto =
    ## Map three openarrays together to produce a seq.  The arguments can of different types and they will stop when the shortest arg runs out of items.  OR the arguments can be of the same type and an optional padding argument can be given.
    var temp: T
    let l = max(x.len,y.len)
    type outType = type(procName(temp,temp,temp))
    result = newSeq[outType](l)
    for i in 0..<l:
      result[i] = procName(x.getOr(i,pad),y.getOr(i,pad),z.getOr(i,pad))

# https://nim-lang.org/docs/manual.html#macros-debug-example is actually useful, you might want to add it here
macro debug*(args: varargs[untyped]): untyped =
  ## Copied from https://nim-lang.org/docs/manual.html#macros-debug-example
  # `args` is a collection of `NimNode` values that each contain the
  # AST for an argument of the macro. A macro always has to
  # return a `NimNode`. A node of kind `nnkStmtList` is suitable for
  # this use case.
  result = nnkStmtList.newTree()
  # iterate over any argument that is passed to this macro:
  for n in args:
    # add a call to the statement list that writes the expression;
    # `toStrLit` converts an AST to its string representation:
    result.add newCall("write", newIdentNode("stdout"), newLit(n.repr))
    # add a call to the statement list that writes ": "
    result.add newCall("write", newIdentNode("stdout"), newLit(": "))
    # add a call to the statement list that writes the expressions value:
    result.add newCall("writeLine", newIdentNode("stdout"), n)

###

when isMainModule:
  import math, strutils
  import utils

  abs.liftToMap(absMap)
  absMap.liftToMap(absMapMap)
  assert @[1,-2,3].absMap == @[1, 2, 3]
  assert @[@[1,-2,3],@[-3,-4]].absMapMap == @[@[1, 2, 3], @[3, 4]]

  `+`.liftToMap2(plusMap2)
  assert @[-1,-2,3].plusMap2(@[4,6,2]) == @[3,4,5]
  assert @[-1,-2,3].plusMap2(@[4,6,2,2,3,4,5],pad=1) == @[3, 4, 5, 3, 4, 5, 6]

  bt[int].liftToMap3(btMap)
  assert @[1,2,3].btMap(@[4,6,2],@[-3,1,1]) == @[true, true, false]
  proc foo(x:string,y:int,z:float):int64 = (x.parseInt + y + z.floor.int).int64
  assert foo("3",2,3.0) == 8'i64
  foo.liftToMap3(fooMap)
  assert fooMap(@["3","5"],@[2,3],@[2.0,10.0]) == @[7'i64, 18]

  echo "All shenanigans asserts all passed!"
