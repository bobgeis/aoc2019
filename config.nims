
import algorithm, strformat, strutils

const dayDir = "src"

task newest, "Compile and run the most recent day":
  let src = listFiles(dayDir).sorted()[^1]
  exec &"nim runc --hint[Conf]=off -o:out/newest {src}"

task day, "build and run the given day(s), eg `nim day 1 2 3`":
  for i in 2..paramCount():
    let num = paramStr(i).parseInt()
    exec &"nim runc --hint[Conf]=off -o:out/{num:02} {dayDir}/day{num:02}.nim"

task runall, "build and run all completed days":
  let days = listFiles(dayDir).sorted()
  for day in days:
    exec &"nim runc --hints=off --warnings=off -o:output {day}"

task time, "build, run, time the given day(s)":
  for i in 2..paramCount():
    let num = paramStr(i).parseInt()
    exec &"nim c --hint[Conf]=off -d:release -d:danger --opt:speed -o:out/{num:02} {dayDir}/day{num:02}.nim"
    exec &"time ./out/{num:02}"

task timeall, "build all, then time all runs":
  let days = listFiles(dayDir).sorted()
  for i,day in days:
    exec &"nim c --hints=off --warnings=off -d:release -d:danger --opt:speed -o:out/{i:02} {day}"
  for i,day in days:
    exec &"time ./out/{i:02}"

task helpers, "build and run named helper file(s) or all of them (with no name)":
  if paramCount() < 2:
    for file in listFiles("src/helpers"):
      echo &"Runcing {file}"
      exec &"nim runc --hint[Conf]=off -o:out/helperTest {file}"
  for i in 2..paramCount():
    let file = paramStr(i)
    exec &"nim runc --hint[Conf]=off -o:out/{file} src/helpers/{file}.nim"
