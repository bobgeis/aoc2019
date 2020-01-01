
## This files useful for this advent of code repo.  The classic example is getting the input file.

import std/[strformat]

const
  inputDir = "data"

proc inputFilePath*(day:string):string =
  &"{inputDir}/day{day}.txt"

proc inputTestFilePath*(day:string,test:int):string =
  &"{inputDir}/day{day}test{test}.txt"