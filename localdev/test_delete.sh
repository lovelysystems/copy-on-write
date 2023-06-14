#!/bin/bash

source "./testing.sh"

# run before container has been started
beforeStartDelete() {
  cd "$baseDir/volumes/src"

  # write a file to a folder mapped with DELETE_SOURCE_FILE true
  mkdir "delete_in"
  touch "delete_in/file1.txt"

  # write to a folder with DELETE_SOURCE_FILE=false
  mkdir -p my_dir
  touch "my_dir/nodelete.txt"
}

# run after container has been started
afterStartDelete() {
  target="$baseDir/volumes/target"
  src="$baseDir/volumes/src"

  # file has been copied
  cd $target
  fileShouldExist "delete_out/file1.txt"
  fileShouldExist "other_dir/nodelete.txt"

  cd $src
  # original file has been removed
  fileShouldNotExist "delete_in/file1.txt"
  # with DELETE_SOURCE_FILE=false file did not get deleted
  fileShouldExist "my_dir/nodelete.txt"


}
