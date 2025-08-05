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
# Library configuration and load.
# @note: Simple install so no need for separate install-functions.sh.

# Set the library path to /opt/jjs105/lib.
# @note: We know this path is available because this development container
# feature depends on the jjs105-devcontainer development container feature.
_jjs105_lib_path="/opt/jjs105/lib"

# Configure logging.
_lib_install_log="true"
_lib_ini_log="true"
_log() { [ "true" = "true" ] && log "jjs105/wslg-support" "${1}" || :; }

# Include the lib-install.sh library from its install location.
# shellcheck source=lib/lib-install.sh
. "${_jjs105_lib_path}/lib-install.sh"

# Include the lib-ini.sh library from its install location.
# shellcheck source=lib/lib-ini.sh
. "${_jjs105_lib_path}/lib-ini.sh"

#-------------------------------------------------------------------------------
# Always required installations.

setup_jjs105_ini
setup_downloads

#-------------------------------------------------------------------------------
# Install packages etc.

# Required packages
_log "installing required packages"
install_packages vainfo mesa-va-drivers || :

# Install the X11 apps if requested.
[ "true" = "${INSTALL_X11_APPS}" ] \
  && _log "installing X11 apps" \
  && install_packages x11-apps || :

# Install the Mesa utilities if requested.
[ "true" = "${INSTALL_MESA_UTILS}" ] \
  && _log "installing Mesa utilities" \
  && install_packages mesa-utils || :

#-------------------------------------------------------------------------------
# Configure the check options.

ini_set_value "${INI_FILE}" "wslg-support" \
  "check-device-dxg" "${CHECK_DEVICE_DXG}"
ini_set_value "${INI_FILE}" "wslg-support" \
  "check-device-video" "${CHECK_DEVICE_VIDEO}"

#-------------------------------------------------------------------------------
# Append our bashrc script to the end of the user's bashrc file.
# @note: We do this last so everything else is ready before it can ever be run.

append_script_to_bashrc "wslg-support-bashrc.sh"
