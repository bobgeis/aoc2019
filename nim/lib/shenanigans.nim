## This file contains procs and macros.  Some of the things here were copied from or inspired by the work of others (eg debug which is an example macro from the nim manual).  Mostly this is for experimenting with the nim language/macros, and following on inspiriation from other.  Nothing here is asserted to be best practice or a good idea, use at your own risk!

## TODO: error handling in DistributeSymbol(s).  Also can they be made more versatile?
## TODO: unpacking macros: consolidate repetition, spread operator, error handling, fancify

# import math, strutils
import std/[macros, monotimes, strformat, tables, times]

# import bedrock


macro debug*(args: varargs[untyped]): untyped =
  ## A debugging macro that echos the given expression, both literally, and the resulting value.
  ## Copied from https://nim-lang.org/docs/manual.html#macros-debug-example
  # `args` is a collection of `NimNode` values that each contain the
  # AST for an argument of the macro. A macro always has to
  # return a `NimNode`. A node of kind `nnkStmtList` is suitable for
  # this use case.
  runnableExamples:
        let x,y = 5
        debug x + 5, y - 8
        # output: "x + 5: 10"
        # output: "y - 8: -3"
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

proc echoMonoTime(t:Duration, msg:string ="", iters:int = 1) =
  ## Need in ordre to call strformat's `&` macro from a template/macro
  var timeStr = msg
  if iters > 1:
    timeStr &= &", {iters} times"
  if timeStr.len > 0: timeStr &= " in "
  # timeStr &= &"{t.inNanoseconds.float / 1e6} ms"
  timeStr &= $t
  echo timeStr

template timeit*(msg: string = "", iters:int = 1, body: untyped):untyped =
  ## A handy timing template,
  ## Adapted from Kaynato's https://github.com/Kaynato/AdventOfCode/blob/master/timeit.nim
  # import std/[monotimes]
  let t1 = getMonoTime()
  for i in 1..iters:
    body
  let t2 = getMonoTime()
  echoMonoTime(t2-t1,msg,iters)

template timeit*(msg: string, body: untyped):untyped = timeit(msg,1,body)
template timeit*(iters: int, body: untyped):untyped = timeit("",iters,body)
template timeit*(body: untyped):untyped = timeit("",1,body)

proc binBy*[T, U](ts: openArray[T], fn: proc (x: T): U {.closure.}):TableRef[U,seq[T]] =
  ## Given a sequence `ts`, and a proc `fn` that will turn the items of `ts` into something hashable, create a table that bins each of the items into subsequences using the value of returned from `fn`.
  ## Inspired by partition from https://github.com/jabbalaci/nimpykot/blob/82ed5e40c50af133946555acf07bbf01071c2d0f/src/pykot/functional.nim
  runnableExamples:
        let # example 1
          digits = @[0,1,2,3,4,5,6,7,8,9]
          mod3 = digits.binBy(d => d mod 3)
        assert @[2,5,8] == mod3[2]
        let # example 2
          pairs = @[@[1,2],@[3,1],@[5,6],@[9,5]]
          mins = pairs.binBy(p => p.min)
        assert @[@[5,6],@[9,5]] == mins[5]
        let # example 3
          words = @["sam","so","am","alpine"]
          charTable = words.binBy(s => s[0])
        assert @["am", "alpine"] == charTable['a']
  result = newTable[U,seq[T]]()
  for t in ts:
    let s = fn(t)
    var v:seq[T] = result.getOrDefault(s,@[])
    v.add t
    result[s]= v

template liftToMap*(procName,newProcName:untyped,X:static[bool]=false) =
  ## Creates a new mapping proc called `newProcName` that calls `procName` on every element of a sequence to produce new output.  Note well that `newProcName` and `procName` can have the same name, and if they do then calling the produced function on nested sequences will apply it recursively.  This is essentially another way to do `mapIt(it.procName)`.  The last argument to this template is an eXport flag (default false), if set to true, then the proc must be defined at the top level and will be exported.
  ## Inspired by https://github.com/jlp765/seqmath/blob/master/src/seqmath/smath.nim#L55
  runnableExamples:
        abs.liftToMap(absMap)
        assert @[-1,-2,-3].absMap == @[1,2,3]
  proc newProcName[T](x: openarray[T]): auto =
    var temp: T
    type outType = type(procName(temp))
    result = newSeq[outType](x.len)
    for i in 0..<x.len:
      result[i] = procName(x[i])
  when X:
    export newProcName

template liftToMap2*(procName,newProcName:untyped,X:static[bool]=false) =
  ## Like liftToMap, this creates a new proc with the name `newProcName`, but the intention is to create a map function that takes TWO openarrays, instead of one, and the output is taken from calling the mapped proc with items from each array.  The last argument to this template is an eXport flag (default false), if set to true, then the proc must be defined at the top level and will be exported.
  ## Inspired by https://github.com/jlp765/seqmath/blob/master/src/seqmath/smath.nim#L55
  runnableExamples:
        `+`.liftToMap2(plusMap)
        assert @[-1,-2,3].plusMap2(@[4,6,2]) == @[3,4,5]
  proc newProcName[T,U](x: openarray[T], y: openarray[U]): auto =
    var temp: T
    var temp2: U
    let l = min(x.len,y.len)
    type outType = type(procName(temp,temp2))
    result = newSeq[outType](l)
    for i in 0..<l:
      result[i] = procName(x[i],y[i])
  when X:
    export newProcName

template liftToMap2padded*(procName,newProcName:untyped,X:static[bool]=false) =
  ## Like liftToMap, this creates a new proc with the name `newProcName`, but the intention is to create a map function that takes TWO openarrays, instead of one, and the output is taken from calling the mapped proc with items from each array.  The last argument to this template is an eXport flag (default false), if set to true, then the proc must be defined at the top level and will be exported.  This version will create a proc that accepts three open arrays of the same type, and also takes a `pad` argument that will be used to fill out any openarrays that are shorter than the longest.
  ## Inspired by https://github.com/jlp765/seqmath/blob/master/src/seqmath/smath.nim#L55
  runnableExamples:
        `+`.liftToMap2padded(plusMap2p)
        assert @[-1,-2,3].plusMap2p(@[4,6,2,2,3,4,5],pad=1) == @[3, 4, 5, 3, 4, 5, 6]
  proc newProcName[T](x,y: openarray[T],pad:T=T.default): auto =
    var temp: T
    let l = max(x.len,y.len)
    type outType = type(procName(temp,temp))
    result = newSeq[outType](l)
    for i in 0..<l:
      result[i] = procName(x.getOr(i,pad),y.getOr(i,pad))
  when X:
    export newProcName



template liftToMap3*(procName,newProcName:untyped,X:static[bool]=false) =
  ## Like liftToMap, this creates a new proc with the name `newProcName`, but the intention is to create a map function that takes THREE openarrays, instead of one, and the output is taken from calling the mapped proc with items from each array.  The last argument to this template is an eXport flag (default false), if set to true, then the proc must be defined at the top level and will be exported.
  ## Inspired by https://github.com/jlp765/seqmath/blob/master/src/seqmath/smath.nim#L55
  runnableExamples:
        from bedrock import between
        between[int].liftToMap3(btMap)
        assert @[1,2,3].btMap(@[4,6,2],@[-3,1,1]) == @[true, true, false]
        proc foo(x:string,y:int,z:float):int64 = (x.parseInt + y + z.floor.int).int64
        assert foo("3",2,3.0) == 8'i64
        foo.liftToMap3(fooMap)
        assert fooMap(@["3","5"],@[2,3],@[2.0,10.0]) == @[7'i64, 18]
  proc newProcName[T,U,V](x: openarray[T],y: openarray[U],z: openarray[V]): auto =
    var
      temp1: T
      temp2: U
      temp3: V
    let l = min([x.len, y.len, z.len])
    type outType = type(procName(temp1,temp2,temp3))
    result = newSeq[outType](l)
    for i in 0..<l:
      result[i] = procName(x[i],y[i],z[i])
  when X:
    export newProcName

template liftToMap3padded*(procName,newProcName:untyped,X:static[bool]=false) =
  ## Like liftToMap, this creates a new proc with the name `newProcName`, but the intention is to create a map function that takes THREE openarrays, instead of one, and the output is taken from calling the mapped proc with items from each array.  The last argument to this template is an eXport flag (default false), if set to true, then the proc must be defined at the top level and will be exported.  This version will create a proc that accepts three open arrays of the same type, and also takes a `pad` argument that will be used to fill out any openarrays that are shorter than the longest.
  ## Inspired by https://github.com/jlp765/seqmath/blob/master/src/seqmath/smath.nim#L55
  # runnableExamples: discard
  proc newProcName[T](x,y,z: openarray[T],pad:T): auto =
    var temp: T
    let l = max(x.len,y.len)
    type outType = type(procName(temp,temp,temp))
    result = newSeq[outType](l)
    for i in 0..<l:
      result[i] = procName(x.getOr(i,pad),y.getOr(i,pad),z.getOr(i,pad))
  when X:
    export newProcName


proc recurisveReplace(body, placeholder, target: NimNode): NimNode =
  ## This is a helper function for DistributeSymbol and DistributeSymbols
  ## Adapted from: https://github.com/Kaynato/AdventOfCode/blob/9223e1b5c8675b1b6664d41b9dc984759c0aba17/graphlib/copymacro.nim
  if body.kind == nnkIdent and body.strVal == placeholder.strVal:
    return target
  else:
    result = copyNimNode(body)
    for n in body:
      result.add(recurisveReplace(n, placeholder, target))

macro DistributeSymbol*(standIn, targetList, body: untyped): untyped =
  ## For every item in `targetList` it will call body with `standIn` replaced with the item.  This can be used to quickly eliminate large amounts of boilerplate.  Many potential uses of this can be served by templates, but it's fun to play with macros.  TODO: better error handling.
  ## Adapted from: https://github.com/Kaynato/AdventOfCode/blob/9223e1b5c8675b1b6664d41b9dc984759c0aba17/graphlib/copymacro.nim
  runnableExamples:
        DistributeSymbol(Op, [`+=`, `-=`, `*=`]):
          proc Op*(a: var (x:int,y:int), b: (x:int,y:int)) =
            Op(a.x, b.x)
            Op(a.y, b.y)
        var a,b = (x:2,y:2)
        a += b
        a -= b
        a *= b
        assert a == (x:4,y:4)
  ##
  result = newNimNode(nnkStmtList)
  for target in targetList:
    result.add(body.recurisveReplace(standIn, target))
  result.add()
  # echo treeRepr result

macro DistributeSymbols*(standIns, targetLists, body: untyped): untyped =
  ## Similar to DistributeSymbol, except the standIns and targetLists are both lists themselves.  Every list in targetLists, a new instance of the body will be made with every symbol in standIns replaced by the symbol in the target list with the same offset.  This can be used to quickly eliminate large amounts of boilerplate.  Many potential uses of this can be served by templates, but it's fun to play with macros.  TODO: better error handling.
  ## Adapted from: https://github.com/Kaynato/AdventOfCode/blob/9223e1b5c8675b1b6664d41b9dc984759c0aba17/graphlib/copymacro.nim
  runnableExamples:
        DistributeSymbols([Name,Num],[[Tab2i,2],[Tab3i,3]]):
          type Name[T] = Table[array[Num,int],T]
        var tab3i:Tab3i[char] = initTable[array[3,int],char]()
  ##
  result = newNimNode(nnkStmtList)
  for targetList in targetLists:
    # echo targetList.repr
    var statement = body
    for i in 0..<targetList.len:
      statement = statement.recurisveReplace(standIns[i],targetList[i])
    result.add statement
    continue
  result.add()
  # echo treeRepr result
  # echo result.repr


macro `..=`*(lhs:untyped, rhs:typed):auto =
  ## Unpacking macro: Use this to assign multiple variables from a data structure.  If the data structure uses numerical indexes, then you can use notation like: `[x,y,_,w] ..= someSeq`.  Note that _s are skipped.  If the data structure is an object or named tuple, then you can use notation like: `{x,y,z:zCoord,w} ..= someTuple`.  Note that :s are used to rename variables, otherwise the name of the variable will be the name of the field.  There are three flavors of this macro: `..=` defines lets, `..=^` defines vars, and `..=!` assigns to existing vars.
  ## Adapted from https://github.com/Kaynato/AdventOfCode/blob/master/unpack.nim and https://github.com/technicallyagd/unpack
  runnableExamples:
        type Foo = object
          x,y,z:int
        let foo = Foo(x:3,y:5,z:8)
        {x,y,z:zCoord} ..= foo
        assert [x,y,zCoord] == [3,5,8]
        [a,b,_,_,e] ..= @[5,6,7,8,9,10,11,12,13]
        assert [a,b,e] == [5,6,9]
  let t = genSym()
  result = newStmtList(quote do:
    let `t` = `rhs`)
  if lhs.kind == nnkBracket or lhs.kind == nnkPar:
    for i in 0..<lhs.len:
      let v = lhs[i]
      if $v.toStrLit != "_":
        result.add(quote do:
          let `v` = `t`[`i`])
  elif lhs.kind == nnkCurly or lhs.kind == nnkTableConstr:
    for i in 0..<lhs.len:
      if lhs[i].kind == nnkExprColonExpr:
        let
          v0 = lhs[i][0]
          v1 = lhs[i][1]
        result.add(quote do:
          let `v1` = `t`.`v0`)
      else:
        let v = lhs[i]
        result.add(quote do:
          let `v` = `t`.`v`)
  # echo treeRepr result
  # echo result.repr

macro `..=^`*(lhs:untyped, rhs:typed):auto =
  ## Unpacking macro: Use this to assign multiple variables from a data structure.  If the data structure uses numerical indexes, then you can use notation like: `[x,y,_,w] ..= someSeq`.  Note that _s are skipped.  If the data structure is an object or named tuple, then you can use notation like: `{x,y,z:zCoord,w} ..= someTuple`.  Note that :s are used to rename variables, otherwise the name of the variable will be the name of the field.  There are three flavors of this macro: `..=` defines lets, `..=^` defines vars, and `..=!` assigns to existing vars.
  ## Adapted from https://github.com/Kaynato/AdventOfCode/blob/master/unpack.nim and https://github.com/technicallyagd/unpack
  runnableExamples:
        let s = @[1,2,3,4]
        [a,b,_,c] ..=^ s
        a += c
        assert a == 5
  let t = genSym()
  result = newStmtList(quote do:
    let `t` = `rhs`)
  if lhs.kind == nnkBracket or lhs.kind == nnkPar:
    for i in 0..<lhs.len:
      let v = lhs[i]
      if $v.toStrLit != "_":
        result.add(quote do:
          var `v` = `t`[`i`])
  elif lhs.kind == nnkCurly or lhs.kind == nnkTableConstr:
    for i in 0..<lhs.len:
      if lhs[i].kind == nnkExprColonExpr:
        let
          v0 = lhs[i][0]
          v1 = lhs[i][1]
        result.add(quote do:
          var `v1` = `t`.`v0`)
      else:
        let v = lhs[i]
        result.add(quote do:
          var `v` = `t`.`v`)

macro `..=!`*(lhs:untyped, rhs:typed):auto =
  ## Unpacking macro: Use this to assign multiple variables from a data structure.  If the data structure uses numerical indexes, then you can use notation like: `[x,y,_,w] ..= someSeq`.  Note that _s are skipped.  If the data structure is an object or named tuple, then you can use notation like: `{x,y,z:zCoord,w} ..= someTuple`.  Note that :s are used to rename variables, otherwise the name of the variable will be the name of the field.  There are three flavors of this macro: `..=` defines lets, `..=^` defines vars, and `..=!` assigns to existing vars.
  ## Adapted from https://github.com/Kaynato/AdventOfCode/blob/master/unpack.nim and https://github.com/technicallyagd/unpack
  runnableExamples:
        var x,y,z:int = 0
        let coords = [5,7,12]
        [x,y,z] ..=! coords
        assert x + y == z
  let t = genSym()
  result = newStmtList(quote do:
    let `t` = `rhs`)
  if lhs.kind == nnkBracket or lhs.kind == nnkPar:
    for i in 0..<lhs.len:
      let v = lhs[i]
      if $v.toStrLit != "_":
        result.add(quote do:
          `v` = `t`[`i`])
  elif lhs.kind == nnkCurly or lhs.kind == nnkTableConstr:
    for i in 0..<lhs.len:
      if lhs[i].kind == nnkExprColonExpr:
        let
          v0 = lhs[i][0]
          v1 = lhs[i][1]
        result.add(quote do:
          `v1` = `t`.`v0`)
      else:
        let v = lhs[i]
        result.add(quote do:
          `v` = `t`.`v`)

###

when isMainModule:
  import math, strutils
  import bedrock

  # this needs to be at the top level or trying to export will fail
  abs.liftToMap(absMap,X=true)
  `+`.liftToMap2(plusMap2,X=true)
  block:
        absMap.liftToMap(absMapMap)
        assert @[1,-2,3].absMap == @[1, 2, 3]
        assert @[@[1,-2,3],@[-3,-4]].absMapMap == @[@[1, 2, 3], @[3, 4]]

  block:
        `+`.liftToMap2(plusMap2)
        `+`.liftToMap2padded(plusMap2p)
        assert @[-1,-2,3].plusMap2(@[4,6,2]) == @[3,4,5]
        assert @[-1,-2,3].plusMap2p(@[4,6,2,2,3,4,5],pad=1) == @[3, 4, 5, 3, 4, 5, 6]

  block:
        between[int].liftToMap3(btMap)
        assert @[1,2,3].btMap(@[4,6,2],@[-3,1,1]) == @[true, true, false]
        proc foo(x:string,y:int,z:float):int64 = (x.parseInt + y + z.floor.int).int64
        assert foo("3",2,3.0) == 8'i64
        foo.liftToMap3(fooMap)
        assert fooMap(@["3","5"],@[2,3],@[2.0,10.0]) == @[7'i64, 18]

  block:
        type
          Foo = object
            x,y,z:int
        let foo = Foo(x:3,y:5,z:8)
        {x,y,z:zCoord} ..= foo
        assert [x,y,zCoord] == [3,5,8]
        [a,b,_,_,e] ..= @[5,6,7,8,9,10,11,12,13]
        assert [a,b,e] == [5,6,9]

  block:
        let s = @[1,2,3,4]
        [a,b,_,c] ..=^ s
        a += b + c
        assert a == 7

  block:
        var x,y,z:int = 0
        let coords = [5,7,12]
        [x,y,z] ..=! coords
        assert x + y == z

  echo "shenanigans asserts passed"
