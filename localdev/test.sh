#!/bin/sh

#so that the script can be called from any directory
originalWd=$(pwd)
cd "$(dirname $0)"
trap 'cd $originalWd' EXIT

docker compose down #incase

mkdir -p ../volumes/src/existBeforeStart
echo "some content" > ../volumes/src/existBeforeStart/some.txt
echo "some other content" > "../volumes/src/existBeforeStart/some spacey starter.txt"
echo "a" > "../volumes/src/existBeforeStart/some strange %'12&( starter.txt"

sleep 1
docker compose up --build -d --wait
sleep 2 # so the container has time do initial copying and initialize the watches

mkdir ../volumes/target/music

success="true"
cd ../volumes/src

#create files in src
mkdir my_dir
mkdir no_slash_mapping
mkdir "spacey dir"
mkdir not_so_spacey
mkdir my_other_dir
mkdir 'stran"F%lder'
mkdir someNormalFolder

mkdir nested
mkdir my_dir/subFolder
mkdir my_dir/floder
sleep 1
mkdir nested/first
mkdir nested/second
mkdir notStrangeFolder

mkdir unmappedMusicFolder
echo "content in folder with typo" > my_dir/floder/stuff.txt
sleep 1

cd my_dir
mv floder folder
echo "content in sub folder" > subFolder/file.txt
echo "Hello ContentA" > contentA.txt
echo "Some unimportant Content. " > "spacey contentWith $%strange.txt"
echo "Some unimportant Content. more unimportant content" > "spacey contentWith $%strange.txt"
cd ../"spacey dir"
touch "content.txt"
touch "space content.txt"
cd ../unmappedMusicFolder

touch "spacey test.mp3"

cd ../../target

sleep 1

# check they exist in target

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

fileShouldExistWithContent() {
  fileShouldExist "$1"
  contentAct=$(cat "$1")
  if [ "$contentAct" != "$2" ]; then
    echo "File $1 should have content $2 but had $contentAct"
    success="false"
  fi
}

fileShouldExistWithContent "other_dir/contentA.txt" "Hello ContentA"
fileShouldExistWithContent "other_dir/folder/stuff.txt" "content in folder with typo"
fileShouldExistWithContent "other_dir/spacey contentWith $%strange.txt" "Some unimportant Content. more unimportant content"
fileShouldExistWithContent "other_dir/subFolder/file.txt" "content in sub folder"
fileShouldExist "not_so_spacey_target/content.txt"
fileShouldExist "not_so_spacey_target/space content.txt"
fileShouldExist "music/spacey test.mp3"

fileShouldExistWithContent "mappedDuringStart/some.txt" "some content"
fileShouldExistWithContent "mappedDuringStart/some spacey starter.txt" "some other content"
fileShouldExistWithContent "mappedDuringStart/some strange %'12&( starter.txt" "a"

cd ../../localdev

rm -rf ../volumes/src/*
rm -rf ../volumes/target/*

docker compose down

if [ $success = "false" ]; then
  echo "Tests Failed"
else
  echo "Tests success"
fi