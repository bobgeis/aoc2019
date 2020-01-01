
# std lib modules https://nim-lang.org/docs/lib.html
import std/[math, strformat, strscans, strutils, tables]

# local lib modules
import lib/[aocutils, bedrock, intcode]

const
  dayNum = "14"
  inputFile = inputFilePath(dayNum)

proc testFile(i:int):string = inputTestFilePath(dayNum,i)

type
  Chemistry = TableRef[string,(int,seq[(int,string)])]

proc getChem(s:string):(int,string) =
  var
    amount: int
    name: string
  if not s.scanf("$s$i $w$s",amount,name):
    err &"Couldn't getChem from '{s}'"
  return (amount.int,name)

proc parseInput(inputs:string or TaintedString):Chemistry =
  var chemistry = newTable[string,(int,seq[(int,string)])]()
  for s in inputs.strip.splitlines:
    let s2 = s.split("=>")
    let prod = s2[1].getChem
    var reactants: seq[(int,string)]
    for r in s2[0].split(','):
      reactants.add r.getChem
    chemistry[prod[1]] = (prod[0],reactants)
  return chemistry

proc walkToOre(chemistry:Chemistry, goal:int = 1 ):int =
  var
    need = @[(goal,"FUEL")]
    extra = newTable[string,int]()
    ore = 0
  while need.len > 0:
    let (amtNeeded, product) = need.pop
    if product == "ORE": ore += amtNeeded
    else:
      let
        (amtProduced, reactants) = chemistry[product]
        amtExtra = extra.getOrDefault(product,0)
        times = ceil((amtNeeded - amtExtra)/amtProduced).int
      extra[product] = (times * amtProduced) - amtNeeded + amtExtra
      for (a,r) in reactants:
        # echo &"Need {a * times} of {r} to make {product} {times} times."
        need.add (a * times,r)
  return ore

### part 1 ###

let
  t1 = testFile(1)
  t2 = testFile(2)
  t3 = testFile(3)
  t4 = testFile(4)
  t5 = testFile(5)

assert 31 == t1.readFile.parseInput.walkToOre
assert 165 == t2.readFile.parseInput.walkToOre
assert 13312 == t3.readFile.parseInput.walkToOre
assert 180697 == t4.readFile.parseInput.walkToOre
assert 2210736 == t5.readFile.parseInput.walkToOre

proc part1*():int =
  result = inputFile.readFile.parseInput.walkToOre
  assert 261960 == result

### part 2 ###
# now we need to make as much fuel as possible given fixed ore, instead of find the min ore to find 1 fuel.  Remember that we were producing extras of various intermediates, this will mean it isn't as simple as just totalOre / minOrePerFuel.

# The 13312 ORE-per-FUEL example could produce 82892753 FUEL.
# The 180697 ORE-per-FUEL example could produce 5586022 FUEL.
# The 2210736 ORE-per-FUEL example could produce 460664 FUEL.

proc guessAndCheck(chemistry:Chemistry, ore = 1000000000000.int):int =
  var
    minOrePerFuel = chemistry.walkToOre()
    remaining = ore
    guess = floor(ore / minOrePerFuel).int
    nextGuess = guess + 1
    # count = 0
  while true:
    let oreUsed = chemistry.walkToOre(nextGuess)
    # count += 1
    if oreUsed > ore:
      # echo count # count == 9 for part2
      return guess
    else:
      guess = nextGuess
      remaining = ore - oreUsed
      nextGuess = guess + (remaining / minOrePerFuel).floor.int.max(1)

assert 82892753 == t3.readFile.parseInput.guessAndCheck
assert 5586022 == t4.readFile.parseInput.guessAndCheck
assert 460664 == t5.readFile.parseInput.guessAndCheck

proc part2*():int =
  result = inputFile.readFile.parseInput.guessAndCheck
  assert 4366186 == result # 4366186.0 is not right!

when isMainModule:
  echo "Day14"
  echo &"Part1 {part1()}"
  echo &"Part2 {part2()}"

# Compile command: 'nim c --hints=off --warnings=off  -d:danger -d:release --opt:speed -o:out/time_day14 nim/day14.nim'
# Run command: 'time ./out/time_day14'
# Day14
# Part1 261960
# Part2 4366186

# real    0m0.016s
# user    0m0.005s
# sys     0m0.003s