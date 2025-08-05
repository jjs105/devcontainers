#-------------------------------------------------------------------------------
# Copyright (c) Jon Spain (https://github.com/jjs105).
# Licensed under GNU GPL v3 or later
# https://github.com/jjs105/devcontainers/tree/main/LICENSE
#-------------------------------------------------------------------------------

# Install script for the odin-lang development container feature.

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

RELEASE="${RELEASE:=dev-2025-07}"
OS="${OS:=linux}"
ARCH="${ARCH:=amd64}"
COMPILE="${COMPILE:=false}"
EXAMPLES="${EXAMPLES:=true}"
OLS_CREATE_CONFIG="${OLS_CREATE_CONFIG:=true}"
OLS_CREATE_FORMAT="${OLS_CREATE_FORMAT:=true}"

#-------------------------------------------------------------------------------
# Library configuration and load.

# Set the library path to /opt/jjs105/lib.
# @note: We know this path is available because this development container
# feature depends on the jjs105-devcontainer development container feature.
_jjs105_lib_path="/opt/jjs105/lib"

# Configure logging.
_lib_install_log="true"
_lib_ini_log="true"
_log() { [ "true" = "true" ] && log "jjs105/odin-lang" "${1}" || :; }

# Include the lib-install.sh library from its install location.
# shellcheck source=lib/lib-install.sh
. "${_jjs105_lib_path}/lib-install.sh"

# Include the lib-ini.sh library from its install location.
# shellcheck source=lib/lib-ini.sh
. "${_jjs105_lib_path}/lib-ini.sh"

# Include our install functions (keeps overall install logic readable).
. "./install-functions.sh"

#-------------------------------------------------------------------------------
# Always required installations.

_check_not_windows
setup_jjs105_ini
setup_downloads

#-------------------------------------------------------------------------------
# Odin language pre-requisites installation.

install_packages clang

#-------------------------------------------------------------------------------
# Either compile and configure the Odin language or download a release version.

[ "true" = "${COMPILE}" ] \
  && _compile_and_configure_odin \
    || _install_odin_release

#-------------------------------------------------------------------------------
# Odin language configuration.

# Symlink the Odin language compiler to the standard location.
# POSIX/Alpine, ln -s (--symbolic).
[ ! -L "/usr/local/bin/odin" ] \
  && ln -s "/opt/jjs105/lib/odin-lang/odin" "/usr/local/bin/"

#-------------------------------------------------------------------------------
# Add packages as necessary.

[ "true" = "${EXAMPLES}" ] && _install_odin_examples || :

#-------------------------------------------------------------------------------
# Odin Language Server (OLS) copy files and configuration.

install_file_set "./ols/." "/opt/jjs105/lib/ols"

ini_set_value "${INI_FILE}" "odin-lang" \
  "create-ols-config" "${OLS_CREATE_CONFIG}"
ini_set_value "${INI_FILE}" "odin-lang" \
  "create-ols-format" "${OLS_CREATE_FORMAT}"

#-------------------------------------------------------------------------------
# Append our bashrc script to the end of the user's bashrc file.
# @note: We do this last so everything else is ready before it can ever be run.

append_script_to_bashrc "odin-lang-bashrc.sh"
