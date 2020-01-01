
# std lib modules https://nim-lang.org/docs/lib.html
import std/[deques, math, sequtils, strformat, strtabs, strutils, tables]

# local lib modules
import lib/[aocutils, bedrock]

const
  dayNum = "09"
  inputFile = inputFilePath(dayNum)

proc readtext():seq[int64] =
  toSeq(inputFile.lines)[0].split(',').mapIt(parseBiggestInt(it).int64)

const
  opAdd = "01"
  opMult = "02"
  opInput = "03"
  opOutput = "04"
  opTrueJump = "05"
  opFalseJump = "06"
  opLess = "07"
  opEqual = "08"
  opAdjRelativeBase = "09"
  opHalt = "99"

type
  StateKind = enum
    skRunning, skHalt, skInput, skOutput,
  IntcodeComputer = ref object
    mem: seq[int64] ## the current memory
    input: Deque[int64] ## deque of *unprocessed* inputs
    output: Deque[int64] ## deque of outputs
    state:StateKind ## current state
    ip:int64 ## instruction point
    rb:int64 ## relative base

proc addInput(icc:var IntcodeComputer,inputs:seq[int64]) =
  for i in inputs:
    icc.input.addLast i

proc addInput(icc:var IntcodeComputer,input:int64) =
  icc.input.addLast input

proc `[]`(icc:IntcodeComputer,i:int64):int64 =
  let ii = i.int
  if icc.mem.len - 1 <= ii:
    icc.mem.setlen(ii + 1)
  return icc.mem[ii]

proc `[]=`(icc:var IntcodeComputer,i:int64,val:int64) =
  let ii = i.int
  if icc.mem.len - 1 <= ii:
    icc.mem.setlen(ii + 1)
  icc.mem[ii] = val

proc newIcc(data:seq[int64],inputs:seq[int64] = @[]):IntcodeComputer =
  result = IntcodeComputer(
    mem:data,
    input:initDeque[int64](),
    output:initDeque[int64](),
    state:skRunning,
    ip:0,
    rb:0,
  )
  result.addInput inputs

proc readOutput(icc: IntcodeComputer):int64 =
  icc.output.peekLast

proc readAllOutputs(icc: IntcodeComputer):seq[int64] =
  toSeq(icc.output.items)

proc doOp(icc:var IntcodeComputer) =
  ## process the next op
  var
    code: string ## the current zero padded opcode
  template ip:untyped = icc.ip
  template getval(i:int64):untyped =
    if code[^(i+2)] == '1': icc[ip()+i]
    elif code[^(i+2)] == '2': icc[icc[ip()+i] + icc.rb]
    else: icc[icc[ip()+i]]
  template setval(i,val:int64):untyped =
    if code[^(i+2)] == '1': icc[ip()+i] = val
    elif code[^(i+2)] == '2': icc[icc[ip()+i] + icc.rb] = val
    else: icc[icc[ip()+i]] = val
  code = &"{icc[ip]:05}"
  icc.state = skRunning
  case code[^2..^1]
  of opAdd:
    setval(3,getval(1) + getval(2))
    ip += 4
  of opMult:
    setval(3,getval(1) * getval(2))
    ip += 4
  of opInput:
    if icc.input.len > 0:
      setVal(1,icc.input.popFirst)
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
    setval(3,if getval(1) < getval(2): 1 else: 0)
    ip += 4
  of opEqual:
    setval(3,if getval(1) == getval(2): 1 else: 0)
    ip += 4
  of opAdjRelativeBase:
    icc.rb += getval(1)
    ip += 2
  of opHalt:
    icc.state = skHalt
  else:
    err &"Unhandled opcode at position {ip}: {icc[ip]}"

proc run(icc: var IntcodeComputer, skipOutput=true):int64=
  var running = true
  while running:
    icc.doOp()
    case icc.state
    of skHalt, skInput: running = false
    of skOutput: running = skipOutput
    else: discard
  return icc.readOutput

proc amps(data:seq[int64],phases:seq[int64]):int64 =
  ## I copied this from day07 to catch regressions
  var
    iccs:seq[IntcodeComputer] = @[]
    i = 0
    feedback = 0'i64
  for p in phases:
    iccs.add newIcc(data,@[p])
  iccs[0].addInput feedback # the first one gets 0 feedback to start
  while iccs.anyIt(it.state != skHalt):
    feedback = iccs[i].run
    i = (i + 1) mod phases.len
    iccs[i].addInput feedback
  return feedback

assert 139629729'i64 == @[3'i64,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5].amps(@[9'i64,8,7,6,5])
assert 18216'i64 == @[3'i64,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,-5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10].amps(@[9'i64,7,8,5,6])

proc runreadall(data:seq[int64],inputs:seq[int64] = @[]):seq[int64] =
  var
    icc = newIcc(data,inputs)
    output = 0'i64
  while icc.state != skHalt and icc.state != skInput:
    output = icc.run(skipOutput=false)
  return icc.readAllOutputs

### part 1 ###

assert 1219070632396864'i64 == @[1102'i64,34915192,34915192,7,4,7,99,0].runreadall()[0]
assert 1125899906842624'i64 == @[104'i64,1125899906842624,99].runreadall()[0]
assert @[109'i64,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99] == @[109'i64,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99].runreadall()

proc part1*():int64 =
  result = readtext().runreadall(@[1'i64])[0]
  assert 3340912345 == result

### part 2 ###

proc part2*():int64 =
  result = readtext().runreadall(@[2'i64])[0]
  assert 51754 == result

when isMainModule:
  echo "Day09"
  echo &"Part1 {part1()}" # √
  echo &"Part2 {part2()}" # √

# Compile command: 'nim c --hint[Conf]=off  -d:danger -d:release --opt:speed -o:out/time_day09 nim/day09.nim'
# Run command: 'time ./out/time_day09'
# Day09
# Part1 3340912345
# Part2 51754

# real    0m0.205s
# user    0m0.183s
# sys     0m0.004s