#!/bin/bash

scriptFilePath=${SCRIPT_FILE_PATH:-"/replacements.sed"}

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

function copyIfMapped {
  fullPath=$1

  if [ -d "$fullPath" ]; then
    fullPath="$fullPath/"
  fi
  originalPath=${fullPath#"$SOURCE_ROOT"}

  replacedPath=$(echo "$originalPath" | sed -r -f "${SCRIPT_FILE_PATH:-"replacements.sed"}")
  if [[ "$originalPath" != "$replacedPath" ]]; then
    >&2 echo "copying to $TARGET_ROOT$replacedPath"
    cp -R "$fullPath" "$TARGET_ROOT$replacedPath"
  fi
}

export -f copyIfMapped

find "$SOURCE_ROOT" -exec bash -c 'copyIfMapped "$1"' bash {} \;

#do NOT include the "open" event, copy command will trigger a open event -> resulting in an endless loop
inotifywait -mr "$SOURCE_ROOT" -e moved_to -e create -e modify --format '%w%f' |
  while read -r fullPath; do
    copyIfMapped "$fullPath"
  done