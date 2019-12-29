
# std lib modules https://nim-lang.org/docs/lib.html
import algorithm, deques, math, options, os, sequtils, sets, strformat, strscans, strtabs, strutils, sugar, tables

# nimble pkgs
import itertools
# docs https://narimiran.github.io/itertools/index.html
# repo https://github.com/narimiran/itertools

# local modules
import helpers/[intcode, shenanigans, utils, vecna]

const
  dayNum = "18"
  inputFile = &"data/day{dayNum}.txt"
  north = [0,-1]
  south = [0,1]
  west = [-1,0]
  east = [1,0]
  inputTest1 = &"data/day{dayNum}test1.txt" # 8 steps
  inputTest2 = &"data/day{dayNum}test2.txt" # 86 steps
  inputTest3 = &"data/day{dayNum}test3.txt" # 132 steps
  inputTest4 = &"data/day{dayNum}test4.txt" # 136 steps
  inputTest5 = &"data/day{dayNum}test5.txt" # 81 steps

proc testFile(i:int):string = &"data/day{dayNum}test{i}.txt"

type
  Maze = seq[string]

let
  inputMazeString = inputFile.readFile.strip
  inputMaze = inputMazeString.split('\n')


proc drawMaze(maze:seq[string]) =
  for row in maze:
    echo row

proc findStart(maze:seq[string]):Vec2i =
  for y,row in maze.pairs:
    for x,c in row:
      if c == '@':
        return [x,y]


proc get(maze:seq[string],pos:Vec2i):char = maze[pos.y][pos.x]

proc getadjacent(pos:Vec2i):seq[Vec2i] =
  result.add (pos + north)
  result.add (pos + south)
  result.add (pos + west)
  result.add (pos + east)

### part 1 ###

inputMaze.drawMaze
echo inputMaze.findStart
# [40,40] # looks right: exactly in the middle

# . is open space, # is wall, @ is entrance
# a is a key to the door A
# shortest path to get all the keys?

# note that for part1 we don't actually care about the path itself, just its length.
# we can do flood fill to find all the keys

# day 15 does flood fill
# So lets make a table of vec -> 0,1 for impassable/passable

proc part1*():int =
  result = 1
  # assert xxx == result

### part 2 ###



proc part2*():int =
  result = 2
  # assert xxx == result


when isMainModule:
  echo &"Day{dayNum}"
  echo &"Part1 {part1()}"
  echo &"Part2 {part2()}"

