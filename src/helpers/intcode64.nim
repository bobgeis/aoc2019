
import deques, sequtils, strformat, strutils

import utils

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
  StateKind* = enum
    skRunning, skHalt, skInput, skOutput,
  IntcodeComputer* = ref object
    mem*: seq[int64] ## the current memory
    input*: Deque[int64] ## deque of *unprocessed* inputs
    output*: Deque[int64] ## deque of outputs
    state*:StateKind ## current state
    ip*:int64 ## instruction point
    rb*:int64 ## relative base

proc addInput*(icc:var IntcodeComputer,inputs:seq[int64]) =
  for i in inputs:
    icc.input.addLast i

proc addInput*(icc:var IntcodeComputer,input:int64) =
  icc.input.addLast input

proc popOutput*(icc: IntcodeComputer):int64 =
  icc.output.popFirst

proc readLastOutput*(icc: IntcodeComputer):int64 =
  icc.output.peekLast

proc readAllOutputs*(icc: IntcodeComputer):seq[int64] =
  toSeq(icc.output.items)

proc clearOutput*(icc:var IntcodeComputer) =
  icc.output.clear

proc `[]`*(icc:IntcodeComputer,i:int64):int64 =
  let ii = i.int
  if icc.mem.len - 1 <= ii:
    icc.mem.setlen(ii + 1)
  return icc.mem[ii]

proc `[]=`*(icc:var IntcodeComputer,i:int64,val:int64) =
  let ii = i.int
  if icc.mem.len - 1 <= ii:
    icc.mem.setlen(ii + 1)
  icc.mem[ii] = val

proc newIcc*(data:seq[int64],inputs:seq[int64] = @[]):IntcodeComputer =
  result = IntcodeComputer(
    mem:data,
    input:initDeque[int64](),
    output:initDeque[int64](),
    state:skRunning,
    ip:0,
    rb:0,
  )
  result.addInput inputs

proc doOp*(icc:var IntcodeComputer) =
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

proc run*(icc: var IntcodeComputer, inputs: seq[int64] = @[], continueOnOutput = true):seq[int64] =
  ## takes a seq of inputs and runs until halt or new input required, returns a seq of all outputs so far
  var running = true
  icc.addInput(inputs)
  while running:
    icc.doOp()
    case icc.state
    of skHalt, skInput: running = false
    of skOutput: running = continueOnOutput # in case we're computing digits of pi
    else: discard
  return icc.readAllOutputs

proc getIccFromFile*(file:string):IntcodeComputer =
  toSeq(file.lines)[0].split(',').mapIt(parseBiggestInt(it).int64).newIcc(@[])


proc buildAndRun*(data:seq[int64],inputs:seq[int64] = @[]):seq[int64] =
  var icc = newIcc(data,inputs)
  return icc.run()


when isMainModule:

  assert 1219070632396864'i64 == @[1102'i64,34915192,34915192,7,4,7,99,0].buildAndRun[0]
  assert 1125899906842624'i64 == @[104'i64,1125899906842624,99].buildAndRun[0]
  assert @[109'i64,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99] == @[109'i64,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99].buildAndRun
  echo "All helpers/intcode64 asserts passed!"
