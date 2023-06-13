#!/bin/bash

# returns file modification in seconds since epoch
function mTime() {
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

export -f mTime
