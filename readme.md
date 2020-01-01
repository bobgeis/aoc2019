
# Advent-of-Code 2019

[Advent of Code](https://adventofcode.com/2019)

[My solutions](https://github.com/bobgeis/aoc2019)

## Setup

### Nim

At first I was using scripts in the nimble file to run code, but nimble kept complaining about my unusual directory setup, so I moved all the scripts into config.nims.  I kept the nimble file to mark the versions of the nim compiler and nimble packages that were used.

I put code shared between days in nim/lib.  `aocutils.nim` has some utilities for dealing with this particular repo (like where to find data files).  `bedrock` is a miscellaneous utilities file that has no other in-repo dependencies.  `graphwalk` has very generic implementation of BFS and Dijkstra's algorithm.  Instead of having special "graph" data structures, they take procs that are called to get adjacencies. `intcode` is the intcode computer used by many challenges in 2019.  `shenanigans` is for experimentation, mostly with macros and/or building from other people's code.  `vecna` is yet another simple vector library. Vecna uses fixed length arrays as the underlying implementation, but was made with my ergonomics in mind, rather than performance.

I did my coding using vscode with [nim](https://marketplace.visualstudio.com/items?itemName=kosz78.nim) and [indent-rainbow](https://marketplace.visualstudio.com/items?itemName=oderwat.indent-rainbow) extensions.



## SPOILERS












## Day 1

Straightforward arithmetic.  I spent most of my time trying to get my setup working the way I liked.

## Day 2

Fun and not hard.  There's probably a better way to code operations than what I did.


## Day 3

This one was much harder than day 1 and 2, and seemed to be a bit of a filter.  I did it in a wasteful way: I turn everything into line segments, and then for part 2 I *recalculate* the distances.

## Day 4

This was much easier than day 3.  I did it in an obvious but obviously slow way: I checked every number in the entire range.  It would probably be faster to construct monotonically increasing numbers and then do some more work to check repeats.

## Day 5

I copied over the code from day 2.  I know other people extracted it, but I didn't want to risk breaking day 2 if the design called for breaking changes.  If it appears again, and breaking changes continue to be unlikely, then I will probably put it into it's own module.

## Day 6

I did this as a graph traversal problem, but it's possible to do it without.  For instance, you could just assemble the paths to the center and then compare them (because *all* paths go to the center) to find where they join.

## Day 7

Part 1 was fairly straightforward and fun.  Part 2 actually required me to re-write a lot of the intcode computer!

## Day 8

By far the hardest part of this was realizing that the output was *supposed to be an image*. -_-

## Day 9

We finally finished our "intcode computers"!  I should really factor it out at this point.


## Day 10

Asteroids! My first attempt was to walk from each asteroid to each other and see if it bumps into something, but that was a little tricky.  It occurred to me that I could use the slope of the line between two asteroids to sort them, but then you'd have to deal with asteroids on either side having the same slope.  Then I realized that nim's math has arctan2 that lets you distinguish these.  I wrote a `binBy` proc helper function that turns a seq into a table using a binning/bucketing function.

## Day 11

Finally put intcode into it's own file.  This one required reading from an "image" again.  I wonder if I should put that in a helper too.

## Day 12

Part 1 was fun.  Part 2 required some that, but I was pleased with the approach to the solution.  Looking at other people's answers in nim, makes me want to try to use more features of the language, like strscans.

## Day 13

Breakout!  I had a bug where I wasn't clearing inputs and this was making it unplayable.  I worked around that by hacking the intcode program to have a paddle the width of the play area -_-

## Day 14

I learned that large numbers will fit in an `int` but if you may need to cast it to an `int` otherwise it will be parsed as an `int64`.

## Day 15

I had an off-by-two error in my solution to part 2.  Part of it was due to starting at 1 minute (the first space is already full of oxygen at minute 0), and part of it was that I was counting frontiers, even if the frontiers had no open spaces in them.  The last part means I was counting an extra minute while I evaluated the walls of the last open space.  Having a lib with a BFS impl, instead of making a new one ad hoc, would have helped here.


