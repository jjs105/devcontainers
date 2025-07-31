#!/bin/bash

#-------------------------------------------------------------------------------
# Copyright (c) Jon Spain (https://github.com/jjs105).
# Licensed under GNU GPL v3 or later
# https://github.com/jjs105/devcontainers/tree/main/LICENSE
#-------------------------------------------------------------------------------

# This script is executed when the development container is attached and is used
# to carry out feature configuration requiring access to the VS Code workspace.

# Exit on any failure, use +e to revert if necessary.
# WARNING: The use of set -e means that the script wil exit if ANY SINGLE
# COMMAND FAILS. This means that, for correct operation, tests that may fail
# as expected behaviour need to be part of a command that actually succeeds.
# @note: -x can be used for debugging purposes.
set -eu

#-------------------------------------------------------------------------------
# Library inclusion and copy + required script setup.

# Include the install-lib.sh library from its install location.
. /opt/jjs105/lib/install-lib.sh

# Ensure logs are configured and set up our simplified log function.
_log() { log "jjs105/devcontainer" "${1}"; }

# Check that the jjs105 INI file exists.
[ ! -f "${INI_FILE=/opt/jjs105/etc/jjs105.ini}" ] \
  && _log "INI file (${INI_FILE}) not found, exiting" \
  && exit 1

# Get the current user.
USER=$(whoami)

#-------------------------------------------------------------------------------
# atuin configuration.

# Disable atuin enter accept if necessary.
# @note: sed -E is used to ensure POSIX compatibility.
ATUIN_ENTER_ACCEPT=$(ini_get_value "${INI_FILE}" "atuin" "atuin_enter_accept")
PATTERN="s/enter_accept = true/enter_accept = ${ATUIN_ENTER_ACCEPT}/g"
[ -f "${HOME}/.config/atuin/config.toml" ] \
  && _log "setting atuin enter_accept to ${ATUIN_ENTER_ACCEPT} (${USER})" \
  && sed -E --in-place "${PATTERN}" "${HOME}/.config/atuin/config.toml"
# @note:The bash -c is used to run a command.
[ "root" != "${USER}" ] \
  && _log "setting atuin enter_accept to ${ATUIN_ENTER_ACCEPT} (root)" \
  && sudo bash -c \
    "sed -E --in-place '${PATTERN}' /root/.config/atuin/config.toml"

# Set atuin inline height if necessary.
# @note: sed -E is used to ensure POSIX compatibility.
ATUIN_INLINE_HEIGHT=$(ini_get_value "${INI_FILE}" "atuin" "atuin_inline_height")
PATTERN="s/# inline_height = 0/inline_height = ${ATUIN_INLINE_HEIGHT}/g"
[ -f "${HOME}/.config/atuin/config.toml" ] \
  && _log "setting atuin inline_height to ${ATUIN_INLINE_HEIGHT} (${USER})" \
  && sed -E --in-place "${PATTERN}" "${HOME}/.config/atuin/config.toml"
# @note:The bash -c is used to run a command.
[ "root" != "${USER}" ] \
  && _log "setting atuin inline_height to ${ATUIN_INLINE_HEIGHT} (root)" \
  && sudo bash -c \
    "sed -E --in-place '${PATTERN}' /root/.config/atuin/config.toml"

# Attempt to login if no key file found.
if [ ! -f "~/.local/share/atuin/key" ]; then
  USERNAME=$(get_secret "ATUIN_USERNAME")
  PASSWORD=$(get_secret "ATUIN_PASSWORD")
  KEY=$(get_secret "ATUIN_KEY")
  if [ -n "${USERNAME}" ] && [ -n "${PASSWORD}" ] && [ -n "${KEY}" ]; then
    _log "logging into atuin (${USER})" \
      && atuin login --username "${USERNAME}" --password "${PASSWORD}" --key "${KEY}" \
      && atuin sync

    # @note:The bash -c is used to run a command.
    [ "root" != "${USER}" ] && \
      _log "logging into atuin (root)" \
        && sudo bash -c "/root/.atuin/bin/atuin login --username \"${USERNAME}\" --password \"${PASSWORD}\" --key \"${KEY}\"" \
        && sudo bash -c "/root/.atuin/bin/atuin sync"
  fi
fi

#-------------------------------------------------------------------------------
# Secrets processing.
# @note: We do this last as we are messing with the IFS value.

# Check for an existing secrets example file and create if necessary.
[ ! -f "${SECRETS_FILE=./.jjs105-secrets.example}" ] \
  && _log "creating example secrets file" \
  && cp /opt/jjs105/lib/.jjs105-secrets.example ./

# Make sure all expected secrets exist in the example file.
EXPECTED_SECRETS=$(ini_get_keys "${INI_FILE}" "expected-secrets")
if [ -n "${EXPECTED_SECRETS}" ]; then
  IFS=,; for secret in ${EXPECTED_SECRETS}; do
    ini_has_value "${SECRETS_FILE}" "ROOT" "${secret}" \
      || ini_set_value "${SECRETS_FILE}" "ROOT" "${secret}" ""
  done
fi
