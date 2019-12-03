
version = "0.1.0"
author = "Bob Geis"
description = "Advent of Code 2019"
license = "MIT"


# tasks

import algorithm
import strformat

task newest, "Compile and run the most recent day":
  echo "Running newest day."
  let src = listFiles("./src").sorted()[^1]
  exec &"nim runc -o:output {src}"
