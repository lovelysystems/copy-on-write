# Changes for copy-on-write

## 2023-06-12 / 1.3.0

### Breaking

* Copy to `*.part` files and rename file when complete. This allows watchers to be sure
  a file is complete when the `create` event is fired.

## Development

- Update alpine 3.16.4 to 3.18.0

## 2023-04-18 / 1.2.0

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
