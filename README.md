# README - copy on write

Docker image to maintain a duplicated directory structure. Works based on filesystem events. Copies a file/directory from a tracked source directory when it is created or moved to the source directory.
All timestamps will be set to now during the copy, no timestamps are preserved. This way we make sure we have monotonous rising timestamps for incoming files. 

Works based on regex substitution. See [replacements](localdev/replacements.sed) for an example mapping.

On startup existing files in SOURCE_ROOT are copied to target if mapped.
You can use `INITIAL_FIND_PARAMS` (GNU find parameters) to further limit the files copied initially:
Eg `INITIAL_FIND_PARAMS='-mtime -2'` to only copy files modified less than 2*24 hours ago.

To make sure a file that ends up in the target directory is complete, a `.part` extension is added and
the file is renamed when copy has finished.
Make sure to exclude `*.part` files when using watchers to process files in the target directory.

See [localdev/docker-compose.yml](localdev/docker-compose.yml) for an example configuration.

## Tests

Tests can be run by executing [test.sh](localdev/test.sh). This requires docker engine to be running locally and docker compose v2.

## Development

To test changes, tell compose to rebuild the image before startup: `docker compose up --build --force-recreate`

## Limitations

- existing files (matching name) won't get updated (file content/metadata is not compared)

- currently it is not possible to map a file from `$SOURCE/my_dir` to `$TARGET/my_dir`.
  (the file path relative to source and target directory must be distinct in order to copy a file)

- when a folder in the source directories is renamed a folder with the mapped name will not be created in target immediately.

  * On restart, the new folder and existing files will be copied.
  * However, the old folder in target will still exist (not get removed/renamed)

- SED processes all rules in the configuration file sequentially which could result in chained mappings.
  make sure to use regular expressions specific enough (e.g. by using `^start_of_string`)

- on linux test.sh needs to be run as root user (or docker/docker-compose configured to run with the current user)
