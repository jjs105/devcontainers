#-------------------------------------------------------------------------------
# Copyright (c) Jon Spain (https://github.com/jjs105).
# Licensed under GNU GPL v3 or later
# https://github.com/jjs105/devcontainers/tree/main/LICENSE
#-------------------------------------------------------------------------------

# Defines (helper) functions for the implementation of development container and
# feature install scripts.

# @note: We assume that only the most basic POSIX shell (sh) is available to aid
# in OS compatibility etc.

#-------------------------------------------------------------------------------
install_packages() {
  # Function to install a list of packages.
  # @note: We do not worry about uninstalling later - i.e. to minimise
  # development container image layer sizes. If this is a hard requirement then
  # a different approach should be used.
  # ${@} - list of packages to install

  # Use apt if available.
  if [ -x "/usr/bin/apt-get" ]; then
    apt-get update --assume-yes \
    && apt-get install --assume-yes --no-install-recommends "$@" \
    && apt-get clean && apt-get autoclean && apt-get autoremove \
    && rm --recursive --force /var/lib/apt/lists/*

  # APK? (i.e. on Alpine).
  elif [ -x "/sbin/apk" ]; then
    apk add --no-cache "$@"

  # Pacman? (i.e. on Arch).
  elif [ -x "/sbin/pacman" ]; then
    pacman --noconfirm --sync --refresh "$@"

  # Otherwise not supported.
  else
    echo "Linux distro not supported."
    return 1
  fi
}

#-------------------------------------------------------------------------------
install_library() {
  # Simple install library function.
  # @note: This is implemented as the 'install' utility is not in the POSIX
  # shell specification and therefore may not be available.
  # ${1} - source file path
  # ${2} - target directory path

  # We only support installing single (library) files.
  [ ! -f "${1}" ] \
    && log "jjs105/install-lib" "install_library() expects '${1}' to be a file" \
    && return 1

  # Ensure that the target path exists copy the file and set permissions.
  log "jjs105/install-lib" "installing library ${1} -> ${2}"
  mkdir --parents "${2}" && cp "${1}" "${2}" \
    && chmod u=rw,go=r "${2}/${1##*/}"
}

#-------------------------------------------------------------------------------
install_script() {
  # Simple install script function.
  # @note: This is implemented as the 'install' utility is not in the POSIX
  # shell specification and therefore may not be available.
  # ${1} - source file path
  # ${2} - target directory path

  # We only support installing single (script) files.
  [ ! -f "${1}" ] \
    && log "jjs105/install-lib" "install_script() expects '${1}' to be a file" \
    && return 1

  # Ensure that the target path exists copy the file and set permissions.
  log "jjs105/install-lib" "installing script ${1} -> ${2}"
  mkdir --parents "${2}" && cp "${1}" "${2}" \
    && chmod u=rwx,go=rx "${2}/${1##*/}"
}

#-------------------------------------------------------------------------------
latest_git_release() {
  # Get the latest release tag from a GitHub repository.
  # ${1} - the GitHub repository in the format 'owner/repo'.

  # Get the release information from the GitHub API and extract the tag name.
  curl --silent "https://api.github.com/repos/${1}/releases/latest" \
    | grep '"tag_name":' \
    | sed --regexp-extended 's/.*"([^"]+)".*/\1/'
}

#-------------------------------------------------------------------------------
run_command_for_users() {
  # Runs a command for all users - i.e. root, _CONTAINER_USER and _REMOTE_USER
  # ${1} - the command to run

  # Run the command for root.
  log "jjs105/install-lib" "running command as root: ${1}"
  /bin/su --command "${1}" - root
  
  # Run the command for the container user if not root.
  if [ "root" != "${_CONTAINER_USER}" ]; then
    log "jjs105/install-lib" \
      "running command as _CONTAINER_USER: ${_CONTAINER_USER}: ${1}"
    /bin/su --command "${1}" - "${_CONTAINER_USER}"
  fi

  # Run the command for the remote user if not root or the container user.
  if [ "root" != "${_REMOTE_USER}" ] \
    && [ "${_CONTAINER_USER}" != "${_REMOTE_USER}" ]; then
      log "jjs105/install-lib" \
        "running command as _REMOTE_USER: ${_REMOTE_USER}: ${1}" \
      && /bin/su --command "${1}" - "${_REMOTE_USER}"
    fi
}

#-------------------------------------------------------------------------------
# Log file functionality.

# Ensure the log and directory exists and is writable.
# @note: Development container feature install scripts run as root so we don't
# need worry about permissions.
mkdir --parents /var/log/jjs105 && touch /var/log/jjs105/install-log
chmod --recursive ugo+r /var/log/jjs105

log() {
  # Simple log function.
  # ${1} - package identifier
  # ${2} - string to log

  # Log to stdout and log file (we don't assume that 'tee' is available).
  echo "===>>> ${1}: ${2}"
  echo "===>>> ${1}: ${2}" >> /var/log/jjs105/install-log
}
