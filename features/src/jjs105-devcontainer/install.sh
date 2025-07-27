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

INSTALL_LIB="${INSTALL_LIB:=false}"
TEST_LIB="${TEST_LIB:=false}"
ENSURE_BASH="${ENSURE_BASH:=true}"
BASH_HISTORY_PATH="${BASH_HISTORY_PATH:=}"
INSTALL_FZF="${INSTALL_FZF:=true}"
GIT_PROMPT="${GIT_PROMPT:=true}"

#-------------------------------------------------------------------------------
# Library inclusion and copy + required script setup.

# Include the install-lib.sh library directly from the container.
. ./lib/install-lib.sh

# Ensure logs are configured and set up our simplified log function.
_log() { log "jjs105/devcontainer" "${1}"; }
log_setup

# Copy/install the install-lib.sh library if necessary.
# @note: We check that the file does not already exist to avoid overwriting.
[ "true" = "${INSTALL_LIB}" ] && [ -f "/opt/jjs105/lib/install-lib.sh" ] \
  && _log "install-lib.sh already exists, skipping install" \
  && INSTALL_LIB="false"
[ "true" = "${INSTALL_LIB}" ] \
  && _log "installing install-lib.sh" \
  && install_library ./lib/install-lib.sh /opt/jjs105/lib

# Copy/install the test-lib.sh library if necessary.
# @note: We check that the file does not already exist to avoid overwriting.
[ "true" = "${TEST_LIB}" ] && [ -f "/opt/jjs105/lib/test-lib.sh" ] \
  && _log "test-lib.sh already exists, skipping install" \
  && TEST_LIB="false"
[ "true" = "${TEST_LIB}" ] \
  && _log "installing test-lib.sh" \
  && install_library ./lib/test-lib.sh /opt/jjs105/lib

# If necessary install cURL and ensure we have a download directory.
if [ "true" = "${INSTALL_FZF}" ] || [ "true" = "${GIT_PROMPT}" ]; then
  _log "installing cURL"
  install_packages curl ca-certificates
  _log "creating download dir"
  # @note: -t is used to specify a template for the temporary directory name.
  DOWNLOAD_DIR="$(mktemp --directory || mktemp --directory -t 'tmp')"
fi

#-------------------------------------------------------------------------------
# Bash install and configuration.

# Check for bash and install if necessary.
# @note: command -v is similar to using type but more portable.
[ "true" = "${ENSURE_BASH}" ] && [ ! $(command -v bash) ] \
  && _log "installing bash" \
  && install_packages bash

# If necessary change the bash history file location so that it can be shared
# between users and persisted as a volume.
# @note: We allow this code to run even if multiple installs of the development
# container feature - just in case the user has set different paths.
if [ -n "${BASH_HISTORY_PATH}" ]; then
  if [ -n "${HISTORY_PATH:="${BASH_HISTORY_PATH%\.bash_history}"}" ]; then

    _log "setting bash history location to ${HISTORY_PATH}"
    mkdir --parents "${HISTORY_PATH}" && touch "${HISTORY_PATH}/.bash_history" 
    chmod --recursive ugo+rw "${HISTORY_PATH}"

    _log "setting user bash history location(s)"
    SNIPPET="export HISTFILE=${HISTORY_PATH}.bash_history"
    # @note: echo -e means interpret escaped chars, -n means no ending newline.
    run_command_for_users "echo -e \"\n\n${SNIPPET}\" >> ~/.bashrc"
  fi
fi

#-------------------------------------------------------------------------------
# Other tools installation and configuration.

# Download, install and configure fzf.
# @note: We allow this code to run even if multiple installs of the development
# container feature - fzf doesn't mind being installed multiple times.
if [ "true" = "${INSTALL_FZF}" ]; then

  URL="https://raw.githubusercontent.com/junegunn/fzf/refs/heads/master/install"
  _log "downloading fzf from ${URL}"
  curl --silent --fail --location --retry 3 "${URL}" \
    --output "${DOWNLOAD_DIR}/install-fzf"
  install_script "${DOWNLOAD_DIR}/install-fzf" /opt/jjs105

  _log "installing fzf for users"
  run_command_for_users "/opt/jjs105/install-fzf --all"
fi

# Download, install and configure Git prompt script.
# @note:@ We check if the script has already been downloaded - i.e. by a
# previous install of this feature - to avoid overwriting.
[ -f "/opt/jjs105/lib/git-prompt.sh" ] \
  && _log "git-prompt.sh already exists, skipping install" \
  && GIT_PROMPT="false"
if [ "true" = "${GIT_PROMPT}" ]; then

  URL="https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh"
  _log "downloading git-prompt from ${URL}"
  curl --silent --fail --location --retry 3 "${URL}" \
    --output "${DOWNLOAD_DIR}/git-prompt.sh"
  install_library "${DOWNLOAD_DIR}/git-prompt.sh" /opt/jjs105/lib

  _log "configuring git prompt for users"
  run_command_for_users "cat $(pwd)/lib/bash-prompt.sh >> ~/.bashrc"
fi

#-------------------------------------------------------------------------------
# Script cleanup etc.

# Remove the download directory if created.
[ -n "${DOWNLOAD_DIR}" ] \
  && _log "removing download dir" \
  && rm --recursive "${DOWNLOAD_DIR}"
