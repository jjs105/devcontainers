#-------------------------------------------------------------------------------
# Copyright (c) Jon Spain (https://github.com/jjs105).
# Licensed under GNU GPL v3 or later
# https://github.com/jjs105/devcontainers/tree/main/LICENSE
#-------------------------------------------------------------------------------

# This script is added to the user's .bashrc file to check vGPU and accelerated
# video support as necessary.

# This file is not intended to be run as a script, although it is possible.
# Rather it should be sourced by, or appended to, a user's .bashrc file.

# Check that the jjs105 INI file exists or return.
# @note: Return without error so that bashrc continues.
[ ! -f "${INI_FILE:=/opt/jjs105/etc/jjs105.ini}" ] && return 0

# Make sure the INI library is loaded.
. "/opt/jjs105/lib/lib-ini.sh"

#-------------------------------------------------------------------------------
truthy() {
  # Function to check if a value is truthy - 1, y, yes, t, true
  # ${1} - the value to check

  case "${1}" in
    1|[yY]|[yY][eE][sS]|[tT]|[tT][rR][uU][eE]) return 0;;
    *) return 1;;
  esac
}

#-------------------------------------------------------------------------------
# Check vGPU and accelerated video support.

_check=$(ini_get_value "${INI_FILE}" "wslg-support" "check-device-dxg")
if truthy "${_check}"; then
  [ -e /dev/dxg ] \
    && echo "vGPU support enabled" \
      || echo "vGPU support not enabled"
fi

_check=$(ini_get_value "${INI_FILE}" "wslg-support" "check-device-video")
if truthy "${_check}"; then
  ([ -e /dev/dri/card0 ] || [ -e /dev/dri/renderD128 ]) \
    && echo "Accelerated video support enabled" \
      || echo "Accelerated video support not enabled"
fi
