#!/bin/bash

#-------------------------------------------------------------------------------
# Copyright (c) Jon Spain (https://github.com/jjs105).
# Licensed under GNU GPL v3 or later
# https://github.com/jjs105/devcontainers/tree/main/LICENSE
#-------------------------------------------------------------------------------

# This script is executed when the development container is attached and is used
# to check vGPU and accelerated video support as necessary.

#-------------------------------------------------------------------------------
# Library inclusion and copy + required script setup.

# Include the install-lib.sh library from its install location.
. /opt/jjs105/lib/install-lib.sh

# Check that the jjs105 INI file exists.
[ ! -f "${INI_FILE=/opt/jjs105/etc/jjs105.ini}" ] \
  && _log "INI file (${INI_FILE}) not found, exiting" \
  && exit 1

#-------------------------------------------------------------------------------
# Check vGPU and accelerated video support.

CHECK=$(ini_get_value "${INI_FILE}" "wslg-support" "check-device-dxg")
if truthy "${CHECK}"; then
  [ -e /dev/dxg ] \
    && echo "vGPU support enabled" \
      || echo "vGPU support not enabled"
fi

CHECK=$(ini_get_value "${INI_FILE}" "wslg-support" "check-device-video")
if truthy "${CHECK}"; then
  ([ -e /dev/dri/card0 ] || [ -e /dev/dri/renderD128 ]) \
    && echo "Accelerated video support enabled" \
      || echo "Accelerated video support not enabled"
fi
