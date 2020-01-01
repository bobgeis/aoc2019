

# std lib modules https://nim-lang.org/docs/lib.html
import std/[math, strformat]

# local lib modules
import lib/[aocutils, bedrock, intcode]

const
  dayNum = "19"
  inputFile = inputFilePath(dayNum)

### part 1 ###

let theIcc = getIccFromFile(inputFile)

proc scan(x,y:int):int  =
  var drone = theIcc.deepCopy()
  drone.addInputs @[x,y]
  discard drone.run
  # echo &"Scanned {x},{y} = {drone.readLastOutput}"
  return drone.readLastOutput

# echo scan(0,0) # 1
# echo scan(1,1) # 0 ? # my output is different from the example

proc drawGrid(s:seq[int],y:int):string =
  let grid = s.groupsOf(y)
  for j,row in grid.pairs:
    for i,num in row:
      let c = if num == 1: '#'
        elif i.bt(j, 3*j div 4): 'x'
        else: '.'
      result.add c
    result.add '\n'
# #.................................................
# xx................................................
# .xx...............................................
# ..xx..............................................
# ...xx.............................................
# ...x#x............................................
# ....x#x...........................................
# .....x#x..........................................
# ......x#x.........................................
# ......xx#x........................................
# .......x##x.......................................
# ........x#xx......................................
# .........x#xx.....................................
# .........xx#xx....................................
# ..........x##xx...................................
# ...........x##xx..................................
# ............x##xx.................................
# ............xx##xx................................
# .............xx##xx...............................
# ..............x###xx..............................
# ...............x###xx.............................
# ...............xx##xxx............................
# ................xx##xxx...........................
# .................x###xxx..........................
# ..................x###xxx.........................
# ..................xx###xxx........................
# ...................xx###xxx.......................
# ....................xx###xxx......................
# .....................x####xxx.....................
# .....................xx####xxx....................
# ......................xx####xxx...................
# .......................xx####xxx..................
# ........................xx###xxxx.................
# ........................xx####xxxx................
# .........................xx####xxxx...............
# ..........................xx####xxxx..............
# ...........................xx####xxxx.............
# ...........................xx#####xxxx............
# ............................xx#####xxxx...........
# .............................xx#####xxxx..........
# ..............................xx#####xxxx.........
# ..............................xxx#####xxxx........
# ...............................xx#####xxxxx.......
# ................................xx#####xxxxx......
# .................................xx#####xxxxx.....
# .................................xxx#####xxxxx....
# ..................................xx######xxxxx...
# ...................................xx######xxxxx..
# ....................................xx######xxxxx.
# ....................................xxx######xxxxx

proc scanGrid(xLen,yLen:int):seq[int] =
  for y in 0..<yLen:
    for x in 0..<xLen:
      result.add scan(x,y)

# echo scanGrid(50,50)
# echo scanGrid(50,50).drawGrid(50)

proc part1*():int =
  result = scanGrid(50,50).sum
  assert 150 == result

### part 2 ###

# Brute forcing will take forever.
# But we don't need to test everything, we know that large regions are empty.
# Also it *looks* like the region is bounded by straight lines.
# if we can find the center line, we can find the width and height from it.
# It looks like all the points lie between y = x and y = 3/4 x

proc scanY(y:int):(int,int,int,int) =
  ## returns: start and stop x offset, and the length of the run and the number of duds that were scanned before the run started (these are wasteful, but if it's 0 then it means you probably missed the start.)
  var
    start = int.high
    stop = 0
    hits = 0
    duds = 0
  for x in (3 * y div 4)..y:
    if scan(x,y) == 1:
      start = min(x,start)
      stop = x
      hits += 1
    elif hits > 0:
      return (start,stop,hits,duds)
    else:
      duds += 1

# echo scanY(10)
# echo scanY(100)
# echo scanY(1000)
# echo scanY(10000)
# (8, 9, 2, 1)
# (79, 90, 12, 4)
# (783, 903, 121, 33)
# (7825, 9036, 1212, 325)

# so we probably want to look in the thousands

# echo scanY(2000)
# echo scanY(3000)
# echo scanY(4000)
# echo scanY(5000)
# (1565, 1807, 243, 65)
# (2348, 2710, 363, 98)
# (3130, 3614, 485, 130)
# (3913, 4518, 606, 163)

# ................#################.......
# .................########OOOOOOOOOO.....
# ..................#######OOOOOOOOOO#....
# ...................######OOOOOOOOOO###..
# ....................#####OOOOOOOOOO#####
# .....................####OOOOOOOOOO#####
# .....................####OOOOOOOOOO#####
# ......................###OOOOOOOOOO#####
# .......................##OOOOOOOOOO#####
# ........................#OOOOOOOOOO#####
# .........................OOOOOOOOOO#####
# ..........................##############

# If (x,y) is the lower left corner of the square,
# then (x + 99, y - 99) is the top right corner

proc getWidth(y:int):int =
  ## Get width of rectangle with height 99 with lower left corner on row y.
  let
    (startX,_,_,_) = scanY(y)
    (_,stopX,_,_) = scanY(y - 99)
  return stopX - startX


# echo getWidth(1000) # 31
# echo getWidth(1500) # 92
# echo getWidth(2000) # 152
# echo getWidth(2500) # 212
# echo getWidth(1400) # 79
# echo getWidth(1550) # 98
# echo getWidth(1600) # 104
# echo getWidth(1700) # 115

# for y in 1550..1600:
#   discard getWidth y

# echo getWidth(1557) # 98
# echo getWidth(1558) # 98
# echo getWidth(1559) # 99

proc part2*():int =
  result = 1220 * 10_000 + 1460
  assert 12201460 == result


when isMainModule:
  echo &"Day{dayNum}"
  echo &"Part1 {part1()}"
  echo &"Part2 {part2()}"

# Compile command: 'nim c --hints=off --warnings=off  -d:danger -d:release --opt:speed -o:out/time_day19 nim/day19.nim'
# Run command: 'time ./out/time_day19'
# Day19
# Part1 150
# Part2 12201460

# real    0m0.396s
# user    0m0.382s
# sys     0m0.005s