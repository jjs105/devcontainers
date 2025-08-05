#-------------------------------------------------------------------------------
# Copyright (c) Jon Spain (https://github.com/jjs105).
# Licensed under GNU GPL v3 or later
# https://github.com/jjs105/devcontainers/tree/main/LICENSE
#-------------------------------------------------------------------------------

# Defines a set of functions to support secrets in the context of jjs105
# development containers.

# @note: We assume that only the most basic POSIX shell (sh) is available to aid
# in OS compatibility etc.

#-------------------------------------------------------------------------------
# Script setup etc.

# Load library only once.
[ "true" = "${_lib_secrets_loaded:-false}" ] && return 0 \
  || _lib_secrets_loaded="true"

# POSIX shell doesn't have a way to get the current script path so we need to
# have set it, defaulting to /opt/jjs105/lib.
_jjs105_lib_path="${_jjs105_lib_path:-/opt/jjs105/lib}"

# Make sure the INI library is loaded.
. "${_jjs105_lib_path}/lib-ini.sh"

#-------------------------------------------------------------------------------
secrets_add_expected_to_ini() {
  # Function to add expected secrets to the INI file.
  # ${1} - the expected secrets, commas separate list

  # Get all secrets from the passed value and loop through.
  # @note: We add a trailing comma for the processing.
  local _secrets="${1},"
  while [ -n "${_secrets}" ]; do
    local _secret="${_secrets%%,*}"; _secrets="${_secrets#*,}"
    # Add the secret to the INI file.
    ini_set_value "${INI_FILE}" "expected-secrets" "${_secret}" ""
  done
}

#-------------------------------------------------------------------------------
secrets_create_example_file() {
  # Function to create an example secrets file.

  # Create the example file.
  cp "/opt/jjs105/lib/.jjs105-secrets.example" "./.jjs105-secrets.example"

  # Get all secrets from the current value and loop through.
  # @note: We add a trailing comma for the processing.
  local _secrets="$(ini_get_keys "${INI_FILE}" "expected-secrets"),"
  while [ -n "${_secrets}" ]; do
    local _secret="${_secrets%%,*}"; _secrets="${_secrets#*,}"
    # Set the secret to blank in the example file.
    ini_set_value "./.jjs105-secrets.example" "ROOT" "${_secret}" ""
  done
}

#-------------------------------------------------------------------------------
secrets_add_to_environment() {
  # Function to add secrets to the environment.

  local _secrets_file="./.jjs105-secrets"

  # Get all secrets from the secrets file and loop through.
  # @note: We add a trailing comma for the processing.
  local _secrets="$(ini_get_keys "${_secrets_file}" "ROOT"),"
  while [ -n "${_secrets}" ]; do
    local _secret="${_secrets%%,*}"; _secrets="${_secrets#*,}"
    # Get the secret value and export to the environment.
    local _value=$(ini_get_value "${_secrets_file}" "ROOT" "${_secret}")
    export "${_secret}"="${_value}"
  done
}

#-------------------------------------------------------------------------------
secrets_get() {
  # Gets a secret either from an environment variable with the same name or a
  # file called .jjs105.secrets in the current directory.
  # ${1} - the secret name

  # Value available in environment variable trumps all.
  [ -n "${!1+1}" ] && echo "${!1}" && return 0

  # Otherwise check for a secrets file in the current directory.
  # @note: We do not need to check for a value first as ini_get_value() returns
  # blank on not found.
  # @note: This function should only be called by lifecycle scripts where the
  # current directory context should be that of the project root.
  [ -f "./.jjs105-secrets" ] \
    && ini_get_value "./.jjs105-secrets" "ROOT" "${1}" \
    && return 0

  # No secret found so return blank.
  echo ""; return 0
}
