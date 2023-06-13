#!/bin/bash

source "./testing.sh"

## run before container has been started
beforeStartSHA() {
  cd "$baseDir/volumes/src"
  mkdir "sha_in"
  echo "version 1" > "sha_in/file1.txt"
  echo "version 1" > "sha_in/archive.tar.gz"
}

# run after container has been started
afterStartSHA() {
  cd "$baseDir/volumes/target"
  # the sha1 sum has been added to the filename before the extension
  fileShouldExist "sha_out/file1-91918bf2fbfc2745097832e8020d41941b9e546b.txt"
  fileShouldExist "sha_out/archive.tar-91918bf2fbfc2745097832e8020d41941b9e546b.gz"
}
