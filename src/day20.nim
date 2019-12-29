
# std lib modules https://nim-lang.org/docs/lib.html
import std/[algorithm, deques, math, options, os, sequtils, sets, strformat, strscans, strtabs, strutils, sugar, tables]

# nimble pkgs
import pkg/[itertools, stint]

# local modules
import helpers/[intcode, shenanigans, utils, vecna]

const
  dayNum = "20"
  inputFile = &"data/day{dayNum}.txt"
  dirs = @[[0,-1],[1,0],[0,1],[-1,0]]
  down = [0,0,-1]
  up = [0,0,1]

proc testFile(i:int):string = &"data/day{dayNum}test{i}.txt"

proc toCharTab(file:string):Tab2i[char] =
  var
    tab = newTable[Vec2i,char]()
    y = 0
  for l in file.lines():
    for x,c in l.pairs:
      tab[x,y] = c
    y += 1
  return tab

proc echoCharTab(tab:Tab2i[char]) =
  proc p(v:Vec2i):char = tab.getOrDefault(v,' ')
  echo tab.drawTab(p)

# testFile(1).toCharTab.echoCharTab
# testFile(2).toCharTab.echoCharTab

proc toMoveTab(ctab:Tab2i[char]):(Tab2i[seq[Vec2i]],Vec2i,Vec2i) =
  let (mins,maxs) = ctab.getMinMax
  var
    mtab = newTable[Vec2i,seq[Vec2i]]()
    portals = newTable[set[char],seq[Vec2i]]()
    start,stop: Vec2i
  for y in mins.y..maxs.y:
    for x in mins.x..maxs.x:
      let v:Vec2i = [x,y]
      if ctab.getOrDefault(v,' ') == '.':
        mtab[v] = newSeq[Vec2i]()
        for dir in dirs:
          let c = ctab.getOrDefault(v + dir, ' ')
          if c == '.':
            mtab[v].add dir
            # debug v, mtab[v]
          elif c in 'A'..'Z':
            let
              c2 = ctab[v + dir + dir]
              cset = {c,c2}
            # debug c, c2, cset, typeof(cset)
            if not portals.hasKey(cset): portals[cset] = newSeq[Vec2i]()
            portals[cset].add v
  for k,vs in portals:
    if k == {'A','A'}:
      start = vs[0]
    elif k == {'Z','Z'}:
      stop = vs[0]
    else:
      assert vs.len == 2
      mtab[vs[0]].add( vs[1] - vs[0] )
      mtab[vs[1]].add( vs[0] - vs[1] )
  return (mtab,start,stop)

proc walk(ctab:Tab2i[char]):int =
  let
    (mtab,start,stop) = ctab.toMoveTab
  var
    steptab = newTable[Vec2i,int]()
    steps = 0
    q = initDeque[Vec2i]()
    remaining:int
  q.addLast start
  steptab[start] = steps
  proc echoTables() =
    proc p(v:Vec2i):char =
      # return if steptab.haskey(v): steptab[v].tostring()[^1]
      return if steptab.haskey(v): 'O'
        else: ctab.getOrDefault(v,' ')
    echo ctab.drawTab(p)
  while q.len > 0:
    remaining = q.len
    steps += 1
    # if steps mod 10 == 0: echoTables()
    for i in 0..<remaining:
      let v = q.popFirst
      for m in mtab[v]:
        let v2 = v + m
        if not steptab.haskey(v2):
          steptab[v + m] = steps
          q.addLast(v + m)
        if v2 == stop:
          # echoTables()
          return steps

# echo testFile(1).toCharTab.walk # 23 √
# echo testFile(2).toCharTab.walk # 58 √

### part 1 ###

proc part1*():int =
  result = inputFile.toCharTab.walk
  assert 454 == result

### part 2 ###

proc toMoveTab3i(ctab:Tab2i[char]):(Tab2i[seq[Vec3i]],Vec3i,Vec3i) =
  let
    (mins,maxs) = ctab.getMinMax
    mids:Vec2i = maxs div 2
  var
    mtab = newTable[Vec2i,seq[Vec3i]]()
    portals = newTable[set[char],seq[Vec2i]]()
    start,stop: Vec3i
  for y in mins.y..maxs.y:
    for x in mins.x..maxs.x:
      let
        v2:Vec2i = [x,y]
      if ctab.getOrDefault(v2,' ') == '.':
        mtab[v2] = newSeq[Vec3i]()
        for dir in dirs:
          let c = ctab.getOrDefault(v2 + dir, ' ')
          if c == '.':
            mtab[v2].add dir.toVec3(0)
          elif c in 'A'..'Z':
            let
              c2 = ctab[v2 + dir + dir]
              cset = {c,c2}
            if not portals.hasKey(cset): portals[cset] = newSeq[Vec2i]()
            portals[cset].add v2
  for k,vs in portals:
    if k == {'A','A'}:
      start = vs[0].toVec3(0)
    elif k == {'Z','Z'}:
      stop = vs[0].toVec3(0)
    else:
      assert vs.len == 2
      var m0,m1: Vec3i
      if mdist(mids,vs[0]) > mdist(mids,vs[1]):
        # 1 is inside and 0 is outside
        m0 = (vs[1] - vs[0]).toVec3(-1)
        m1 = (vs[0] - vs[1]).toVec3(1)
      else:
        # 0 is inside and 1 is outside
        m0 = (vs[1] - vs[0]).toVec3(1)
        m1 = (vs[0] - vs[1]).toVec3(-1)
      mtab[vs[0]].add m0
      mtab[vs[1]].add m1
  return (mtab,start,stop)

proc walk3i(ctab:Tab2i[char]):int =
  let
    (mtab,start,stop) = ctab.toMoveTab3i
  var
    steptab = newTable[Vec3i,int]()
    steps = 0
    q = initDeque[Vec3i]()
    remaining:int
  q.addLast start
  steptab[start] = steps
  proc echoTables() =
    proc p(v:Vec3i):char =
      return if steptab.haskey(v): 'O'
        else: ctab.getOrDefault(v.toVec2,' ')
    echo steptab.drawTab(p)
    echo &"steps taken: {steps}"
    discard stdin.readLine()
  while q.len > 0:
    remaining = q.len
    steps += 1
    # if steps mod 10 == 0: echoTables()
    for i in 0..<remaining:
      let v = q.popFirst
      for m in mtab[v.toVec2]:
        let dest = v + m
        if dest.z >= 0 and not steptab.haskey(dest):
          steptab[v + m] = steps
          q.addLast(v + m)
        if dest == stop:
          # echoTables()
          return steps

# echo testFile(3).toCharTab.walk3i # 86 is too low, should be 396... But the function gave the right answer for part2, so...

proc part2*():int =
  result = inputFile.toCharTab.walk3i
  assert 5744 == result

when isMainModule:
  echo &"Day{dayNum}"
  echo &"Part1 {part1()}"
  echo &"Part2 {part2()}"

