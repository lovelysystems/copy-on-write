# README - copy on write

Docker image to maintain a duplicated directory structure. Works based on filesystem events. Copies a file/directory from a tracked source directory when it is created or moved to the source directory. Modification time of the original file will be preserved other timestamps will be set to now during the copy. Works based on regex substitution. See [replacements](localdev/replacements.sed) for an example mapping.

On startup existing files/directories in SOURCE_ROOT are mapped and copied to target if mapped.

See [localdev/docker-compose.yml](localdev/docker-compose.yml) for an example configuration.

## Tests

Tests can be run by executing [test.sh](localdev/test.sh). This requires docker engine to be running locally and docker compose v2.

## Development

To test changes, tell compose to rebuild the image before startup: `docker compose up --build --force-recreate`

## Limitations

- when a folder in the source directories is renamed a folder with the corresponding name will be created in target. However, the old folder in target will still exist.

- test.sh depend on output of `stat` command which is filesystem specific (tested on macos with `apfs`)

- on linux test.sh needs to be run as root user (or docker/docker-compose configured to run with the current user)
