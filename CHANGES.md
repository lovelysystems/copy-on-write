# Changes for copy-on-write

## Unreleased

### Breaking

* Do not preserve modified timestamp on copy as on most unix filesystems the
  creation time of a file is not accessible so the mtime is the ts our file
  got processed by copy-on-write

### Fixes

* Do not re-process (update) existing files on restart

## 2023-04-05 / 1.1.0

### Breaking

* Only treat files, create intermediate folders if necessary

## 2023-03-13 / 1.0.1

### Fixes

* remove unnecessary call to `bash` in `find --exec`


## 2023-03-06 / 1.0.0

Set created/accessed timestamp to now on copy, preserve modified timestamp.