#-------------------------------------------------------------------------------
# Copyright (c) Jon Spain (https://github.com/jjs105).
# Licensed under GNU GPL v3 or later
# https://github.com/jjs105/devcontainers/tree/main/LICENSE
#-------------------------------------------------------------------------------

# Install script for the wsl2-x11-gui development container feature.

# @note: We assume that only the most basic POSIX shell (sh) is available to aid
# in OS compatibility etc.

# Exit on any failure, use +e to revert if necessary.
# WARNING: The use of set -e means that the script wil exit if ANY SINGLE
# COMMAND FAILS. This means that, for correct operation, tests that may fail
# as expected behaviour need to be part of a command that actually succeeds.
# @note: -x can be used for debugging purposes.
set -eu

#-------------------------------------------------------------------------------
# Feature options.
# @note: := substitution to ensure var=null => true.

INSTALL_X11_APPS="${INSTALL_X11_APPS:=true}"
INSTALL_MESA_UTILS="${INSTALL_MESA_UTILS:=true}"
CHECK_DEVICE_DXG="${CHECK_DEVICE_DXG:=true}"
CHECK_DEVICE_VIDEO="${CHECK_DEVICE_VIDEO:=true}"

#-------------------------------------------------------------------------------
# Library inclusion and copy + required script setup.

# Include the install-lib.sh library from its install location.
. /opt/jjs105/lib/install-lib.sh

# Set up our simplified log function.
_log() { log "jjs105/wslg-support" "${1}"; }

#-------------------------------------------------------------------------------
# Install packages etc.

# Required packages
_log "installing required packages"
install_packages vainfo mesa-va-drivers

# Install the X11 apps if requested.
"true" = "${INSTALL_X11_APPS}" ] \
  && _log "installing X11 apps" \
  && install_packages x11-apps

# Install the Mesa utilities if requested.
[ "true" = "${INSTALL_MESA_UTILS}" ] \
  && _log "installing Mesa utilities" \
  && install_packages mesa-utils

#-------------------------------------------------------------------------------
# Copy and configure the check options script.

_log "setting up check options script"
install_script ./check-wslg-options.sh /opt/jjs105/bin
mkdir --parents /opt/jjs105/etc
[ "true" = "${CHECK_DEVICE_DXG}" ] && touch /opt/jjs105/etc/.check-vgpu
[ "true" = "${CHECK_DEVICE_VIDEO}" ] && touch /opt/jjs105/etc/.check-accvid
chmod --recursive ugo+r /opt/jjs105/etc
