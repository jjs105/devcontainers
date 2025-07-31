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

TEST_LIB="${TEST_LIB:=false}"
ENSURE_BASH="${ENSURE_BASH:=true}"
EXPECTED_SECRETS="${EXPECTED_SECRETS:=}"
SHELL_HISTORY_METHOD="${SHELL_HISTORY_METHOD:=atuin_fzf}"
BASH_HISTORY_PATH="${BASH_HISTORY_PATH:=/command-history/.bash_history}"
ATUIN_DISABLE_UP_ARROW="${ATUIN_DISABLE_UP_ARROW:=true}"
ATUIN_ENTER_ACCEPT="${ATUIN_ENTER_ACCEPT:=false}"
ATUIN_INLINE_HEIGHT="${ATUIN_INLINE_HEIGHT:=0}"
GIT_PROMPT="${GIT_PROMPT:=true}"

#-------------------------------------------------------------------------------
# Library inclusion and copy + required script setup.

# Include the install-lib.sh library directly from the container.
. ./lib/install-lib.sh

# Ensure logs are configured and set up our simplified log function.
_log() { log "jjs105/devcontainer" "${1}"; }
log_setup

# Copy/install the install-lib.sh library.
# @note: This used to be based on an option but now we always copy.
# @note: We check that the file does not already exist to avoid overwriting.
[ ! -f "/opt/jjs105/lib/install-lib.sh" ] \
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

# Install cURL and ensure we have a download directory.
_log "installing cURL"
install_packages curl ca-certificates
_log "creating download dir"
# @note: -t is used to specify a template for the temporary directory name.
DOWNLOAD_DIR="$(mktemp --directory || mktemp --directory -t 'tmp')"

# Ensure that we have a general jjs105 INI file.
ensure_jjs105_ini

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

    # Need to double check the shared history method is set to shared_file.
    if [ "shared_file" != "${SHELL_HISTORY_METHOD}" ]; then
      _log "bash history location, method not set to shared_file, skipping"
    else

      _log "setting bash history location to ${HISTORY_PATH}"
      mkdir --parents "${HISTORY_PATH}" && touch "${HISTORY_PATH}/.bash_history" 
      chmod --recursive ugo+rw "${HISTORY_PATH}"

      _log "setting user bash history location(s)"
      SNIPPET="export HISTFILE=${HISTORY_PATH}.bash_history"
      # @note: echo -e means interpret escaped chars, -n means no ending newline.
      run_command_for_users "echo -e \"\n\n${SNIPPET}\" >> ~/.bashrc"
    fi
  fi
fi

#-------------------------------------------------------------------------------
# Other tools installation and configuration.

# Download, install and configure fzf.
# @note: We check if the script has already been downloaded - i.e. by a
# previous install of this feature - to avoid re-installation.
[ -f "/opt/jjs105/install-fzf" ] \
  && _log "install-fzf already exists, skipping install" \
  && FZF_INSTALLED="true" || FZF_INSTALLED="false"
if [ "true" != "${FZF_INSTALLED}" ] \
  && [ "fzf" = "${SHELL_HISTORY_METHOD##atuin_}" ]; then

  URL="https://raw.githubusercontent.com/junegunn/fzf/refs/heads/master/install"
  _log "downloading fzf from ${URL}"
  curl --silent --fail --location --retry 3 "${URL}" \
    --output "${DOWNLOAD_DIR}/install-fzf"
  install_script "${DOWNLOAD_DIR}/install-fzf" /opt/jjs105

  _log "installing fzf for users"
  run_command_for_users "/opt/jjs105/install-fzf --all"
fi

# Download, install and configure atuin.
# @note: We check if the script has already been downloaded - i.e. by a
# previous install of this feature - to avoid re-installation.
[ -f "/opt/jjs105/install-atuin" ] \
  && _log "install-atuin already exists, skipping install" \
  && ATUIN_INSTALLED="true" || ATUIN_INSTALLED="false"
if [ "true" != "${ATUIN_INSTALLED}" ] \
  && [ "atuin" = "${SHELL_HISTORY_METHOD%%_fzf}" ]; then

  URL="https://setup.atuin.sh"
  _log "downloading atuin from ${URL}"
  curl --silent --fail --location --retry 3 "${URL}" \
    --output "${DOWNLOAD_DIR}/install-atuin"
  install_script "${DOWNLOAD_DIR}/install-atuin" /opt/jjs105

  _log "installing atuin for users"
  run_command_for_users "/opt/jjs105/install-atuin"

  # For some reason atuin config file is root only.
  [ "root" != "${_CONTAINER_USER}" ] \
    && chmod ugo+rw "/home/${_CONTAINER_USER}/.config/atuin/config.toml"
  [ "${_CONTAINER_USER}" = "${_REMOTE_USER}" ] \
    && [ -f "/home/${_REMOTE_USER}/.config/atuin/config.toml" ] \
    && chmod ugo+rw "/home/${_REMOTE_USER}/.config/atuin/config.toml"

  # @note: sed -E is used to ensure POSIX compatibility.
  PATTERN="atuin init bash"; FLAG="--disable-up-arrow"
  PATTERN="s/${PATTERN}/${PATTERN} ${FLAG}/g"
  [ "true" = "${ATUIN_DISABLE_UP_ARROW}" ] \
    && _log "disabling atuin up arrow" \
    && run_command_for_users "sed -E --in-place '${PATTERN}' ~/.bashrc"
fi

# Download, install and configure Git prompt script.
# @note: We check if the script has already been downloaded - i.e. by a
# previous install of this feature - to avoid re-installation.
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
# Copy and configure the post-attach script.

_log "setting up jjs105-post-attach script"
install_script ./jjs105-post-attach.sh /opt/jjs105/bin

# Set the options we may need in the future.
ini_set_value "${INI_FILE}" "shell" \
  "shell_history_method" "${SHELL_HISTORY_METHOD}"
ini_set_value "${INI_FILE}" "atuin" \
  "atuin_enter_accept" "${ATUIN_ENTER_ACCEPT}"
ini_set_value "${INI_FILE}" "atuin" \
  "atuin_inline_height" "${ATUIN_INLINE_HEIGHT}"

#-------------------------------------------------------------------------------
# Secrets.

# In this install.sh context we have access to options but not the configured
# workspace. For this reason we just add any list of secrets to our INI file.
# @note: We do this last as we are messing with the IFS value.

# Loop through the variable adding the blank values.
if [ -n "${EXPECTED_SECRETS}" ]; then
  IFS=,; for secret in ${EXPECTED_SECRETS}; do
    _log "secret: ${secret}"
    ini_set_value "${INI_FILE}" "expected-secrets" "${secret}" ""
  done
fi

# Copy the example secrets file for later use.
install_library ./lib/.jjs105-secrets.example /opt/jjs105/lib

#-------------------------------------------------------------------------------
# Script cleanup etc.

# Remove the download directory if created.
[ -n "${DOWNLOAD_DIR}" ] \
  && _log "removing download dir" \
  && rm --recursive "${DOWNLOAD_DIR}"
