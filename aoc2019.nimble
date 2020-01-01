# Package

version       = "0.1.0"
author        = "Bob Geis"
description   = "Advent of Code 2019"
license       = "MIT"
srcDir        = "src"

# Dependencies # this file mainly exists to pin versions

requires "nim >= 1.0.4"

# itertools
# has useful iterators
# nimble https://nimble.directory/pkg/itertools
# src https://github.com/narimiran/itertools
# doc https://narimiran.github.io/itertools/
requires "itertools >= 0.3.0"

# memo
# great for memoizing procs
# nimble https://nimble.directory/pkg/memo
# src https://github.com/andreaferretti/memo
# doc https://nimble.directory/docs/memo
requires "memo >= 0.3.0"

# stint
# necessary for dealing with large integers, eg Int128 and bigger
# nimble https://nimble.directory/pkg/stint
# src https://github.com/status-im/nim-stint
requires "stint >= 0.0.1"