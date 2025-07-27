#!/bin/bash

#-------------------------------------------------------------------------------
# Copyright (c) Jon Spain (https://github.com/jjs105).
# Licensed under GNU GPL v3 or later
# https://github.com/jjs105/devcontainers/tree/main/LICENSE
#-------------------------------------------------------------------------------

# This script is executed when the development container is created and is used
# to create the Odin Language Server (OLS) configuration files in the workspace 
# root as necessary.

#-------------------------------------------------------------------------------
# Library inclusion and copy + required script setup.

# Include the install-lib.sh library from its install location.
. /opt/jjs105/lib/install-lib.sh

# Set up our simplified log function.
_log() { log "jjs105/odin-lang" "${1}"; }

# Check that the jjs105 INI file exists.
[ ! -f "${INI_FILE=/opt/jjs105/etc/jjs105.ini}" ] \
  && _log "INI file (${INI_FILE}) not found, exiting" \
  && exit 1

#-------------------------------------------------------------------------------
# Odin Language Server (OLS) configuration file(s) creation.

# Copy our ols.json file if configured and not already present.
CREATE=$(ini_get_value "${INI_FILE}" "odin-lang" "create-ols-config")
if truthy "${CREATE}" && [ ! -f "./ols.json" ]; then
  _log "creating OLS configuration file (ols.json)"
  install_workspace_file /opt/jjs105/lib/ols/ols.json ./
fi

# Copy our odinfmt.json file if configured and not already present.
CREATE=$(ini_get_value "${INI_FILE}" "odin-lang" "create-ols-format")
if truthy "${CREATE}" && [ ! -f "./odinfmt.json" ]; then
  _log "creating OLS format file (odinfmt.json)"
  install_workspace_file /opt/jjs105/lib/ols/odinfmt.json ./
fi
