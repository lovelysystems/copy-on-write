#!/bin/bash

source "./testing.sh"

# run before container has been started
beforeStartSHA() {
  cd "$baseDir/volumes/src"
  mkdir "sha_in"
  echo "version 1" > "sha_in/file1.txt"
  echo "version 1" > "sha_in/archive.tar.gz"

  # setup a file that already has been mapped and copied
  echo "version 1" > "sha_in/existing.txt"
  cd "$baseDir/volumes/target"
  mkdir -p sha_out
  targetFile="sha_out/existing-91918bf2fbfc2745097832e8020d41941b9e546b.txt"
  cp ../src/sha_in/existing.txt $targetFile
  # remember the modification time
  shaMTimeBeforeStart=$(mTime $targetFile)
}

# run after container has been started
afterStartSHA() {
  cd "$baseDir/volumes/target"
  # the sha1 sum has been added to the filename before the extension
  fileShouldExist "sha_out/file1-91918bf2fbfc2745097832e8020d41941b9e546b.txt"
  fileShouldExist "sha_out/archive.tar-91918bf2fbfc2745097832e8020d41941b9e546b.gz"

  # on startup, the already copied file did not get replaced
  shaMTimeAfterStart=$(mTime "sha_out/existing-91918bf2fbfc2745097832e8020d41941b9e546b.txt")
  if [ "$shaMTimeBeforeStart" != "$shaMTimeAfterStart" ]; then
    echo "sha_out/existing... should have mTime $shaMTimeBeforeStart but had $shaMTimeAfterStart"
    success="false"
  fi


}
