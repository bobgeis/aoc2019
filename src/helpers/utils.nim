
## This file is for simple procs and types.  It may import from the std libs or nimble libs, but from no local files.  It should contain generally useful procs, things that you potentially might have wished were in the std lib.

import macros, math, strformat, strutils, sugar, tables

proc square*(n:SomeNumber):SomeNumber = n * n

proc flip*[T,U](t:(T,U)):(U,T) = (t[1],t[0]) ## Take a two item tuple, and return a tuple of the items in reverse order

proc spy*[T](t:T,msg = ""):T = # For when you want to echo something in the middle of a chain of proc calls.
  echo &"{msg}{$t}"
  return t

proc toString*[T](t:T):string {.inline.}= $t ## For when you want to turn something into a string in the middle of a chain of proc calls.

proc getOr*[T](s: openArray[T], i:int, def:T):T =
  ## GetOrDefault for sequences
  if i < s.len: s[i] else: def

proc parseInt*(c:char):int = parseInt($c)

proc reversed*[T](s:seq[T]):seq[T] =
  ## Create a copy with items in reverse order. In contrast to `reverse` which is in place.
  result = newSeq[T](s.len)
  for i in 1..s.len:
    result[i-1] = s[^i]

proc reverse*[T](s:var seq[T]) =
  ## Reverse the seq in place. In contrast to `reversed` which returns a new seq.
  let mid = s.len div 2
  var swap: T
  for i in 1..mid:
    swap = s[i-1]
    s[i-1] = s[^i]
    s[^i] = swap

proc flatten*[T](ss:seq[seq[T]]):seq[T] =
  ## Take a seq of seq of T and return a seq of T.
  for s in ss:
    for t in s:
      result.add t

proc between*(m,a,b:SomeNumber):bool =
  ## Is m between a and b (inclusive)?  Doesn't care about order of a or b. Remember if you know a<b, then you can just do "m in a..b".
  (m <= a and m >= b) or (m >= a and m <= b)

proc bt*(m,a,b:SomeNumber):bool {.inline.} =
  ## Alias for `between`. Is m between a and b (inclusive)?  Doesn't care about order of a or b.  Remember if you know a<b, then you can just do "m in a..b".
  m.between(a,b)

proc err*(msg = "Error!") =
  ## easy terse error
  raise newException(Exception, msg)

proc getlines*(path:string):seq[string] =
  for line in path.lines:
    result.add line

proc transpose*[T](ss:seq[seq[T]]):seq[seq[T]] =
  result = newSeqOfCap[seq[T]](ss[0].len)
  for i in 0..<ss[0].len:
    var row = newSeqOfCap[T](ss.len)
    for j in 0..<ss.len:
      row.add ss[j][i]
    result.add row

proc groupsOf*[T](s:seq[T],g:Positive):seq[seq[T]] =
  ## Chop a seq `s` into a seq of subseqs each of length `g` (the last one may be shorter)
  var
    sub = newSeqofCap[T](g)
    i = 0
  for t in s:
    sub.add t
    i += 1
    if i >= g:
      result.add sub
      sub = newSeqOfCap[T](g)
      i = 0
  if sub.len > 0: result.add sub

proc findb*[T](s:openArray[T],t:T):int =
  ## Find backwards: find the offset of the last instance of the item `t` in the sequence `s`.
  for i in countdown(s.high,0):
    if s[i] == t: return i
  return -1

proc pmod*(v,m:int):int =
  ## Pythonic modulus.  The output will have the same sign as the divisor `m`.
  runnableExamples:
    assert 5.pmod(3) == 2 # same as 5 mod 3
    assert pmod(-5,3) == 1 # -5 mod 3 would give -2
    assert 5.pmod(-3) == -1 # 5 mod -3 would give 2
    assert pmod(-5,-3) == -2 # same as 5 mod 3
  ((v mod m) + m) mod m

proc pdiv*(a,b:int):int =
  ## Pythonic integer division.  Nim will round towards zero whereas python will always round down.
  runnableExamples:
    assert 9.pdiv(2) == 4 # same as 9 div 2
    assert pdiv(-9,2) == -5 # -9 div 2 would give -4
    assert 9.pdiv(-2) == -5 # 9 div -2 would give -4
  result = a div b
  if a*b < 0: result = result - 1

proc imod*(v,m:int):int =
  ## Multiplicative inverse in a given modulus.
  ## Find the value x such that (x * v) % m == 1
  ## Copied from: https://bugs.python.org/issue36027
  runnableExamples:
    assert imod(138,191) == 18
    assert imod(38,191) == 186
    assert imod(23,120) == 47
  var
    x,q = 0
    lastx = 1
    a = m
    b = v
  while b != 0:
    (a,q,b) = (b, a div b, a mod b)
    (x,lastx) = (lastx - q * x, x)
  result = (1 - lastx * m) div v
  if result < 0:
    result += m
  # assert result.bt(0,m)
  # assert result * v mod m == 1

proc pow*(x,y,m:int):int =
  ## Unoptimized implementation of modulus power
  runnableExamples:
    assert pow(3, 2, 4) == 1
    assert pow(10, 9, 6) == 4
    assert pow(450, 768, 517) == 34
  if y == 0: return 1
  var p = pow(x, y div 2, m) mod m
  p = (p * p) mod m
  return if (y and 1) == 0: p else: (x * p) mod m

when isMainModule:
  assert @[@[1,2,3],@[4,5,6]].flatten == @[1,2,3,4,5,6]

  assert 5.pmod(3) == 2 # same as 5 mod 3
  assert pmod(-5,3) == 1 # -5 mod 3 would give -2
  assert 5.pmod(-3) == -1 # 5 mod -3 would give 2
  assert pmod(-5,-3) == -2 # same as 5 mod 3

  assert 9.pdiv(2) == 4 # same as 9 div 2
  assert pdiv(-9,2) == -5 # -9 div 2 would give -4
  assert 9.pdiv(-2) == -5 # 9 div -2 would give -4

  assert imod(138,191) == 18
  assert imod(38,191) == 186
  assert imod(23,120) == 47

  assert pow(3, 2, 4) == 1
  assert pow(10, 9, 6) == 4
  assert pow(450, 768, 517) == 34

  echo "helpers/utils asserts passed"

