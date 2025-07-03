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

## Repository Structure

The repository is split into two main areas. The first containing the source
code for the development container `templates` and the second the source code
for individual development container `features`.

In addition the repository contains a `scripts` directory containing support
scripts and tools used to develop the development templates and features.

## Implementation

The templates and features in this repository have been initially implemented as
an exercise to learn about development containers and features.

### Templates

### Features

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
) feature to install the latest releases of apps/scripts directly from the
GitHub repository

Note, the above use of `nanolayer` and/or `gh-release` also require `python` to
be installed and available on the container

## Approach

The implementations in this repository utilise ideas from the above approaches
with the additional following aims:

* The feature should be fully stand-alone
* Container image layers should be kept as small as possible using best practice
* Centralise common functions in a library file that can be re-used at a later
date

### Stand-Alone and/or Shared Library Usage

As described in the development containers proposal found at the URL below, use
of common/shared code between features (and templates?) - or lack thereof - is a
known issue, an accepted  solution for which has not yet been finalised or
implemented.

https://github.com/devcontainers/spec/blob/main/proposals/features-library.md

### Other Possible Approaches

For expediency the use of copied 'master' files described later is being run
with, however it is less than ideal - hence the discovery of the proposal above.

Other approaches that could be undertaken are described below.

#### Full Implementation of the Shared Library Proposal

The idea of implementing this proposal utilising a PR has merit however, after
brief investigation, my Node.js experience is lacking with regard to such an
undertaking. Additionally this repository, as stated above, is for personal use
and mainly as an exercise in learning about development containers.

Beyond the lack of Node.js experience this approach also has the disadvantage
that - until official roll-out and adoption of any proposal solution - any
developed features would be wholly incompatible with software which supports
development containers - i.e. IDEs etc.

Further - also until official roll-out and adoption - a bespoke/customised
devcontainers CLI tool would also need to be developed and used.

#### Partial Implementation of the Shared Library Proposal

Another option would be to implement '[Proposal A] Add: include property to
devcontainer-feature.json' only.

This approach could then be used in conjunction with either a) build scripts or
b) a bespoke/customised devcontainers CLI tool to manage the files contained in
a feature prior to build/test/package/publish.

Although promising as an approach, to avoid incompatibility with software
supporting development containers even part A of the proposal could not be fully
adhered to - specifically any 'included' files would need to be copied within
the target features as opposed to the root of the distribution package.

Additionally simply adding an 'include' section to the devcontainer-feature.json
file may cause the packaged features to be deemed invalid by any supporting
software.

#### Modified Development Process with Pre-Build

As opposed to copying 'master' files throughout this repository prior to the
build/test/package/publish of features (which then need to be ignored in Git)
this process could be automated as part of a bespoke build script utilising any
or all of the following features:

* Copy all files to a single (Git ignored) build area prior to build
* Copy the master files as initially implemented but clean up after the build
process has completed
* Identify files to be copied via either a) an 'include' section in the
devcontainer-feature.json file (see above) or alternative '.include' file or
similar
* Include options to automatically generate test script and test scenario stub
files etc.

## Build Tools etc.

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

## History

All features etc. were initially developed as complete stand-alone artifacts.
Soon after the concept of copy master files was implemented. Even from its
initial use this approach was deemed a hack and less than ideal - hence
discovery of the shared library proposal and the thoughts regarding different
approaches documented above.

Even considering my lack of Node.js experience, serious consideration was given
to forking the devcontainers CLI tool and implementing a butchered version of
the shared library proposal (part A).

The decision was made to run with the approach of copying master files
throughout the repository prior to build - then quickly rejected AGAIN, it
really is both inelegant and messy.
