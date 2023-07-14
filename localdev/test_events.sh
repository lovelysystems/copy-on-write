#!/bin/bash

source "./testing.sh"

# run when container has been started up
afterStartEvents() {
  cd "$baseDir/volumes/src"
  mkdir "events_in"

  # a file that gets created
  echo "created" > "events_in/created.txt"

  # move file to source folder
  echo "moved" > "test-file.txt"
  mv test-file.txt "events_in/moved-from-outside.txt"

  # copy file to source folder
  echo "copied" > "copied-file.txt"
  cp copied-file.txt "events_in/"

  # simulate long-running upload
  # open a file for writing, wait before writing and closing
  exec 3<> "events_in/slow-write.txt"
      # Let's print some text to fd 3
      echo -n "Roses " >&3
      sleep 1
      echo -n "are red" >&3
  # Close fd 3
  exec 3>&-

  # move file in place -> should result in second file
  # sleep 1  # sleep to make sure initial created.txt has been processed
  # -> we already sleep via slow-write
  mv "events_in/created.txt" "events_in/moved-in-folder.txt"

}

# container has been granted some time to process files
afterSleepEvents() {
  cd "$baseDir/volumes/target"

  # created file has been copied
  fileShouldExistWithContent "events_out/created.txt" "created"

  # moved file has been copied again to the new filename
  fileShouldExistWithContent "events_out/moved-in-folder.txt" "created"

  # copied file has been processed
  fileShouldExist "events_out/copied-file.txt"

  # file moved to src from outside has been copied
  fileShouldExist "events_out/moved-from-outside.txt"

  # slow file has been processed after it's been fully written and closed
  fileShouldExistWithContent "events_out/slow-write.txt" "Roses are red"

  # cleanup
  rm "$baseDir/volumes/src/copied-file.txt"
}
