# README - copy on write

Docker image to maintain a duplicated directory structure. Works based on filesystem events. Copies a file/directory from a tracked source directory when it is created or moved to the source directory.
All timestamps will be set to now during the copy, no timestamps are preserved. This way we make sure we have monotonous rising timestamps for incoming files. 

Works based on regex substitution. See [replacements](localdev/replacements.sed) for an example mapping.

On startup existing files in SOURCE_ROOT are copied to target if mapped.

See [localdev/docker-compose.yml](localdev/docker-compose.yml) for an example configuration.

## Tests

Tests can be run by executing [test.sh](localdev/test.sh). This requires docker engine to be running locally and docker compose v2.

## Development

To test changes, tell compose to rebuild the image before startup: `docker compose up --build --force-recreate`

## Limitations

- existing files (matching name) won't get updated (file content/metadata is not compared)

- when a folder in the source directories is renamed a folder with the mapped name will not be created in target immediately.

  * On restart, the new folder and existing files will be copied.
  * However, the old folder in target will still exist (not get removed/renamed)

- on linux test.sh needs to be run as root user (or docker/docker-compose configured to run with the current user)
