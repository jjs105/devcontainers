#!/usr/bin/env bash
#-------------------------------------------------------------------------------
# Copyright (c) Jon Spain (https://github.com/jjs105).
# Licensed under GNU GPL v3 or later.
# https://github.com/jjs105/devcontainers/tree/main/LICENSE
#-------------------------------------------------------------------------------

# Main install script for the jjs105/dependencies development container. Updates
# the OS, installs a minimal install library and then installs common tools and
# other dependencies.

# Exit on any failure or unset variable, use +eu to revert if necessary.
set -eu

# Load the minimal install library from its location in the feature.
source "${PWD}/install-lib.sh"

# Check for root access.
ensure_root

# Update the OS.
update_os

# Install the common tools and dependencies.
install_packages coreutils sudo
install_packages curl ca-certificates
install_packages vim nano

# Install the libraries for use by other development container features to the
# container .
install_with_permissions "${PWD}/install-lib.sh" "/opt/jjs105/lib" "u=rw,go=r"
install_with_permissions "${PWD}/bashrc-lib.sh" "/opt/jjs105/lib" "u=rw,go=r"
