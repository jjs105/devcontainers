#-------------------------------------------------------------------------------
# Copyright (c) Jon Spain (https://github.com/jjs105).
# Licensed under GNU GPL v3 or later
# https://github.com/jjs105/devcontainers/tree/main/LICENSE
#-------------------------------------------------------------------------------

# Install script for the jjs105-devcontainer development container feature.

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

INSTALL_LIBRARIES_ONLY="${INSTALL_LIBRARIES_ONLY:=false}"
EXPECTED_SECRETS="${EXPECTED_SECRETS:=}"
SHELL_HISTORY_METHOD="${SHELL_HISTORY_METHOD:=atuin_fzf}"
BASH_HISTORY_PATH="${BASH_HISTORY_PATH:=/command-history/.bash_history}"
GIT_PROMPT="${GIT_PROMPT:=true}"

#-------------------------------------------------------------------------------
# Library configuration and load.

# Set the library path during install to our relative location.
# @note: We need to do this as the POSIX shell doesn't have a way to get the
# current script path and we haven't yet copied them to /opt/jjs105/lib.
_jjs105_lib_path="${PWD}/lib"

# Configure logging.
_lib_install_log="true"
_lib_ini_log="true"
_log() { [ "true" = "true" ] && log "jjs105/devcontainer" "${1}" || :; }

# Include the lib-install.sh library directly from the container.
# shellcheck source=lib/lib-install.sh
. "${_jjs105_lib_path}/lib-install.sh"

# Include the lib-secrets.sh library directly from the container.
# shellcheck source=lib/lib-secrets.sh
. "${_jjs105_lib_path}/lib-secrets.sh"

# Include our install functions (keeps overall install logic readable).
. "./install-functions.sh"

#-------------------------------------------------------------------------------
# Always required actions.

# Install all our library files.
# @note: We have to hard-code the path here as the _jjs105_lib_path variable
# points to the development container files location during install.
install_file_set "./lib/." "/opt/jjs105/lib"

# If only installing library files then we are done.
[ "true" = "${INSTALL_LIBRARIES_ONLY}" ] \
  && _log "libraries only installed, exiting" \
  && exit 0

_ensure_bash
setup_jjs105_ini
setup_downloads

#-------------------------------------------------------------------------------
# Add any expected secrets to the ini file.

[ -n "${EXPECTED_SECRETS}" ] \
  && secrets_add_expected_to_ini "${EXPECTED_SECRETS}"

#-------------------------------------------------------------------------------
# Bash usage, history and prompt configuration.

# If necessary change the bash history file location so that it can be shared
# between users and persisted as a volume.
[ "shared_file" = "${SHELL_HISTORY_METHOD}" ] \
  && [ -n "${BASH_HISTORY_PATH}" ] \
    && _set_history_path "${BASH_HISTORY_PATH}" \
      || :

# Download an install the Git prompt script if necessary.
[ "true" = "${GIT_PROMPT}" ] && _install_git_prompt || :

#-------------------------------------------------------------------------------
# Install fzf and/or atuin bash history tools as necessary.

[ "fzf" = "${SHELL_HISTORY_METHOD##atuin_}" ] && _install_fzf || :
[ "atuin" = "${SHELL_HISTORY_METHOD%%_fzf}" ] && _install_atuin || :

#-------------------------------------------------------------------------------
# Append our bashrc script to the end of the user's bashrc file.
# @note: We do this last so everything else is ready before it can ever be run.

append_script_to_bashrc "jjs105-bashrc.sh"
