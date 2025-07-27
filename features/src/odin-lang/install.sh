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
set -eux

#-------------------------------------------------------------------------------
# Feature options.
# @note: := substitution to ensure var=null => true.

RELEASE="${RELEASE:=latest}"
OS="${OS:=linux}"
ARCH="${ARCH:=amd64}"
COMPILE="${COMPILE:=false}"
EXAMPLES="${EXAMPLES:=true}"
EXAMPLES_PATH="${EXAMPLES_PATH:=/opt/jjs105/src/}"
OLS_CREATE_CONFIG="${OLS_CREATE_CONFIG:=true}"
OLS_CREATE_FORMAT="${OLS_CREATE_FORMAT:=true}"

#-------------------------------------------------------------------------------
# Library inclusion and copy + required script setup.

# Include the install-lib.sh library from its install location.
. /opt/jjs105/lib/install-lib.sh

# Ensure logs are configured and set up our simplified log function.
_log() { log "jjs105/odin-lang" "${1}"; }
log_setup

# We don't actually support windows download.
[ "windows" = "${OS}" ] \
  && _log "Windows OS not supported, exiting" \
  && exit 1

# We will always need a download directory, so create it now.
_log "creating download dir"
# @note: -t is used to specify a template for the temporary directory name.
DOWNLOAD_DIR="$(mktemp --directory || mktemp --directory -t 'tmp')"

# If necessary install cURL and ensure we have a download directory.
if [ "true" != "${COMPILE}" ]; then
  _log "installing cURL"
  install_packages curl ca-certificates
fi

# Ensure that we have a general jjs105 INI file.
ensure_jjs105_ini

#-------------------------------------------------------------------------------
# Odin pre-requisites installation.

install_packages clang

#-------------------------------------------------------------------------------
# Not compiling Odin so download and use specified release.

if [ "true" != "${COMPILE}" ]; then

  _log "determining odin-lang download: ${RELEASE}, OS: ${OS}, ARCH: ${ARCH}"
  [ "latest" != "${RELEASE}" ] || RELEASE="$(latest_git_release odin-lang/Odin)"

  # arm64 only supported on MacOS.
  [ "arm64" = "${ARCH}" ] && [ "macos" != "${OS}" ] \
    && _log "arm64 architecture only supported on MacOS, exiting" \
    && exit 1

  # Extension based on OS, however we don't support windows download.
  [ "windows" = "${OS}" ] && EXTENSION="zip" || EXTENSION="tar.gz"

  FILENAME="odin-${OS}-${ARCH}-${RELEASE}.${EXTENSION}"
  URL="https://github.com/odin-lang/Odin/releases/download/${RELEASE}/${FILENAME}"

  _log "downloading odin-lang from ${URL}"
  curl --silent --fail --location --retry 3 "${URL}" \
    --output "${DOWNLOAD_DIR}/${FILENAME}"
  tar --extract --gzip --file="${DOWNLOAD_DIR}/${FILENAME}" \
    --directory="${DOWNLOAD_DIR}"

  # @todo: Use folder based lib function (to be created) instead of cp.
  cp --recursive "${DOWNLOAD_DIR}/odin-${OS}-${ARCH}-${RELEASE}" \
    /opt/jjs105/lib/odin-lang
  chmod --recursive u+rw,go+r /opt/jjs105/lib/odin-lang
fi

#-------------------------------------------------------------------------------
# Compiling Odin so clone from Git configure and compile.

if [ "true" = "${COMPILE}" ]; then

  # Not yest supported.
  _log "compiling Odin is not yet supported by this feature, exiting"  
  exit 1

  # Install the pre-requisites.
  # Clone the Odin repository.
  # Check for and checkout a release branch if specified.
  # Compile Odin.
  # Install the compiled Odin to the lib directory.
  # Uninstall the pre-requisites.
fi

#-------------------------------------------------------------------------------
# Odin configuration.

# Symlink Odin to standard location.
ln --symbolic /opt/jjs105/lib/odin-lang/odin /usr/local/bin/

#-------------------------------------------------------------------------------
# Add packages as necessary.

if [ "true" = "${EXAMPLES}" ]; then

  URL="https://api.github.com/repos/odin-lang/examples/tarball/master"
  FILENAME="odin-examples.tar.gz"

  _log "downloading odin-lang examples"
  curl --silent --fail --location --retry 3 "${URL}" \
    --output "${DOWNLOAD_DIR}/${FILENAME}"
    
  mkdir --parents "${EXAMPLES_PATH}"
  tar --extract --gzip --file="${DOWNLOAD_DIR}/${FILENAME}" \
    --directory="${EXAMPLES_PATH}"

  chmod --recursive ugo+rw "${EXAMPLES_PATH}"

  # Add the examples message to the bashrc file.
  if [ ! $(grep -q "Odin examples" "~/.bashrc") ]; then
    _log "adding Odin examples message to ~/.bashrc"
    SNIPPET="echo \"Odin examples can be found in ${EXAMPLES_PATH}.\""
    # @note: echo -e means interpret escaped chars, -n means no ending newline.
    run_command_for_users "echo -e \"\n\n${SNIPPET}\" >> ~/.bashrc"
  fi
fi

#-------------------------------------------------------------------------------
# Odin Language Server (OLS) configuration.

# Copy the OLS script and files so they can be used later in the lifecycle.
_log "copying OLS configuration files"
install_script ./ols/odin-ols-config.sh /opt/jjs105/bin
install_library ./ols/ols.json /opt/jjs105/lib/ols
install_library ./ols/odinfmt.json /opt/jjs105/lib/ols

# Set the OLS configuration in the jjs105 INI file.
ini_set_value "${INI_FILE}" "odin-lang" \
  "create-ols-config" "${OLS_CREATE_CONFIG}"
ini_set_value "${INI_FILE}" "odin-lang" \
  "create-ols-format" "${OLS_CREATE_FORMAT}"

#-------------------------------------------------------------------------------
# Script cleanup etc.

# Remove the download directory if created.
[ -n "${DOWNLOAD_DIR}" ] \
  && _log "removing download dir" \
  && rm --recursive "${DOWNLOAD_DIR}"
