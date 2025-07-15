#-------------------------------------------------------------------------------
# Copyright (c) Jon Spain (https://github.com/jjs105).
# Licensed under GNU GPL v3 or later
# https://github.com/jjs105/devcontainers/tree/main/LICENSE
#-------------------------------------------------------------------------------

# Install script jjs105-devcontainer development container feature.

# @note: We assume that only the most basic POSIX shell (sh) is available to aid
# in OS compatibility etc.

# Exit on any failure, use +e to revert if necessary.
# WARNING: The use of set -e means that the script wil exit if ANY SINGLE
# COMMAND FAILS. This means that, for correct operation, tests that may fail
# as expected behaviour need to be part of a command that actually succeeds.
# @note: -x can be used for debugging purposes.
set -eux

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

# Set up our simplified log function.
_log() { log "devcontainer-install" "${1}"; }

# Copy/install the install-lib.sh library if necessary.
[ "true" = "${INSTALL_LIB}" ] \
  && _log "installing install-lib.sh" \
  && install_library ./lib/install-lib.sh /opt/jjs105/lib

# Copy/install the tst-lib.sh library if necessary.
[ "true" = "${TEST_LIB}" ] \
  && _log "installing test-lib.sh" \
  && install_library ./lib/test-lib.sh /opt/jjs105/lib

# If necessary install cURL and ensure we have a download directory.
if [ "true" = "${INSTALL_FZF}" ] || [ "true" = "${GIT_PROMPT}" ]; then
  _log "installing cURL"
  install_packages curl ca-certificates
  _log "creating download dir"
  DOWNLOAD_DIR="$(mktemp -d || mktemp -d -t 'tmp')"
fi

#-------------------------------------------------------------------------------
# Bash install and configuration.

# Check for bash and install if necessary.
[ "true" = "${ENSURE_BASH}" ] && [ ! $(command -v bash) ] \
  && _log "installing bash" \
  && install_packages bash

# If necessary change the bash history file location so that it can be shared
# between users and persisted as a volume.
if [ -n "${BASH_HISTORY_PATH}" ]; then
  if [ -n "${HISTORY_PATH:="${BASH_HISTORY_PATH%\.bash_history}"}" ]; then

    _log "setting bash history location to ${HISTORY_PATH}"
    mkdir -p "${HISTORY_PATH}" && touch "${HISTORY_PATH}/.bash_history" 
    chmod -R ugo+rw "${HISTORY_PATH}"

    _log "setting user bash history location(s)"
    SNIPPET="export HISTFILE=${HISTORY_PATH}.bash_history"
    run_command_for_users "echo -e \"\n\n${SNIPPET}\" >> ~/.bashrc"
  fi
fi

#-------------------------------------------------------------------------------
# Other tools installation and configuration.

# Download, install and configure fzf.
if [ "true" = "${INSTALL_FZF}" ]; then

  URL="https://raw.githubusercontent.com/junegunn/fzf/refs/heads/master/install"
  _log "downloading fzf from ${URL}"
  curl -sfL --retry 3 "${URL}" --output "${DOWNLOAD_DIR}/install-fzf"
  install_script "${DOWNLOAD_DIR}/install-fzf" /opt/jjs105

  _log "installing fzf for users"
  run_command_for_users "/opt/jjs105/install-fzf --all"
fi

# Download, install and configure Git prompt script.
if [ "true" = "${GIT_PROMPT}" ]; then

  URL="https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh"
  _log "downloading git-prompt from ${URL}"
  curl -sfL --retry 3 "${URL}" --output "${DOWNLOAD_DIR}/git-prompt.sh"
  install_library "${DOWNLOAD_DIR}/git-prompt.sh" /opt/jjs105/lib

  _log "configuring git prompt for users"
  run_command_for_users "cat $(pwd)/lib/bash-prompt.sh >> ~/.bashrc"
fi

#-------------------------------------------------------------------------------
# Script cleanup etc.

# Remove the download directory if created.
[ -n "${DOWNLOAD_DIR}" ] \
  && _log "removing download dir" \
  && rm -r "${DOWNLOAD_DIR}"
