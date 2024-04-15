# PHPUnit

Provides the PHPUnit tool(s).

# Feature Implementation

This feature has been initially implemented as an exercise to learn about development container features.

## Sources

There are many existing examples of similar, simple features. These implementations use different approaches. The first
as a single self-contained install script, the second utilises the approach used by many of the official, or community
supported, [development container features](https://containers.dev/features), as follows:

* Use of a common
[library_scripts.sh](https://github.com/devcontainers-contrib/features/blob/main/src/bin/library_scripts.sh) code
library, for which there seems to be no master location

* Use of the [nanolayer](https://github.com/devcontainers-contrib/nanolayer) CLI tool to keep container image layers as
small as possible when installing packages etc.

* Use of the [gh-release](https://github.com/devcontainers-contrib/features/tree/main/src/gh-release) feature to install
the latest release of the Exercism CLI directly from the GitHub repository

* The above use of `nanolayer` and/or `gh-release` also require `python` to be installed and available on the container

## Implementation Approach

This implementation utilises ideas from both of the above implementations with the following aims:

* The feature should be fully stand-alone

* Container image layers should be kept as small as possible using best practice

* Centralise common functions in a library file that can be re-used at a later date

# Anot on