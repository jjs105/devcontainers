# jjs105/devcontainers

Home for both development and management of personal development container
templates and features.

## Development Environment

The repository itself uses a tweaked version of the Node.js based development
container provided as a starter template for container development. This
container provides the following features:

* Use of Docker in Docker
* Installation of the official development container CLI tool(s)
* VS Code support for bash scripting (via extension)
* Installation of ESLint in VS Code (via extension)

# Repository Structure

The repository is split into two main areas. The first containing the source
code for the development container `templates` and the second the source code
for individual development container `features`.

In addition the repository contains a `scripts` directory containing support
scripts and tools used to develop the development templates and features.

# Implementation

The templates and features in this repository have been initially implemented as
an exercise to learn about development containers and features.

## Templates

## Features

The two main approaches to feature implementation seem to be either a) as a
single self-contained install script, or b) by utilising the approach used by
many of the official, or community supported, [development container features](
https://containers.dev/features), as follows:

* Use of a common
[library_scripts.sh](
    https://github.com/devcontainers-contrib/features/blob/main/src/bin/library_scripts.sh
) code library, for which there seems to be no master location

* Use of the [nanolayer](https://github.com/devcontainers-contrib/nanolayer) CLI
tool to keep container image layers as small as possible when installing
packages etc.

* Use of the [gh-release](
    https://github.com/devcontainers-contrib/features/tree/main/src/gh-release
) feature to install the latest release of the Exercism CLI directly from the
GitHub repository

* The above use of `nanolayer` and/or `gh-release` also require `python` to be
installed and available on the container

## Approach

The implementations in this repository utilise ideas from all of the above
approaches with the additional following aims:

* The feature should be fully stand-alone
* Container image layers should be kept as small as possible using best practice
* Centralise common functions in a library file that can be re-used at a later
date

# Build Tools etc.

Build tools contained in this repository are implemented either a) directly as
yarn scripts or b) in the scripts/bin directory. _In the latter case the
commands are also available as yarn scripts._

## Use of 'master' Scripts and Libraries

This repository utilises a build tool script which allows master versions of
certain reused files to be copied into the appropriate locations before build.

The master files and where they are copied to are listed below:

* `tools.sh cp-lib`
  * scripts/lib/devcontainers-lib.sh -> /templates/src/**/
  * scripts/lib/devcontainers-lib.sh -> /features/src/**/

* `tools.sh cp-test`
  * scripts/lib/test.sh -> /templates/test/**/
  * scripts/lib/test.sh -> /features/test/**/

