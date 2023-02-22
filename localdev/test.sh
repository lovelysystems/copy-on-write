#!/bin/sh


docker compose down #incase
docker compose up --build -d --wait

sleep 2 # so the container has time to initialize the watches

#setup folders on host
rm -rf ../sandbox/src/*
rm -rf ../sandbox/target/*

mkdir ../sandbox/target/music

success="true"
cd ../sandbox/src

#create files in src
mkdir my_dir
mkdir no_slash_mapping
mkdir "spacey dir"
mkdir not_so_spacey
mkdir my_other_dir
mkdir 'stran"F%lder'
mkdir someNormalFolder

mkdir nested
sleep 1
mkdir nested/first
mkdir nested/second
mkdir notStrangeFolder

mkdir unmappedMusicFolder

cd my_dir
touch "contentA.txt"
touch "spacey contentWith $%strange.txt"
cd ../"spacey dir"
touch "content.txt"
touch "space content.txt"
cd ../unmappedMusicFolder

touch "spacey test.mp3"

cd ../../target

sleep 1

# check they exist in target

success=1

dirShouldExist() {
  path=$1
  if [ ! -d "$path" ]; then
    echo "$path should exist in target but didnt"
    success="false"
  fi
}


dirShouldExist "other_dir"
dirShouldExist "some_dir"
dirShouldExist "not_so_spacey_target"
dirShouldExist "spacey target"
dirShouldExist "also_another_dir"
dirShouldExist "normalFolder"
dirShouldExist 'st"F%lder'
dirShouldExist "first"
dirShouldExist "second"
dirShouldExist "stranger\$Folder"

dirShouldExist "music"

fileShouldExist() {
  if [ ! -f "$1" ]; then
    echo "File $1 should exist but didnt"
    success="false"
  fi
}

fileShouldExist "other_dir/contentA.txt"
fileShouldExist "other_dir/spacey contentWith $%strange.txt"
fileShouldExist "not_so_spacey_target/content.txt"
fileShouldExist "not_so_spacey_target/space content.txt"
fileShouldExist "music/spacey test.mp3"

cd ../../localdev

docker compose down

if [ $success = "false" ]; then
  echo "Tests Failed"
else
  echo "Tests success"
fi