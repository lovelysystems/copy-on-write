# README - copy on write

Docker image to maintain a duplicated directory structure. Works based on filesystem events. Copies a file/directory from a tracked source directory when it is created or moved to the source directory. Modification time of the original file will be preserved other timestamps will be set to now during the copy. Works based on regex substitution. See [replacements](localdev/replacements.sed) for an example mapping.

On startup existing files/directories in SOURCE_ROOT are mapped and copied to target if mapped.

See [localdev/docker-compose.yml](localdev/docker-compose.yml) for usage

## Tests
Tests can be run by executing [test.sh](localdev/test.sh). This requires docker engine to be running locally and docker compose v2.

## Limitations
- when a folder in the source directories is renamed a folder with the corresponding name will be created in target. However, the old folder in target will still exist. 