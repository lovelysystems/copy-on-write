#!/bin/bash

scriptFilePath=$SCRIPT_FILE_PATH
if [ -z "$scriptFilePath" ]; then
  scriptFilePath="/replacements.sed"
  #DEFAULT
fi

inotifywait -mr "$SOURCE_ROOT" -e moved_to -e create --format '%w%f' |
  while read -r fullPath; do
    ending="${rest: -1}"
    if [ -d "$fullPath" ] && [ "$ending" != "/" ]; then
      fullPath="$fullPath/"
    fi

    originalPath=${fullPath#"$SOURCE_ROOT"}
    replacedPath=$(echo "$originalPath" | sed -r -f $scriptFilePath)
    if [[ "$originalPath" != "$replacedPath" ]]; then
      echo "mapped $originalPath to $replacedPath"

      if [[ -d $fullPath ]]; then
        echo "making dir $TARGET_ROOT$replacedPath"
        mkdir "$TARGET_ROOT$replacedPath"
      else
        echo "copying file $TARGET_ROOT$replacedPath"
        cp -p "$fullPath" "$TARGET_ROOT$replacedPath"
      fi
    fi
  done