#!/usr/bin/env bash
#-------------------------------------------------------------------------------
# Copyright (c) Jon Spain (https://github.com/jjs105).
# Licensed under GNU GPL v3 or later.
# https://github.com/jjs105/devcontainers/tree/main/LICENSE
#-------------------------------------------------------------------------------

# This script provides logic and functionality to be added to a user's .bashrc
# or global /etc/bash.bashrc file by the jjs105/wslg-support development
# container feature.

# Check for required device paths.
if [ ! -e /dev/dxg ] \
|| [ ! -e /dev/dri/card0 ] \
|| [ ! -e /dev/dri/renderD128 ]; then
  printf "WSLg-support: could not find device paths, have you set runArgs in devcontainer.json"
fi
