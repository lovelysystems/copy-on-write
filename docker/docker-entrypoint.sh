#!/bin/bash

scriptFilePath=${SCRIPT_FILE_PATH:-"replacements.sed"}

if [[ ! -f "$scriptFilePath" ]]; then
  echo "Script file not found at $scriptFilePath. Exiting"
  exit 1
fi

if [[ ! -d "$SOURCE_ROOT" ]]; then
  echo "Source root doesn't exist. Exiting"
  exit 1
fi

if [[ ! -d "$TARGET_ROOT" ]]; then
  echo "Target root doesn't exist. Exiting"
  exit 1
fi

#do NOT include the "open" event, copy command will trigger a open event -> resulting in an endless loop
inotifywait -mr "$SOURCE_ROOT" -e moved_to -e create -e close_write -e modify --format '%w%f' |
  while read -r fullPath; do
    ending="${rest: -1}"
    if [ -d "$fullPath" ] && [ "$ending" != "/" ]; then
      fullPath="$fullPath/"
    fi

    originalPath=${fullPath#"$SOURCE_ROOT"}
    replacedPath=$(echo "$originalPath" | sed -r -f "$scriptFilePath")
    if [[ "$originalPath" != "$replacedPath" ]]; then
      >&2 echo "copying $TARGET_ROOT$replacedPath"
      cp -pR "$fullPath" "$TARGET_ROOT$replacedPath"
    fi
  done