
import sequtils, strformat, strutils

import helpers/utils

const
  opAdd = "01"
  opMult = "02"
  opHalt = "99"
  opInput = "03"
  opOutput = "04"
  opTrueJump = "05"
  opFalseJump = "06"
  opLess = "07"
  opEqual = "08"

proc getData():seq[int] =
  ## using stripLineEnd
  var file = readFile("data/day05.txt")
  file.stripLineEnd()
  file.split(',').map(parseInt)

proc process(data:var seq[int], input:seq[int]):seq[int]=
  var
    c = 0 ## current position of instruction pointer
    code: string ## zero padded string of opcode
    cIn = 0 ## current position in input seq
    output:seq[int] = @[]
  proc getval(data:var seq[int],i:int):int =
    ## note this closes over c and code
    let revOffset = i + 2
    return if code[^revOffset] == '1': data[c+i] else: data[data[c+i]]
  while c < data.len:
    code = &"{data[c]:04}"
    case code[^2..^1]
    of opAdd:
      data[data[c+3]] = data.getval(1) + data.getval(2)
      c += 4
    of opMult:
      data[data[c+3]] = data.getval(1) * data.getval(2)
      c += 4
    of opInput:
      data[data[c+1]] = input[cIn]
      cIn += 1
      c += 2
    of opOutput:
      output.add data.getval(1)
      c += 2
    of opTrueJump:
      if data.getval(1) != 0:
        c = data.getval(2)
      else:
        c += 3
    of opFalseJump:
      if data.getval(1) == 0:
        c = data.getval(2)
      else:
        c += 3
    of opLess:
      data[data[c+3]] = if data.getval(1) < data.getval(2): 1 else: 0
      c += 4
    of opEqual:
      data[data[c+3]] = if data.getval(1) == data.getval(2): 1 else: 0
      c += 4
    of opHalt:
      return output
    else:
      err &"Unhandled opcode at position {c}: {data[c]}"
  err &"Ran out of input without getting 99:halt"

# copying assertions from day02.nim
# 1,0,0,0,99 becomes 2,0,0,0,99 (1 + 1 = 2).
# 2,3,0,3,99 becomes 2,3,0,6,99 (3 * 2 = 6).
# 2,4,4,5,99,0 becomes 2,4,4,5,99,9801 (99 * 99 = 9801).
# 1,1,1,4,99,5,6,0,99 becomes 30,1,1,4,2,5,6,0,99.

var
  s1 = @[1,0,0,0,99]
  s2 = @[2,3,0,3,99]
  s3 = @[2,4,4,5,99,0]
  s4 = @[1,1,1,4,99,5,6,0,99]

discard s1.process @[]
discard s2.process @[]
discard s3.process @[]
discard s4.process @[]

assert s1 == @[2,0,0,0,99]
assert s2 == @[2,3,0,6,99]
assert s3 == @[2,4,4,5,99,9801]
assert s4 == @[30,1,1,4,2,5,6,0,99]

proc oneOutput(s:seq[int]):int =
  if s.filterIt(it != 0).len <= 1: return s[^1]
  err &"Expected at most one non-zero output, but got: {$s}"

proc process(data:var seq[int], input: int):int =
  ## assumes single int input and output
  data.process(@[input]).oneOutput()

proc process(data: seq[int], input:int):int=
  ## like var process, but uses a copy of the data
  var d = data.deepCopy()
  return d.process(input)

proc part1*():int =
  var data = getData()
  let input = 1
  let
    output = data.process(input)
  assert 9775037 == output
  return output

# For example, here are several programs that take one input, compare it to the value 8, and then produce one output:
# 3,9,8,9,10,9,4,9,99,-1,8 - Using position mode, consider whether the input is equal to 8; output 1 (if it is) or 0 (if it is not).
# 3,9,7,9,10,9,4,9,99,-1,8 - Using position mode, consider whether the input is less than 8; output 1 (if it is) or 0 (if it is not).
# 3,3,1108,-1,8,3,4,3,99 - Using immediate mode, consider whether the input is equal to 8; output 1 (if it is) or 0 (if it is not).
# 3,3,1107,-1,8,3,4,3,99 - Using immediate mode, consider whether the input is less than 8; output 1 (if it is) or 0 (if it is not).

let
  t1 = @[3,9,8,9,10,9,4,9,99,-1,8]
  t2 = @[3,9,7,9,10,9,4,9,99,-1,8]
  t3 = @[3,3,1108,-1,8,3,4,3,99]
  t4 = @[3,3,1107,-1,8,3,4,3,99]

assert 1 == t1.process(8)
assert 0 == t1.process(2)
assert 1 == t2.process(2)
assert 0 == t2.process(9)
assert 1 == t3.process(8)
assert 0 == t3.process(9)
assert 1 == t4.process(2)
assert 0 == t4.process(9)

# Here are some jump tests that take an input, then output 0 if the input was zero or 1 if the input was non-zero:
# 3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9 (using position mode)
# 3,3,1105,-1,9,1101,0,0,12,4,12,99,1 (using immediate mode)

let
  t5 = @[3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9]
  t6 = @[3,3,1105,-1,9,1101,0,0,12,4,12,99,1]

assert 0 == t5.process(0)
assert 1 == t5.process(-5)
assert 0 == t6.process(0)
assert 1 == t6.process(-5)

# Here's a larger example:
# 3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,
# 1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,
# 999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99
# The above example program uses an input instruction to ask for a single number. The program will then output 999 if the input value is below 8, output 1000 if the input value is equal to 8, or output 1001 if the input value is greater than 8.

let
  t7 = @[3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99]

assert 999 == t7.process(-7)
assert 999 == t7.process(7)
assert 1000 == t7.process(8)
assert 1001 == t7.process(9)
assert 1001 == t7.process(9000)

proc part2*():int =
  var data = getData()
  let
    input = 5
    output = data.process(input)
  assert output == 15586959
  return output

when isMainModule:
  echo "Day05"
  echo &"Part1 {part1()}" # 9775037 √
  echo &"Part2 {part2()}" # 15586959 √
