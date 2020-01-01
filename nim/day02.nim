
# std lib modules https://nim-lang.org/docs/lib.html
import std/[parsecsv, sequtils, strformat, strutils]

# local modules
import lib/[aocutils, bedrock]

const
  dayNum = "02"
  inputFile = inputFilePath(dayNum)

proc process(data:var seq[int])=
  var
    c = 0
  while c < data.len:
    case data[c]
    of 1:
      data[data[c+3]] = data[data[c+1]] + data[data[c+2]]
      c += 4
    of 2:
      data[data[c+3]] = data[data[c+1]] * data[data[c+2]]
      c += 4
    of 99:
      return
    else:
      echo &"BUG: Unhandled oppcode at position {c}: {data[c]}"
      return
  echo "BUG: fell off of end of seq without getting a 99."
  return

# 1,0,0,0,99 becomes 2,0,0,0,99 (1 + 1 = 2).
# 2,3,0,3,99 becomes 2,3,0,6,99 (3 * 2 = 6).
# 2,4,4,5,99,0 becomes 2,4,4,5,99,9801 (99 * 99 = 9801).
# 1,1,1,4,99,5,6,0,99 becomes 30,1,1,4,2,5,6,0,99.

var
  s1 = @[1,0,0,0,99]
  s2 = @[2,3,0,3,99]
  s3 = @[2,4,4,5,99,0]
  s4 = @[1,1,1,4,99,5,6,0,99]
s1.process
s2.process
s3.process
s4.process
assert s1 == @[2,0,0,0,99]
assert s2 == @[2,3,0,6,99]
assert s3 == @[2,4,4,5,99,9801]
assert s4 == @[30,1,1,4,2,5,6,0,99]

# Once you have a working computer, the first step is to restore the gravity assist program (your puzzle input) to the "1202 program alarm" state it had just before the last computer caught fire. To do this, before running the program, replace position 1 with the value 12 and replace position 2 with the value 2. What value is left at position 0 after the program halts?

proc getData():seq[int] =
  ## using stripLineEnd
  var file = readFile(inputFile)
  file.stripLineEnd()
  file.split(',').map(parseInt)


proc getDataCSV():seq[int] =
  ## variation that uses parsecsv
  var p: CsvParser
  p.open(inputFile)
  doAssert p.readRow
  for n in p.row.items:
    try:
      result.add n.parseInt
    except:
      echo n
  p.close()


proc part1*():int =
  var data = getData()
  data[1] = 12
  data[2] = 2
  data.process
  result = data[0]
  assert 3760627 == result

# The inputs should still be provided to the program by replacing the values at addresses 1 and 2, just like before. In this program, the value placed in address 1 is called the noun, and the value placed in address 2 is called the verb. Each of the two input values will be between 0 and 99, inclusive.

# Once the program has halted, its output is available at address 0, also just like before. Each time you try a pair of inputs, make sure you first reset the computer's memory to the values in the program (your puzzle input) - in other words, don't reuse memory from a previous attempt.

# Find the input noun and verb that cause the program to produce the output 19690720. What is 100 * noun + verb? (For example, if noun=12 and verb=2, the answer would be 1202.)

proc part2*():int =
  let data = getData()
  const
    stopValue = 19690720
  for noun in 0..99:
    for verb in 0..99:
      var scrap = data.deepCopy()
      scrap[1] = noun
      scrap[2] = verb
      scrap.process
      if scrap[0] == stopValue:
        # echo &"Part2 {100 * noun + verb}"
        result = 100 * noun + verb
        assert 7195 == result
        return
  echo "BUG: finished with no correct result"

when isMainModule:
  echo "Day02"
  echo &"Part1 {part1()}" # 3760627 √
  echo &"Part2 {part2()}" # 7195 √

# Compile command: 'nim c --hint[Conf]=off  -d:danger -d:release --opt:speed -o:out/time_day02 nim/day02.nim'
# Run command: 'time ./out/time_day02'
# Day02
# Part1 3760627
# Part2 7195

# real    0m0.027s
# user    0m0.013s
# sys     0m0.007s