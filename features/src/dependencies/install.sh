#!/usr/bin/env sh
# @note: Assume that only the most basic POSIX shell (sh) is available.

#-------------------------------------------------------------------------------
# Copyright (c) Jon Spain (https://github.com/jjs105).
# Licensed under GNU GPL v3 or later.
# https://github.com/jjs105/devcontainers/tree/main/LICENSE
#-------------------------------------------------------------------------------

# Initial bash availability check script for the jjs105/dependencies development
# container. Checks for, and installs bash if necessary, then continues the
# install via the main bash script.

# Exit on any failure or unset variable, use +eu to revert if necessary.
set -eu

# Development container feature options.
SKIP_BASH_CHECK="${SKIP_BASH_CHECK:=false}"

# If bash is NOT installed.
if [ "true" != "${SKIP_BASH_CHECK}" ] && [ ! "$(command -v bash)" ]; then

  # Check running as root and apt-get is available.
  [ "$(id -u)" != 0 ] \
    && printf "error: not running as root, exiting\n" && exit 1 || :
  [ ! -x "/usr/bin/apt" ] \
    && printf "error: apt-get not found, exiting\n" && exit 1 || :

  # Install bash.
  # @note: Debian/Ubuntu specific, will require update for Alpine, Darwin etc.
  printf "install: bash not found, installing\n"
  apt-get update --assume-yes
  apt-get install --assume-yes --no-install-recommends bash
fi

# Run the main bash based install script.
exec "/bin/bash" "${PWD}/main.sh" "${@}"
