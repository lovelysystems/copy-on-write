#!/bin/bash

scriptFilePath=${SCRIPT_FILE_PATH:-"replacements.sed"}

if [[ ! -f "$scriptFilePath" ]]; then
  echo "Script file not found at $scriptFilePath. Exiting"
  exit 1
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
      if [[ -d $fullPath ]]; then
        >&2 echo "making dir $TARGET_ROOT$replacedPath"
        mkdir "$TARGET_ROOT$replacedPath"
      else
        >&2 echo "copying file $TARGET_ROOT$replacedPath"
        cp -p "$fullPath" "$TARGET_ROOT$replacedPath"
      fi
    fi
  done