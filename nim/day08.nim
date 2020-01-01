
# std lib modules https://nim-lang.org/docs/lib.html
import std/[sequtils, strformat, strutils]

# local lib modules
import lib/[aocutils, bedrock]

const
  dayNum = "08"
  inputFile = inputFilePath(dayNum)

proc readtext():seq[int] =
  return toSeq(inputFile.lines)[0].mapIt(parseInt($it))

### part 1 ###

proc toLayers(data:seq[int], w=25,h=6):seq[seq[int]] =
  let distnum = data.len div (w*h)
  return data.distribute(distnum)

proc fewestZeroes(layers:seq[seq[int]]):seq[int] =
  var
    fewest = 0
  for i,layer in layers:
    if layers[fewest].count(0) > layer.count(0):
      fewest = i
  return layers[fewest]

proc answer(layer:seq[int]):int =
  layer.count(1) * layer.count(2)

proc part1*():int =
  result = readtext().toLayers.fewestZeroes.answer
  assert 1820 == result

### part 2 ###

proc combine(layers:seq[seq[int]]):seq[int] =
  let trans = layers.transpose
  for px in trans:
    result.add px.foldl(if a == 2: b else: a)

proc toString(s:seq[int]):string =
  result = ""
  for i in s:
    result.add $i

proc toImage(s:string,w=25):string =
  ## "image"
  result = ""
  for i,c in s:
    if i mod w == 0 :
      result.add "\n"
    if c == '0':
      result.add " "
    else:
      result.add "#"

assert "0110" == "0222112222120000".mapIt(parseInt($it)).toLayers(2,2).combine.toString
assert "0010" == "0222102222120000".mapIt(parseInt($it)).toLayers(2,2).combine.toString
assert "0011" == "0221102222120000".mapIt(parseInt($it)).toLayers(2,2).combine.toString
assert "1110" == "2222112222120000".mapIt(parseInt($it)).toLayers(2,2).combine.toString

proc part2*():string =
  result = readtext().toLayers().combine.toString
  assert "111101001010010011000011000010100101010010010000100010010010110001000000010010001001010100100000001010000100101010010010100101111001100100100110001100" == result
  # looks like ZUKCJ

when isMainModule:
  echo "Day08"
  echo &"Part1 {part1()}" # √
  echo &"Part2 {part2().toImage()}" # √

# Compile command: 'nim c --hint[Conf]=off  -d:danger -d:release --opt:speed -o:out/time_day08 nim/day08.nim'
# Run command: 'time ./out/time_day08'
# Day08
# Part1 1820
# Part2
# #### #  # #  #  ##    ##
#    # #  # # #  #  #    #
#   #  #  # ##   #       #
#  #   #  # # #  #       #
# #    #  # # #  #  # #  #
# ####  ##  #  #  ##   ##

# real    0m0.007s
# user    0m0.003s
# sys     0m0.002s