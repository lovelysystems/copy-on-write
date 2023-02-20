#!/bin/bash
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

function matchesPairing {
  inputFilePath=$1
  sourceFolder=$2

  if [[ $inputFilePath =~ .?$sourceFolder.? ]] #TODO verify that regex in source works
  then
    return 0
  fi
  return 1
}

function getTargetFileFolders {
  directoryOfFile=$1
  fileName=$2
  matchedSourceFolder=$3

  rest=${directoryOfFile#*"$matchedSourceFolder"}
  if [[ ${rest: -1} == "/" ]]
  then
      rest=${rest:0:-1}
  fi
  echo "$rest"
}

function getOutputPath {
  inputDir=$1
  inputFileName=$2

  for p in "${pairs[@]}";
  do
    sourceFolder=$(getSourceFolder "$p")
    #echo "checking $inputDir $TARGET_ROOT$sourceFolder"
    if matchesPairing "$inputDir$inputFileName" "$sourceFolder";
    then
      targetFolder=$(getTargetFolder "$p")
      targetFileFolders=$(getTargetFileFolders "$inputDir" "$inputFileName" "$sourceFolder")
      echo "$TARGET_ROOT$targetFolder$targetFileFolders/$inputFileName"
      return 0
    fi
  done
}

#create target folders
for p in "${pairs[@]}";
do
  targetFolder=$(getTargetFolder $p)
  targetPath="$TARGET_ROOT$targetFolder"
  echo "Ensuring directory $targetPath exists"
  mkdir -p "$targetPath"
done

inotifywait -mr "$SOURCE_ROOT" -e create -e moved_to |
  while read -r dir action file; do
    fullSourcePath="$dir$file"
    echo "getting output for $dir$file"
    targetPath=$(getOutputPath "$dir" "$file")

    #TODO if new folder is read, reestablish listeners for that folder
    if [[ -z "$targetPath" ]];
    then
      echo "No matching pair found. Ignoring"
    else
      if [[ -f $fullSourcePath ]]; then
        mkdir -p "$(dirname "$targetPath")"
        echo "copying to $targetPath"
        cp -p "$fullSourcePath" "$targetPath"
      elif [[ -d $fullSourcePath ]]; then
        echo "creating directory $fullSourcePath"
        mkdir -p "$fullSourcePath"
      fi
    fi
  done