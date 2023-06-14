#!/bin/bash

source "./testing.sh"

chainSetup() {
    mkdir one
    touch one/foo.txt
}

chainTest() {
    # currently replacements are chained, only the final directory is created/mapped
    # note that this is rather a limitation than a feature and might be fixed in future releases
    fileShouldExist "three/foo.txt"
    dirShouldExist "three"
    dirShouldNotExist "two"
    dirShouldNotExist "one"
}

# run before container has been started
beforeStartMapping() {
  cd $baseDir

  mkdir -p volumes/src/existBeforeStart
  mkdir -p volumes/src/existBeforeStart/empty
  echo "some content" > volumes/src/existBeforeStart/some.txt

  fileMTime=$(mTime volumes/src/existBeforeStart/some.txt)

  # create an existing file in source
  mkdir -p volumes/src/update_test
  echo "initial content" > volumes/src/update_test/file.txt
  echo "initial content" > volumes/src/update_test/file2.txt

  existingFileMTime=$(mTime volumes/src/update_test/file.txt)
  # copy with same attrs to destination directory
  mkdir -p volumes/target/update_test_target
  cp -a volumes/src/update_test/file.txt volumes/target/update_test_target/
  # source file will be updated before container is started and after 1 second sleep

  echo "some other content" > "volumes/src/existBeforeStart/some spacey starter.txt"
  echo "a" > "volumes/src/existBeforeStart/some strange %'12&( starter.txt"

  sleep 1
  # update the update_test file (simulate an update of a previously copied file and a restart)
  # to test existingFileMTime
  echo "updated content" > volumes/src/update_test/file.txt

}

# run after container has been started
afterStartMapping() {
  cd "$baseDir/volumes/src"

  # create files in src
  mkdir -p my_dir
  mkdir no_slash_mapping
  touch no_slash_mapping/foo.txt
  mkdir empty_dir
  mkdir empty_dir/subfolder  # empty folders are ignored
  mkdir "spacey dir"
  mkdir not_so_spacey
  touch not_so_spacey/foo.txt
  mkdir 'stran"F%lder'
  touch 'stran"F%lder/foo.txt'
  mkdir someNormalFolder
  touch someNormalFolder/foo.txt

  mkdir nested
  mkdir my_dir/subFolder
  mkdir my_dir/floder
  sleep 1
  mkdir nested/first
  touch nested/first/foo.txt
  mkdir nested/second
  touch nested/second/foo.txt
  mkdir notStrangeFolder
  touch notStrangeFolder/foo.txt

  chainSetup

  mkdir -p songs/artist_prince
  touch "songs/artist_prince/purple rain.mp3"

  mkdir unmappedMusicFolder
  echo "content in folder with typo" > my_dir/floder/stuff.txt
  sleep 1

  mkdir "on_demand_argovia"
  touch "on_demand_argovia/.in.C055AA93-BC24.json"
  touch "on_demand_argovia/C055AA93-BC24.mp3"
  touch "on_demand_argovia/C055AA93-BC24.json"
  touch "on_demand_argovia/C055AA93-BC24.txt"

  cd my_dir
  mv floder folder
  echo "content in sub folder" > subFolder/file.txt
  echo "Hello ContentA" > contentA.txt

  contentAMTime=$(mTime "contentA.txt")
  echo "Some unimportant Content. " > "spacey contentWith $%strange.txt"
  echo "Some unimportant Content. more unimportant content" > "spacey contentWith $%strange.txt"
  cd ../"spacey dir"
  touch "content.txt"
  touch "space content.txt"
  cd ../unmappedMusicFolder

  touch "unmapped spacey test.mp3"

  cd "$baseDir/volumes/target"

  sleep 1

  dirShouldExist "other_dir"
  dirShouldExist "some_dir"
  # empty directory should not be mapped
  dirShouldNotExist "mapped_dir"
  dirShouldExist "spacey target"
  dirShouldExist "normalFolder"
  dirShouldExist 'st"F%lder'
  dirShouldExist "first"
  dirShouldExist "second"
  dirShouldExist "stranger\$Folder"

  dirShouldExist "music"

  fileShouldExistWithContent "other_dir/contentA.txt" "Hello ContentA"

  actMTime=$(mTime other_dir/contentA.txt)

  if [ "$contentAMTime" != "$actMTime" ]; then
    echo "ContentA should have mTime $contentAMTime but had $actMTime"
    success="false"
  fi

  chainTest

  # the folder with type in its name that got renamed, still exists in the target
  fileShouldExistWithContent "other_dir/floder/stuff.txt" "content in folder with typo"
  # LIMITATION: renaming the folder created no new copy of the folder
  # (as inotifywait only received a folder and folders are ignored)
  # the non-empty folder will be recognized on the next startup
  dirShouldNotExist "other_dir/folder"
  #fileShouldExistWithContent "other_dir/folder/stuff.txt" "content in folder with typo"

  fileShouldExistWithContent "other_dir/spacey contentWith $%strange.txt" "Some unimportant Content. more unimportant content"
  fileShouldExistWithContent "other_dir/subFolder/file.txt" "content in sub folder"
  fileShouldExist "not_so_spacey_target/content.txt"
  fileShouldExist "not_so_spacey_target/space content.txt"
  fileShouldExist "music/prince/purple rain.mp3"

  fileShouldExistWithContent "mappedDuringStart/some.txt" "some content"
  dirShouldNotExist "mappedDuringStart/empty"

  actMTime=$(mTime mappedDuringStart/some.txt)

  # the modification time of the copied file should be updated to now during the copy. That will happen after container has started
  if [ "$actMTime" -lt "$containerStartedTS" ]; then
    echo "mTime of mappedDuringStart/some.txt was earlier than allowed. mTime should be updated to the current time during copy. Which needs to be after the container has started"
    echo "mapped: "  $actMTime + " / containerStart: "  $containerStartedTS
    success="false"
  fi
  # mtime should have changed during copy
  if [ "$actMTime" = "$fileMTime" ]; then
    echo "mTime of mappedDuringStart/some.txt should have been updated during copy, but was the same as on source file"
    success="false"
  fi

  fileShouldExistWithContent "mappedDuringStart/some spacey starter.txt" "some other content"
  fileShouldExistWithContent "mappedDuringStart/some strange %'12&( starter.txt" "a"

  # the existing but updated file did not get re-copied on startup (still initial content)
  fileShouldExistWithContent "update_test_target/file.txt" "initial content"
  # also the timestamp did not change
  updateTestMTime=$(mTime update_test_target/file.txt)
  if [ "$existingFileMTime" != "$updateTestMTime" ]; then
    echo "mTime of update_test_target/file.txt should still be the initial modification time as the file did not get updated/touched"
    success="false"
  fi

  # a non-existing file got processed
  fileShouldExistWithContent "update_test_target/file2.txt" "initial content"

  # interim directories have been created
  dirShouldExist "ondemand/argovia"
  fileShouldExist "ondemand/argovia/C055AA93-BC24.mp3"
  fileShouldExist "ondemand/argovia/C055AA93-BC24.json"
  # dot file and txt not mapped
  fileShouldNotExist "ondemand/argovia/.in.C055AA93-BC24.json"
  fileShouldNotExist "ondemand/argovia/C055AA93-BC24.txt"

  # make sure watcher also recognizes files within subdirectories created after startup
  cd "$baseDir/volumes/src/existBeforeStart"
  mkdir "newsubdirectory"
  touch "newsubdirectory/newfile.txt"
  # allow some time for service to copy the file
  sleep 1s
  cd "$baseDir/volumes/target"
  fileShouldExist "mappedDuringStart/newsubdirectory/newfile.txt"

}
