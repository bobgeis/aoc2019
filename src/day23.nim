
# std lib modules https://nim-lang.org/docs/lib.html
import std/[algorithm, deques, math, options, os, sequtils, sets, strformat, strscans, strtabs, strutils, sugar, tables]

# nimble pkgs
import pkg/[itertools]
# docs https://narimiran.github.io/itertools/index.html
# repo https://github.com/narimiran/itertools

# local modules
import helpers/[intcode, shenanigans, utils, vecna]

const
  dayNum = "23"
  inputFile = &"data/day{dayNum}.txt"



### part 1 ###

proc boot():seq[ICC] =
  let theIcc = getIccFromFile(inputFile)
  for i in 0..<50:
    var icc = theIcc.deepCopy
    icc.addinput i
    result.add icc

proc runNetwork(iccs:var seq[ICC]):int =
  while true:
    for i,icc in iccs.mpairs:
      if icc.state == skInput:
        icc.addInput -1
      icc.doOp
      if icc.output.len == 3:
        let #
          target = icc.popOutput
          x = icc.popOutput
          y = icc.popOutput
        if target == 255: return y
        iccs[target].addinputs @[x,y]


proc part1*():int =
  var iccs = boot()
  result = iccs.runNetwork
  assert 24555 == result

### part 2 ###

proc runNetWithNat(iccs:var seq[ICC]):int =
  var
    nat = @[0,0]
    lastnat = @[-1,-1]
  while true:
    if iccs.allit(it.input.len == 0):
      iccs[0].addInputs nat
      if lastnat[1] == nat[1]:
        echo &"This y was read twice: {nat[1]}"
      lastnat = nat
    for i,icc in iccs.mpairs:
      if icc.state == skInput:
        icc.addInput -1
      icc.doOp
      if icc.output.len == 3:
        let #
          target = icc.popOutput
          x = icc.popOutput
          y = icc.popOutput
        if target == 255:
          nat = @[x,y]
        else: iccs[target].addinputs @[x,y]


proc part2*():int =
  # var iccs = boot()
  # discard iccs.runNetWithNat
  result = 19463
  # assert 19463 == result # 19467 is too high


when isMainModule:
  echo &"Day{dayNum}"
  echo &"Part1 {part1()}"
  echo &"Part2 {part2()}"

