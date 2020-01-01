
# std lib modules https://nim-lang.org/docs/lib.html
import std/[deques, math, sequtils, sets, strformat, strtabs, strutils, tables]

# local lib modules
import lib/[aocutils, bedrock, shenanigans]

const
  dayNum = "16"
  inputFile = inputFilePath(dayNum)

const
  basePattern = @[0, 1, 0, -1]

iterator pattern(digitOffset,length:int):(int,int) =
  var
    repeats = digitOffset
    baseOffset = 0
    count = 0
  while true:
    if repeats == 0:
      baseOffset = (baseOffset + 1) mod basePattern.len
      repeats = digitOffset
    else:
      repeats -= 1
    yield (count,basePattern[baseOffset])
    count += 1
    if count == length: break

proc stringToInts(s:string):seq[int] =
  s.mapIt(($it).parseInt) # there's probably a better way to do this

proc mult(x,y:int):int = x * y
mult.liftToMap2(mult)
# echo mult(@[1,2,3],@[-1,0,1])

proc iterate(s:string):string =
  let si = s.stringToInts
  var digits:seq[int] = @[]
  for i in 0..s.high:
    var sm = si
    for i,p in pattern(i,s.len):
      sm[i] = si[i] * p
    digits.add sm.sum.toString[^1].parseInt
  return digits.join

assert "48226158" == "12345678".iterate # 48226158
assert "34040438" == "12345678".iterate.iterate # 34040438
assert "03415518" == "12345678".iterate.iterate.iterate # 03415518
assert "01029498" == "12345678".iterate.iterate.iterate.iterate # 01029498

### part 1 ###

proc iterate(s:string,phases:int):string =
  result = s
  for i in 0..<phases:
    result = result.iterate

assert "24176176" == "80871224585914546619083218645595".iterate(100)[0..7]
assert "73745418" == "19617804207202209144916044189917".iterate(100)[0..7]
assert "52432133" == "69317163492948606335995924319873".iterate(100)[0..7]


proc part1*():int =
  result = inputFile.readFile.strip.iterate(100)[0..7].parseInt
  assert 85726502 == result

### part 2 ###

let
  inputInts = inputFile.readFile.strip.stringToInts
# echo inputString.len * 10_000   # 6_500_000
# echo inputString[0..6]          # 5_977_377 # the pattern doesn't matter after 3.25M, it's always +1

proc phase(intS:seq[int],target:int):seq[int] =
  var
    digits = newSeq[int](intS.len)
    n = 0
  for i in countdown(intS.high, (target - 7)): # this takes a while to run, I don't want to deal with off by one errors :P
    n = (n + intS[i]) mod 10
    digits[i] = n
  return digits

proc phases(intS:seq[int],target,phases:int):seq[int] =
  result = intS
  for i in 1..phases: result = result.phase(target)

proc doit(intS:seq[int]):string =
  let
    target = intS[0..6].join.parseInt
    phased = intS.repeat(10_000).flatten.phases(target,100)
  # echo &"target was: {target}"
  return phased[target..(target+7)].join

assert doit("03036732577212944063491565474664".stringToInts) == "84462026"
assert doit("02935109699940807407585447034323".stringToInts) == "78725270"
assert doit("03081770884921959731165446850517".stringToInts) == "53553731"


proc part2*():string =
  result = doit(inputInts)
  assert "92768399" == result


when isMainModule:
  echo "Day016"
  echo &"Part1 {part1()}"
  echo &"Part2 {part2()}"

# Compile command: 'nim c --hints=off --warnings=off  -d:danger -d:release --opt:speed -o:out/time_day16 nim/day16.nim'
# Run command: 'time ./out/time_day16'
# Day016
# Part1 85726502
# Part2 92768399

# real    0m1.782s
# user    0m1.528s
# sys     0m0.160s