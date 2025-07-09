# jjs105/devcontainers

Home for both development and management of personal development container
templates and features.

## tl;dr

This readme has become a full history regarding this repository, tl;dr is that
this is bog-standard development container templates/feature repository
utilising POSIX shell based build script(s) and a symbolic link to allow all
features to be referenced as if they were local during development.

## Development Environment

The repository itself uses a tweaked version of the Node.js based development
container provided as a starter template for container development. This
container provides the following features:

* Use of Docker in Docker
* Installation of the official development container CLI tool(s)
* VS Code support for bash scripting (via extension)
* Installation of ESLint in VS Code (via extension)
* Inclusion of the `jjs105-devcontainer` development container feature

## Repository Structure

The repository is split into the following main areas:

* Source code for development container `templates`*
* Source code for individual development container `features`
* Scripts and tools used to build the development containers templates and
  features in `scripts`*

\* To be completed.

### A note on Using (ba)sh

Where possible, and by default, the standard POSIX shell `sh` is used for script
development - i.e. it is not assumed that `bash` is installed, for example when
considering Alpine images.

There is an argument to be made that this repository is an opportunity for me to
start learning another language - for example TypeScript, Python or Go - by
using said language for development of the build scripts - however one thing at
a time!

## Implementation

The templates and features in this repository were initially, and continue to
be, implemented mainly as an exercise to learn about the usage and
implementation of development containers and features.

### Templates

[The main approach for templates TBC]

### Features

The two main approaches to feature implementation seem to be either a) as a
single self-contained install script, or b) by utilising the approach used by
many of the official, or community supported, [development container features](
https://containers.dev/features), as follows:

* Use of a common [library_scripts.sh](
    https://github.com/devcontainers-contrib/features/blob/main/src/bin/library_scripts.sh
  ) code library, for which there seems to be no master location
* Use of the [nanolayer](
    https://github.com/devcontainers-contrib/nanolayer
  ) CLI tool to keep container image layers as small as possible when installing
  packages etc.
* Use of the [gh-release](
    https://github.com/devcontainers-contrib/features/tree/main/src/gh-release
  ) feature to install the latest releases of apps/scripts directly from the
  GitHub repository

Note, the above use of `nanolayer` and/or `gh-release` also require `python` to
be installed and available on the container.

### Aims

The implementations in this repository utilise ideas from the above approaches
with the additional following aims:

* Development container templates and feature should be fully stand-alone
* Container image layers should be kept as small as possible using best practice
* Centralise common functions in a library file that can be re-used at a later
  date

## Implementation Approach

The approach used for development of elements of this repository - more
specifically features - as evolved over time, including at leat one u-turn and
one start from scratch.

The current approach is to develop all development container templates and
features in place (i.e. within their src folder) and use the jjs105-devcontainer
feature as a dependency to include any common libraries - which should be kept
to a minimum.

## Alternative Approaches

The ideal solution would allow development using common/centralised code and/or
libraries, however as described in the [development containers proposal](
  https://github.com/devcontainers/spec/blob/main/proposals/features-library.md
), use of common/shared code between features (and templates?) - or lack
thereof - is a known issue, an accepted solution for which has not yet been
finalised or implemented.

Other approaches that could be undertaken are described below.

### Full Implementation of the Shared Library Proposal

The idea of implementing the above proposal utilising a PR has merit however,
after brief investigation, my Node.js experience is lacking with regard to such
an undertaking. Additionally this repository, as stated above, is for personal
use and mainly as an exercise in learning about development containers.

Beyond the lack of Node.js experience this approach also has the disadvantage
that - until official roll-out and adoption of any proposal solution - any
developed features would be wholly incompatible with software which supports
development containers - i.e. IDEs etc.

Further - also until official roll-out and adoption - a bespoke/customised
devcontainers-CLI tool would also need to be developed and used.

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

#### Use of Symbolic Links

An attempt was made to utilise (soft) symbolic links to include/reference
resources common to multiple development container templates/features.

However, with one exception, this approach was not successful due to the 
development container clients and tools not respecting these links during normal
operation. This may have been possible with hard symbolic links but these are
not supported by git.

The single successful exception to this was the use of a symbolic link to allow 
use of the development container features *within this repository* to be
utilised/referenced by the development container *of this repository*, as if
they were local features.



