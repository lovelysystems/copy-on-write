# README - copy on write

Docker image to maintain a duplicated directory structure. Works based on filesystem events. Copies a file/directory from a tracked source directory when it is created or moved to the source directory.
Works based on regex substitution. See [replacements](localdev/replacements.sed) for an example mapping.

On startup existing files/directories in SOURCE_ROOT are mapped and copied to target if mapped.


See `localdev` for usage

## Limitations
- when a folder in the source directories is renamed a folder with the corresponding name will be created in target. However, the old folder in target will still exist. 