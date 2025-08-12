#-------------------------------------------------------------------------------
# Copyright (c) Jon Spain (https://github.com/jjs105).
# Licensed under GNU GPL v3 or later
# https://github.com/jjs105/devcontainers/tree/main/LICENSE
#-------------------------------------------------------------------------------

# Install script functions for the odin-lang development container feature.

# shellcheck shell=sh
# @note: We assume that only the most basic POSIX shell (sh) is available to aid
# in OS compatibility etc.

#-------------------------------------------------------------------------------
_check_not_windows() {
  # Function to check we aren't running on Windows.

  [ "windows" = "${OS}" ] \
    && _log "Windows OS not supported, exiting" && exit 1 \
    || :
}

#-------------------------------------------------------------------------------
_compile_and_configure_odin() {
  # Function to compile and configure Odin.
  
  # Check whether the Odin language is already installed.
  [ -f "/opt/jjs105/lib/odin-lang/odin" ] \
    && _log "odin language already installed, skipping compilation" \
      && return 0 || :

  # Determine the release.
  _release="${RELEASE}"; [ "latest" = "${_release}" ] \
    || _release="$(latest_git_release odin-lang/Odin)"

  # Install the pre-requisites.
  install_packages clang llvm

  # Clone the Odin language repository and checkout the correct branch.
  _log "cloning the Odin language git repository"
  git clone "https://github.com/odin-lang/Odin" "${DOWNLOAD_DIR}/odin-lang"
  cd "${DOWNLOAD_DIR}/odin-lang" || {
    _log "failed to change directory to Odin language repository"
    exit 1
  }
  { [ "latest" != "${_release}" ] \
    && _log "checking out Odin language branch ${_release}" \
    && git checkout "${_release}"; } \
    || _log "using latest version of Odin language repository"

  # Compile the Odin language.
  make release-native

  # Copy the necessary Odin language files ready to install.
  # POSIX/Alpine, cp -r (--recursive).
  mkdir "${DOWNLOAD_DIR}/odin-install" \
    && cp -r ./base ./core/ ./shared ./vendor ./odin \
      "${DOWNLOAD_DIR}/odin-install"

  # Install the files in the final location.
  install_file_set \
    "${DOWNLOAD_DIR}/odin-install/." "/opt/jjs105/lib/odin-lang"
}

#-------------------------------------------------------------------------------
_install_odin_release() {
  # Function to install an Odin language release from Git.

  # Check whether the Odin language is already installed.
  [ -f "/opt/jjs105/lib/odin-lang/odin" ] \
    && _log "odin language already installed, skipping download" \
      && return 0 || :

  # Determine the release.
  _release="${RELEASE}"; [ "latest" != "${_release}" ] \
    || _release="$(latest_git_release odin-lang/Odin)"

  # ARM64 only supported on MacOS.
  [ "arm64" = "${ARCH}" ] && [ "macos" != "${OS}" ] \
    && _log "arm64 architecture only supported on MacOS, exiting" \
    && exit 1

  # Download and extract the file.
  # @note: Extension based on OS, however we don't support windows download.
  _filename="odin-${OS}-${ARCH}-${_release}.tar.gz"
  download_and_install "download-only" "${_filename}" \
    "https://github.com/odin-lang/Odin/releases/download/${_release}/${_filename}"
  # POSIX/Alpine, tar -x(--extract), -z(--gzip), -f(--file), -C(--directory).
  tar -x -z -f "${DOWNLOAD_DIR}/${_filename}" -C "${DOWNLOAD_DIR}"

  # Install the extracted files to our library folder.
  install_file_set \
    "${DOWNLOAD_DIR}/${_filename%\.tar\.gz}/." "/opt/jjs105/lib/odin-lang"
}

#-------------------------------------------------------------------------------
_install_odin_examples() {
  # Function to install the Odin language examples.

  # Check whether the Odin language is already installed.
  [ -d /opt/jjs105/src/odin-lang-examples ] \
    && _log "odin language examples already installed, skipping download" \
      && return 0 || :

  # Download and extract the examples.
  _filename="odin-examples.tar.gz"
  download_and_install "download-only" "${_filename}" \
    "https://api.github.com/repos/odin-lang/examples/tarball/master"
  # POSIX/Alpine, tar -x(--extract), -z(--gzip), -f(--file), -C(--directory).
  tar -x -z -f "${DOWNLOAD_DIR}/${_filename}" -C "${DOWNLOAD_DIR}"

  # Rename the extracted folder.
  mv "${DOWNLOAD_DIR}"/odin-lang-examples-* "${DOWNLOAD_DIR}/odin-lang-examples"

  # Install the extracted files as sources.
  install_sources \
    "${DOWNLOAD_DIR}/odin-lang-examples/." \
      "/opt/jjs105/src/odin-lang-examples"
}
