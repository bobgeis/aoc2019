
# std lib modules https://nim-lang.org/docs/lib.html
import std/[sequtils, strformat, strscans]

# nimble pkgs
import pkg/[stint]

type
  ShuffleOp = enum
    soCut, soInc, soDeal,

const
  dayNum = "22"
  inputFile = &"data/day{dayNum}.txt"

proc testFile(i:int):string = &"data/day{dayNum}test{i}.txt"

proc parseLine(s:string or TaintedString):(ShuffleOp,int) =
  var i: int
  if s.scanf("deal with increment $i",i): return (soInc,i)
  elif s.scanf("cut $i",i): return (soCut,i)
  else: return (soDeal,0)

proc parseFile(f:string):seq[(ShuffleOp,int)] =
  for l in f.lines():
    result.add l.parseLine

let
  t1 = 1.testFile.parseFile # 0 3 6 9 2 5 8 1 4 7
  t2 = 2.testFile.parseFile # 3 0 7 4 1 8 5 2 9 6
  t3 = 3.testFile.parseFile # 6 3 0 7 4 1 8 5 2 9
  t4 = 4.testFile.parseFile # 9 2 5 8 1 4 7 0 3 6

### part 1 ###

proc findNextOffset(off,length:int,op:(ShuffleOp,int)):int =
  case op[0]
  of soDeal:
    return length - 1 - off
  of soCut:
    return (off - op[1] + length) mod length
  of soInc:
    return (off * op[1]) mod length


let tenCards = @[0,1,2,3,4,5,6,7,8,9]
assert @[9, 8, 7, 6, 5, 4, 3, 2, 1, 0] == tenCards.mapit(it.findNextOffset(10,(soDeal,0)))
assert @[7, 8, 9, 0, 1, 2, 3, 4, 5, 6] == tenCards.mapit(it.findNextOffset(10,(soCut,3)))
assert @[4, 5, 6, 7, 8, 9, 0, 1, 2, 3] == tenCards.mapit(it.findNextOffset(10,(soCut,-4)))
assert @[0, 3, 6, 9, 2, 5, 8, 1, 4, 7] == tenCards.mapit(it.findNextOffset(10,(soInc,3)))

proc findLastOffset(off,length:int,ops:seq[(ShuffleOp,int)]):int =
  result = off
  for op in ops:
    result = result.findNextOffset(length,op)

assert @[0, 7, 4, 1, 8, 5, 2, 9, 6, 3] == tenCards.mapit(it.findLastOffset(10,t1))
assert @[1, 4, 7, 0, 3, 6, 9, 2, 5, 8] == tenCards.mapit(it.findLastOffset(10,t2))
assert @[2, 5, 8, 1, 4, 7, 0, 3, 6, 9] == tenCards.mapit(it.findLastOffset(10,t3))
assert @[7, 4, 1, 8, 5, 2, 9, 6, 3, 0] == tenCards.mapit(it.findLastOffset(10,t4))

proc part1*():int =
  let inputs = inputFile.parseFile
  result = 2019.findLastOffset(10_007,inputs)
  assert 1510 == result

### part 2 ###
# 119315717514047 cards
# 101741582076661 apply full input this many times
# what number is on the card at position 2020?

# I was only able to do this by looking at other people's solutions and working out what would be good for me.
# THIS WAS KEY: https://github.com/zedrdave/advent_of_code/blob/master/2019/22/__main__.py#L48
# I needed to implement my own pythonic mod, div, and pow functions, otherwise things were very confusingly wrong.

const
  size = 119315717514047.i128
  reps = 101741582076661.i128
  stopOffset = 2020.i128

proc pmod(v,m:Int128):Int128 =
  ## pythonic modulo. python keeps divisor's sign, nim keeps dividend's. This can result in a different absolute value as well!
  ((v mod m) + m) mod m

proc pdiv(a,b:Int128):Int128 =
  ## pythonic integer division. python rounds down, while nim rounds towards zero
  result = a div b
  if a*b < 0.i128: result = result - 1.i128

proc pow(x,y,m:Int128):Int128 =
  ## pythonic modulo exponentiation.
  assert y >= 0.i128
  if y == 0.i128: return 1.i128
  # var p = pow(x, y div 2.i128, m) mod m
  var p = pow(x, y.pdiv(2.i128), m).pmod(m)
  # p = (p * p) mod m
  p = (p * p).pmod(m)
  # return if (y and 1.i128) == 0.i128: p else: (x * p) mod m
  return if (y and 1.i128) == 0.i128: p else: (x * p).pmod(m)

assert pow(3.i128, 2.i128, 4.i128) == 1.i128
assert pow(10.i128, 9.i128, 6.i128) == 4.i128
assert pow(450.i128, 768.i128, 517.i128) == 34.i128
assert pow(450.i128, 768.i128, 517.i128) == 34.i128
assert pow(-450.i128, 768.i128, 517.i128) == 34.i128
assert pow(-450.i128, 768.i128, -517.i128) == -483.i128
assert pow(450.i128, 768.i128, -517.i128) == -483.i128

proc getConstants(m:Int128,ops:seq[(ShuffleOp,int)]):(Int128,Int128) =
  var (a,b) = (1.i128,0.i128)
  for op in ops:
    case op[0]
    of soDeal:
      a = (-a).pmod(m)
      b = (m - 1.i128 - b).pmod(m)
    of soCut:
      a = a
      b = (b - op[1].i128).pmod(m)
    of soInc:
      a = (a * op[1].i128).pmod(m)
      b = (b * op[1].i128).pmod(m)
  return (a,b)

proc part2*():Int128 =
  let
    inputs = inputFile.parseFile
    (a,b) = getConstants(size,inputs)
    r = (b * pow(1.i128 - a, size - 2.i128, size)).pmod(size)
  result = ((stopOffset - r) * pow(a, reps*(size-2.i128),size) + r).pmod(size)
  assert 10307144922975.i128 == result

when isMainModule:
  echo &"Day{dayNum}"
  echo &"Part1 {part1()}"
  echo &"Part2 {part2()}"

