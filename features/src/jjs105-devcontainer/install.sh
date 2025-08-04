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

EXPECTED_SECRETS="${EXPECTED_SECRETS:=ATUIN_USERNAME,ATUIN_PASSWORD,ATUIN_KEY}"
SHELL_HISTORY_METHOD="${SHELL_HISTORY_METHOD:=atuin_fzf}"
BASH_HISTORY_PATH="${BASH_HISTORY_PATH:=/command-history/.bash_history}"
GIT_PROMPT="${GIT_PROMPT:=true}"

#-------------------------------------------------------------------------------
# Library configuration and load.

# Set the library path during install to our relative location.
_jjs105_lib_path="${PWD}/lib"

# Configure logging.
_lib_install_log="true"
_lib_ini_log="true"
_log() { [ "true" = "true" ] && log "jjs105/devcontainer" "${1}" || :; }

# Include the lib-install.sh library directly from the container.
# shellcheck source=lib/lib-install.sh
. "${_jjs105_lib_path}/lib-install.sh"

# Include our install functions (keeps overall install logic readable).
. "./install-functions.sh"

#-------------------------------------------------------------------------------
# Always required installations.

_install_library_files
_ensure_bash
setup_jjs105_ini
setup_downloads

#-------------------------------------------------------------------------------
# Add any expected secrets to the ini file.

if [ -n "${EXPECTED_SECRETS}" ]; then
  # shellcheck source=lib/lib-secrets.sh
  . "${_jjs105_lib_path}/lib-secrets.sh"
  secrets_add_expected_to_ini "jjs105-devcontainer" "${EXPECTED_SECRETS}"
fi

#-------------------------------------------------------------------------------
# Bash usage, history and prompt configuration.

# If necessary change the bash history file location so that it can be shared
# between users and persisted as a volume.
[ "shared_file" = "${SHELL_HISTORY_METHOD}" ] \
  && [ -n "${BASH_HISTORY_PATH}" ] \
    && _set_history_path "${BASH_HISTORY_PATH}" \
      || :

# Download an install the Git prompt script if necessary.
# @note: We check if the script has already been downloaded - i.e. by a
# previous install of this feature - to avoid re-installation.
[ "true" = "${GIT_PROMPT}" ] && _install_git_prompt || :

#-------------------------------------------------------------------------------
# Install fzf and/or atuin bash history tools as necessary.

[ "fzf" = "${SHELL_HISTORY_METHOD##atuin_}" ] && _install_fzf || :
[ "atuin" = "${SHELL_HISTORY_METHOD%%_fzf}" ] && _install_atuin || :

#-------------------------------------------------------------------------------
# Update the .bashrc file for all users.

# POSIX/Alpine, grep -q (--quiet), -s (--no-messages).
_grep="grep -q -s \"jjs105-devcontainer\" ~/.bashrc"
_cat="cat ${_jjs105_lib_path}/jjs105-bashrc.sh >> ~/.bashrc"
run_command_for_users "${_grep} || ${_cat}"
