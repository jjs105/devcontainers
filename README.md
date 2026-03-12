# jjs105/devcontainers

Home for both development and management of personal development container
templates and features.

## Third Bite of the Cherry

It feels like going around and around in circles but this [new main] branch is
an attempt to actually create a simplified repository of development container
templates and features that is actually useable and useful without getting
bogged down in shared code libraries, extended functionality, and other baggage.

With this in mind a number of decisions have been made as follows:

* Always keep things simple
* No large collection of common libraries that have to be included in every
  template or feature (or by making a 'common' feature mandatory)*
* Always install or assume the `bash` shell
* Always assume availability of `apt-get` and/or Debian based ecosystem
* No need to support Alpine, Arch, Darwin or other non-Debian based distros
* No need to support ARM64 or other non-AMD64 based architectures
* Keep templates/features small in scope, no more catch all implementations
* Minimal implementation of tests for templates/features
* Utilise development containers CLI tool directly (as opposed to bespoke tools
  script or scripts)
* Use printf as opposed to echo for less issues with command substitution, new
  lines etc.

\* Within minutes of starting this approach to implementation far too much copy
and pasting of code was occurring. This solidifies in my mind that the lack of
any 'official' way to include or reference common code at either build or
runtime has to be the most frustrating part of developing development
containers.
