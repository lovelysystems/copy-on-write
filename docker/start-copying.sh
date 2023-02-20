#!/bin/bash
set -e
#TODO if source env ends with /
IFS=';' read -r -a pairs <<< "$FOLDER_PAIRS"

function getTargetFolder {
  pair=$1
  IFS=":" read -r -a pairing <<< "$pair"
  echo "${pairing[1]}"
}

function getSourceFolder {
  pair=$1
  IFS=":" read -r -a pairing <<< "$pair"
  echo "${pairing[0]}"
}

#/opt/src/nested/second/

function matchesPairing {
  input_path=$1
  source_folder=$2

  if [[ $input_path == *$source_folder* ]] #for now basically tests for contains
  then
    return 0
  fi
  return 1
}

function getOutputPath {
  inputDir=$1
  inputFileName=$2

  for p in "${pairs[@]}";
  do
    source_folder=$(getSourceFolder $p)
    #echo "checking $inputDir $TARGET_ROOT$source_folder"
    if matchesPairing "$inputDir" "$source_folder";
    then
      #echo "matched $TARGET_ROOT$source_folder"
      target_folder=$(getTargetFolder $p)
      echo "$TARGET_ROOT$target_folder/$inputFileName"
      return 0
    fi
  done
  echo "$TARGET_ROOT$inputFileName" #fallback
  return 0
}

#create target folders
for p in "${pairs[@]}";
do
  target_folder=$(getTargetFolder $p)
  target_path="$TARGET_ROOT$target_folder"
  echo "Ensuring directory $target_path exists"
  mkdir -p "$target_path"
done


inotifywait -r -m $SOURCE_ROOT -e create -e moved_to |
  while read -r dir action file; do
    echo "The file '$file' appeared in directiory '$dir' via '$action'"
    full_source_path="$dir$file"
    echo "getting output for $dir$file"
    target_path=$(getOutputPath $dir $file)
    echo "copying to $target_path"
    cp -p $full_source_path $target_path
  done