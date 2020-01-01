
# std lib modules https://nim-lang.org/docs/lib.html
import std/[deques, sequtils, strformat, strutils]

# nimble pkgs
import pkg/[itertools]

# local lib modules
import lib/[aocutils, bedrock]

const
  dayNum = "07"
  inputFile = inputFilePath(dayNum)

proc readtext():seq[int] =
  toSeq(inputFile.lines)[0].split(',').mapIt(parseInt(it))

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

type
  StateKind = enum
    skRunning, skHalt, skInput, skOutput,
  IntcodeComputer = ref object
    mem: seq[int]
    input: Deque[int]
    output: Deque[int]
    state:StateKind
    ip:int

proc addInput(icc:var IntcodeComputer,inputs:seq[int]) =
  for i in inputs:
    icc.input.addLast i

proc addInput(icc:var IntcodeComputer,input:int) =
  icc.input.addLast input

proc newIcc(data:seq[int],inputs:seq[int] = @[]):IntcodeComputer =
  result = IntcodeComputer(
    mem:data,
    input:initDeque[int](),
    output:initDeque[int](),
    state:skRunning,
    ip:0,
  )
  result.addInput inputs

proc readOutput(icc: IntcodeComputer):int =
  icc.output.peekLast

proc processOp(icc:var IntcodeComputer) =
  ## process the next op
  var
    code: string ## the current zero padded opcode
  template ip:untyped = icc.ip
  template mem:untyped = icc.mem
  template getval(i:int):untyped =
    if code[^(i+2)] == '1': mem[ip()+i] else: mem[mem[ip()+i]]
  if ip > mem.len: err &"Intruction pointer, {ip}, is past end of mem, {mem.len}!"
  code = &"{mem[ip]:04}"
  icc.state = skRunning
  case code[^2..^1]
  of opAdd:
    mem[mem[ip+3]] = getval(1) + getval(2)
    ip += 4
  of opMult:
    mem[mem[ip+3]] = getval(1) * getval(2)
    ip += 4
  of opInput:
    if icc.input.len > 0:
      mem[mem[ip+1]] = icc.input.popFirst
      ip += 2
    else:
      icc.state = skInput
  of opOutput:
    icc.output.addLast getval(1)
    ip += 2
    icc.state = skOutput
  of opTrueJump:
    if getval(1) != 0:
      ip = getval(2)
    else:
      ip += 3
  of opFalseJump:
    if getval(1) == 0:
      ip = getval(2)
    else:
      ip += 3
  of opLess:
    mem[mem[ip+3]] = if getval(1) < getval(2): 1 else: 0
    ip += 4
  of opEqual:
    mem[mem[ip+3]] = if getval(1) == getval(2): 1 else: 0
    ip += 4
  of opHalt:
    icc.state = skHalt
  else:
    err &"Unhandled opcode at position {ip}: {mem[ip]}"

proc run(icc: var IntcodeComputer, skipOutput=true):int=
  var running = true
  while running:
    icc.processOp()
    case icc.state
    of skHalt, skInput: running = false
    of skOutput: running = skipOutput
    else: discard
  return icc.readOutput

proc amps(data:seq[int],phases:seq[int]):int =
  var
    iccs:seq[IntcodeComputer] = @[]
    i = 0
    feedback = 0
  for p in phases:
    iccs.add newIcc(data,@[p])
  iccs[0].addInput feedback # the first one gets 0 feedback to start
  while iccs.anyIt(it.state != skHalt):
    feedback = iccs[i].run
    i = (i + 1) mod phases.len
    iccs[i].addInput feedback
  return feedback

proc ampsPermute(data:seq[int],phases:seq[int]):int =
  var
    outs:seq[int] = @[]
  for p in permutations(phases):
    outs.add data.amps(p)
  return outs.foldl(max(a,b))


assert 43210 == @[3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0].amps(@[4,3,2,1,0])
assert 54321 == @[3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0].amps(@[0,1,2,3,4])
assert 65210 == @[3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0].amps(@[1,0,4,3,2])

assert 43210 == @[3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0].ampsPermute(toSeq(0..4))
assert 54321 == @[3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0].ampsPermute(toSeq(0..4))
assert 65210 == @[3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0].ampsPermute(toSeq(0..4))

proc part1*():int =
  result = readtext().ampsPermute(toSeq(0..4))
  assert 18812 == result

###

assert 139629729 == @[3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5].amps(@[9,8,7,6,5])
assert 18216 == @[3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,-5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10].amps(@[9,7,8,5,6])

assert 139629729 == @[3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5].ampsPermute(toSeq(5..9))
assert 18216 == @[3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,-5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10].ampsPermute(toSeq(5..9))

proc part2*():int =
  result = readtext().ampsPermute(toSeq(5..9))
  assert 25534964 == result

when isMainModule:
  echo "Day07"
  echo &"Part1 {part1()}" # 18812 √
  echo &"Part2 {part2()}" # 25534964 √

# Compile command: 'nim c --hint[Conf]=off  -d:danger -d:release --opt:speed -o:out/time_day07 nim/day07.nim'
# Run command: 'time ./out/time_day07'
# Day07
# Part1 18812
# Part2 25534964

# real    0m0.030s
# user    0m0.018s
# sys     0m0.002s