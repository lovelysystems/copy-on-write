#!/bin/bash

# returns file modification in seconds since epoch
mTime() {
  filename=$1
  if uname | grep -q "Darwin"; then
      # stat bsd version
      # %m mtime
      # %c ctime
      mod_time_fmt="-f %m"
  else
      # stat gnu version
      # %Y time of last data modification, seconds since Epoch
      # %W time of file birth, seconds since Epoch; 0 if unknown
      mod_time_fmt="-c %Y"
  fi
  stat $mod_time_fmt $filename
}


# check they exist in target
dirShouldExist() {
  path=$1
  if [ ! -d "$path" ]; then
    echo "$path should exist in target but didn't"
    success="false"
  fi
}

dirShouldNotExist() {
  path=$1
  if [ -d "$path" ]; then
    echo "$path should not exist but exists"
    success="false"
  fi
}


fileShouldExist() {
  if [ ! -f "$1" ]; then
    echo "File $1 should exist but didn't"
    success="false"
  fi
}


fileShouldNotExist() {
  if [ -f "$1" ]; then
    echo "File $1 should not exist but did"
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
