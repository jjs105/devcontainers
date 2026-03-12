#!/usr/bin/env bash
#-------------------------------------------------------------------------------
# Copyright (c) Jon Spain (https://github.com/jjs105).
# Licensed under GNU GPL v3 or later.
# https://github.com/jjs105/devcontainers/tree/main/LICENSE
#-------------------------------------------------------------------------------

# Install script for the jjs105/wslg-support development container feature.

# Exit on any failure or unset variable, use +eu to revert if necessary.
set -eux

# Development container feature options.
INSTALL_PULSE_AUDIO="${INSTALL_PULSE_AUDIO:=true}"
INSTALL_MESA_UTILS="${INSTALL_MESA_UTILS:=true}"
INSTALL_X11_APPS="${INSTALL_X11_APPS:=true}"

# Check for and then load the minimal install library from its location in the
# container.
[ ! -f "/opt/jjs105/lib/install-lib.sh" ] \
  && printf "error: install-lib.sh not found, exiting\n" && exit 1 \
    || source "/opt/jjs105/lib/install-lib.sh"

# Check for root access.
ensure_root

# Install an and all required and/or optional packages.
install_packages mesa-va-drivers
[ "true" = "${INSTALL_PULSE_AUDIO}" ] \
  && install_packages pulseaudio pulseaudio-utils || :
[ "true" = "${INSTALL_MESA_UTILS}" ] && install_packages vainfo mesa-utils || :
[ "true" = "${INSTALL_X11_APPS}" ] && install_packages x11-apps || :

# Install the bespoke WSLg script from the feature.
install_with_permissions \
  "${PWD}/bashrc-wslg.sh" "/opt/jjs105/lib" "u=rw,go=r"

# Source the bespoke WSLg script from appropriate .bashrc files.
append_bashrc \
  "# Load jjs105/bashrc-wslg script." \
  "source /opt/jjs105/lib/bashrc-wslg.sh"
