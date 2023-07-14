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

  # do not handle directories at all
  if [ -d "$fullPath" ]; then
    return
  fi

  originalPath=${fullPath#"$SOURCE_ROOT"}
  replacedPath=$(echo "$originalPath" | sed -r -f "${SCRIPT_FILE_PATH:-"replacements.sed"}")


  # FIXME: limitation: we can't map src/foo to target/foo currently (as paths would not differ)
  if [[ "$originalPath" != "$replacedPath" ]]; then

    newFilename="$TARGET_ROOT$replacedPath"

    # append sha1 sum before file extension
    if [[ "${APPEND_SHA1_SUM:-false}" == "true" ]]; then
      sha=$(sha1sum $fullPath | cut -d " " -f 1)
      # foo.txt -> foo-e1d35a6f7182bfbac1c45f6bfdc12419e06e8d59.txt
      newFilename=$(echo $newFilename | sed "s/\.[^.]*$/-$sha&/")
    fi

    # do not copy file if it already exists
    if [ -f "$newFilename" ]; then
      return
    fi

    # create itermediate directories if necessary
    directory="$(dirname "$TARGET_ROOT$replacedPath")"
    if [[ ! -d "$directory" ]]; then
      >&2 echo "creating intermediate directories for $directory"
      mkdir -p "$directory"
    fi

    >&2 echo "copying $fullPath to $newFilename"
    # cp will create all new timestamps for the new file
    cp "$fullPath" "$newFilename.part"
    # copy to a *.part file and rename when complete to make sure
    # watchers will process a complete file (create event is fired before file is complete)
    mv "$newFilename.part" "$newFilename"

    # remove incoming file in case DELETE_SOURCE_FILE is true
    if [[ "${DELETE_SOURCE_FILE:-false}" == "true" ]]; then
      >&2 echo "removing $fullPath"
      rm $fullPath
    fi

  fi
}

export -f copyIfMapped

>&2 echo "Searching for mapped files and directories in $SOURCE_ROOT"
>&2 echo "Checking `find $SOURCE_ROOT | wc -l` items..."

find "$SOURCE_ROOT" -type f -exec bash -c 'copyIfMapped "{}"' \;

>&2 echo "Watching for updates in $SOURCE_ROOT"


#do NOT include the "open" event, copy command will trigger a open event -> resulting in an endless loop
inotifywait -mr "$SOURCE_ROOT" -e moved_to -e create -e modify --format '%w%f' |
  while read -r fullPath; do
    copyIfMapped "$fullPath"
  done
