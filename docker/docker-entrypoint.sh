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
    >&2 echo "copying $fullPath to $TARGET_ROOT$replacedPath"
    # cp will create all new timestamps for the new file
    cp -R "$fullPath" "$TARGET_ROOT$replacedPath"
    # we want to preserve the mtime from the old file, copy the timestamp from the oldfile
    touch -m -r "$fullPath" "$TARGET_ROOT$replacedPath" # take the modify time from the oldfile
  fi
}

export -f copyIfMapped

>&2 echo "Searching for mapped files and directories in $SOURCE_ROOT"
>&2 echo "Checking `find $SOURCE_ROOT | wc -l` items..."

find "$SOURCE_ROOT" -exec bash -c 'copyIfMapped "{}"' \;

>&2 echo "Watching for updates in $SOURCE_ROOT"


#do NOT include the "open" event, copy command will trigger a open event -> resulting in an endless loop
inotifywait -mr "$SOURCE_ROOT" -e moved_to -e create -e modify --format '%w%f' |
  while read -r fullPath; do
    copyIfMapped "$fullPath"
  done