#!/usr/bin/env bash
#-------------------------------------------------------------------------------
# Copyright (c) Jon Spain (https://github.com/jjs105).
# Licensed under GNU GPL v3 or later.
# https://github.com/jjs105/devcontainers/tree/main/LICENSE
#-------------------------------------------------------------------------------

# Install script for the jjs105/prompt development container feature.

# Exit on any failure or unset variable, use +eu to revert if necessary.
set -eu

# Check for and then load the minimal install library from its location in the
# container.
[ ! -f "/opt/jjs105/lib/install-lib.sh" ] \
  && printf "error: install-lib.sh not found, exiting\n" && exit 1 \
    || source "/opt/jjs105/lib/install-lib.sh"

# Check for root access.
ensure_root

# Install the main prompt script from the feature.
install_with_permissions \
  "${PWD}/bashrc-prompt.sh" "/opt/jjs105/lib" "u=rw,go=r"

# Download and install the git prompt script.
download_and_install \
  "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh" \
  "/opt/jjs105/lib" \
  "u=rw,go=r"

# Source the main prompt script from appropriate .bashrc files.
append_bashrc \
  "# Load jjs105/bashrc-prompt script." \
  "source /opt/jjs105/lib/bashrc-prompt.sh"
