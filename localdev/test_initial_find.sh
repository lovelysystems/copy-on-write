#!/bin/bash

source "./testing.sh"

# run before container has been started
beforeStartInitialFind() {
  cd "$baseDir/volumes/src"

  # write two files to a folder mapped
  mkdir "initial_in"
  # included by INITIAL_FIND_PARAMS
  touch "initial_in/includeme.txt"
  # not included
  touch "initial_in/foo.txt"
}

# run after container has been started
afterStartInitialFind() {
  target="$baseDir/volumes/target"
  src="$baseDir/volumes/src"

  # only files matching INITIAL_FIND_PARAMS
  # have been copied initially
  cd $target
  fileShouldExist "initial_out/includeme.txt"
  fileShouldNotExist "initial_out/foo.txt"
}
