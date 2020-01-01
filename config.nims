
import strformat, strutils
from os import splitFile

const
  nimSrcDir = "nim"
  nimLibDir = &"{nimSrcDir}/lib"
  nimOutDir = "out"

var
  fast = ""

proc parseArgs():seq[string] =
  if paramCount() < 2: return @[]
  for i in 2..paramCount():
    if paramStr(i) == "--fast" or paramStr(i) == "-f":
      fast = " -d:danger -d:release --opt:speed"
    else:
      result.add paramStr(i)

task day, "Build and run the and day(s), eg `nim day 1 2`, or give no days to run all.":
  let days = parseArgs()
  if days.len == 0:
    for dayNum in 0..25:
      let path = &"{nimSrcDir}/day{dayNum:02}.nim"
      if fileExists(path):
        selfExec &"runc --hints=off --warnings=off {fast} -o:{nimOutDir}/day{dayNum:02} {path}"
  for d in days:
    let
      dayNum = d.parseInt
      path = &"{nimSrcDir}/day{dayNum:02}.nim"
    if fileExists(path):
      selfExec &"runc --hint[Conf]=off {fast} -o:{nimOutDir}/day{dayNum:02} {path}"
    else:
      echo &"Could not find nim file for {path}."

task lib, "Build and run named nim lib file(s) or all of them (with no name)":
  let fnames = parseArgs()
  if fnames.len == 0:
    for file in listFiles(&"{nimLibDir}"):
      let (_,fname,ext) = file.splitFile
      if ext == ".nim":
        selfExec &"runc --hints=off --warnings=off {fast} -o:{nimOutDir}/{fname} {file}"
  for fname in fnames:
    let
      path = &"{nimLibDir}/{fname}.nim"
    if fileExists(path):
      selfExec &"runc --hint[Conf]=off {fast} -o:{nimOutDir}/lib_{fname} {path}"
    else:
      echo &"Could not find nim file for {path}"

task ex, "Build and run the named file(s) in the nim source dir":
  let fnames = parseArgs()
  if fnames.len == 0:
    echo "Please enter the name of a nim file in the nim source dir."
  for fname in fnames:
    let
      path = &"{nimSrcDir}/{fname}.nim"
    if path.fileExists:
      selfExec &"runc --hint[Conf]=off {fast} -o:{nimOutDir}/extra_{fname} {path}"
    else:
      echo &"Could not find nim file for {path}"

task time, "build, run, time the named file(s) in the nim source dir":
  let fnames = parseArgs()
  if fnames.len == 0:
    echo "Please enter the name of a nim file in the nim source dir."
  for fname in fnames:
    let
      path = &"{nimSrcDir}/{fname}.nim"
    if path.fileExists:
      selfExec &"c --hints=off --warnings=off {fast} -o:{nimOutDir}/time_{fname} {path}"
      echo &"Compile command: 'nim c --hints=off --warnings=off {fast} -o:{nimOutDir}/time_{fname} {path}'\nRun command: 'time ./{nimOutDir}/time_{fname}'"
      exec &"time ./{nimOutDir}/time_{fname}"
    else:
      echo &"Could not find nim file for {path}"

task clean, "delete the out directory":
  exec &"rm -rf {nimOutDir}"