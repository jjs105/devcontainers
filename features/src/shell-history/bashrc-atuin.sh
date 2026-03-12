#!/usr/bin/env bash
#-------------------------------------------------------------------------------
# Copyright (c) Jon Spain (https://github.com/jjs105).
# Licensed under GNU GPL v3 or later.
# https://github.com/jjs105/devcontainers/tree/main/LICENSE
#-------------------------------------------------------------------------------

# This script provides logic and functionality to be added to a user's .bashrc
# or global /etc/bash.bashrc file by the jjs105/shell-history development
# container feature.

# Check if atuin is installed and not logged in.
if [ -x ~/.atuin/bin/atuin ] \
  && ! { ~/.atuin/bin/atuin status | grep --quiet "Username"; }; then

  # Load the bashrc library.
  [ ! -f "/opt/jjs105/lib/bashrc-lib.sh" ] \
    && printf "error: bashrc-lib.sh not found, skipping\n" && return 0 \
      || source "/opt/jjs105/lib/bashrc-lib.sh"

  # Setup and load the jjs10.ini file from the workspace to get the atuin info.
  setup_jjs105_ini "ATUIN_USERNAME" "ATUIN_PASSWORD" "ATUIN_KEY"
  source "./.jjs105.ini"

  # If we have all information then login and sync.
  if [ -n "${ATUIN_USERNAME}" ] \
  && [ -n "${ATUIN_PASSWORD}" ] \
  && [ -n "${ATUIN_KEY}" ]; then

    ~/.atuin/bin/atuin login \
      --username "${ATUIN_USERNAME}" \
      --password "${ATUIN_PASSWORD}" \
      --key "${ATUIN_KEY}"
    ~/.atuin/bin/atuin sync
  fi
fi
