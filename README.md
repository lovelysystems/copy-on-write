# README - copy on write

Docker image to maintain a duplicated directory structure. Works based on filesystem events. Copies a file/directory from a tracked source directory when it is created or moved to the source directory.
Works based on regex substitution. See [replacements](localdev/replacements.sed) for an example mapping.

See `localdev` for usage