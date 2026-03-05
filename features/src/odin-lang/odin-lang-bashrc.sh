#!/usr/bin/env bash
#-------------------------------------------------------------------------------
# Copyright (c) Jon Spain (https://github.com/jjs105).
# Licensed under GNU GPL v3 or later
# https://github.com/jjs105/devcontainers/tree/main/LICENSE
#-------------------------------------------------------------------------------

# This script is added to the user's .bashrc file to let the user know where
# installed libraries are and/or create Odin Language Server (OLS) file.

# This file is not intended to be run as a script, although it is possible.
# Rather it should be sourced by, or appended to, a user's .bashrc file.

# Check that the jjs105 INI file exists or return.
# @note: Return without error so that bashrc continues.
[ ! -f "${INI_FILE:=/opt/jjs105/etc/jjs105.ini}" ] && return 0

# Make sure the INI library is loaded.
. "/opt/jjs105/lib/lib-ini.sh"

# Tell the user where the Odin language examples are if they exist
[ -d "/opt/jjs105/src/odin-lang-examples" ] \
  && echo "The Odin language examples can be found in /opt/jjs105/src"

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
# Create .vscode files as necessary.

# Copy our VS Code files if configured and not already present.
echo "Example VS Code configuration files can be found in /opt/jjs105/lib/vscode"
_create=$(ini_get_value "${INI_FILE}" "odin-lang" "create-vscode-config")
if truthy "${_create}"; then
  mkdir --parents ./.vscode && chmod ugo=rwX "./.vscode"
  [ ! -f "./.vscode/launch.json" ] \
    && echo "Creating VS Code launch configuration file (launch.json)" \
    && cp /opt/jjs105/lib/vscode/launch.json ./.vscode \
    && chmod ugo=rwX "./.vscode/launch.json" \
      || :
  [ ! -f "./.vscode/tasks.json" ] \
    && echo "Creating VS Code tasks configuration file (tasks.json)" \
    && cp /opt/jjs105/lib/vscode/tasks.json ./.vscode \
    && chmod ugo=rwX "./.vscode/tasks.json" \
      || :
fi

#-------------------------------------------------------------------------------
# Create OLS files as necessary.

# Copy our ols.json file if configured and not already present.
echo "Example OLS configuration files can be found in /opt/jjs105/lib/ols"
_create=$(ini_get_value "${INI_FILE}" "odin-lang" "create-ols-config")
if truthy "${_create}"; then
  [ ! -f "./ols.json" ] \
    && echo "Creating OLS configuration file (ols.json)" \
    && cp /opt/jjs105/lib/ols/ols.json ./ && chmod ugo=rwX "./ols.json" \
      || :
  [ ! -f "./odinfmt.json" ] \
    && echo "Creating OLS format file (odinfmt.json)" \
    && cp /opt/jjs105/lib/ols/odinfmt.json ./ && chmod ugo=rwX "./odinfmt.json" \
      || :
fi

#-------------------------------------------------------------------------------
# Copy the odin-build.sh script if it doesn't already exist.

[ ! -f "./odin-build.sh" ] \
  && echo "Copying odin-build.sh script" \
  && cp /opt/jjs105/bin/odin-build.sh . \
    || :
