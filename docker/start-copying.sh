#!/bin/bash

IFS=$'\n' read -d '' -r -a pairs <<<"$FOLDER_PAIRS"
inotifywait -mr "$SOURCE_ROOT" -e moved_to,create --format '%w|%f' | # using the pipe as our seperator
  while IFS='|' read -r dir file; do
    fullPath="$dir$file"
    if [[ -d $fullPath ]]; then #TODO and doesnt end with slash
      fullPath="$fullPath/"
    fi

    # TODO test if target of pairs can have slash or not?

    #ugly but works
    foundMatch=1

    originalPath=${fullPath#"$SOURCE_ROOT"}

    echo "$fullPath $originalPath"
    for regex in "${pairs[@]}";
    do
      replacedPath=$(echo "$originalPath" | sed "s#$regex#g")
      if [[ "$originalPath" != "$replacedPath" ]]; then
        echo "mapped $originalPath to $replacedPath"
        foundMatch=0
        break
        # this has the behaviour that the first match is the "winning" match
      fi
    done

    if [[ $foundMatch == 0 ]]; then
      if [[ -d $fullPath ]]; then
        echo "making dir $TARGET_ROOT$replacedPath"
        mkdir "$TARGET_ROOT$replacedPath"
      else
        echo "copying file $TARGET_ROOT$replacedPath"
        cp -p "$fullPath" "$TARGET_ROOT$replacedPath"
      fi
    fi
  done