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
# Script setup etc.

# Load library only once.
[ "true" = "${_lib_install_loaded:-false}" ] && return 0 \
  || _lib_install_loaded="true"

# POSIX shell doesn't have a way to get the current script path so we need to
# have set it, defaulting to /opt/jjs105/lib.
_jjs105_lib_path="${_jjs105_lib_path:-/opt/jjs105/lib}"

# Check if we should be logging and load library as necessary
[ "true" = "${_lib_install_log:=false}" ] \
  && . "${_jjs105_lib_path}/lib-log.sh" || :
_lib_install_log() {
  [ "true" = "${_lib_install_log}" ] && \
    log "lib-install" "${1}" || :
}

#-------------------------------------------------------------------------------
# Internal functions.

_error() {
  # Simple internal error function.
  # @note: Centralised to a function in case we change approach.
  # ${1} - the error message

  echo "${1}" | tee "/dev/stderr"
}

_path_readable() {
  # Internal function to check a path is readable. Reports on error.
  # ${1} - the path to check

  [ -r "${1}" ] || { _error "path is not readable (${1})" && return 1; }
}

_path_writable() {
  # Internal function to check a path is writeable. Reports on error.
  # ${1} - the path to check

  [ -w "${1}" ] || { _error "path is not writable (${1})" && return 1; }
}

_path_create() {
  # Function to create a path. Reports on error incorrect permissions assumed.
  # ${1} - the path to create

  # POSIX/Alpine, mkdir -p (--parents).
  (mkdir -p "${1}") || {
    _error "could not create path (${1})" && return 1
  }
}

_install_file() {
  # Internal function to install a file.
  # @note: This is implemented as the 'install' utility is not in the POSIX
  # shell specification and therefore may not be available.
  # ${1} - calling function name (for logging)
  # ${2} - source file path
  # ${3} - target directory path
  # ${4} - optional [new] file name

  # We only support installing single files.
  [ -f "${2}" ] || { _error "${1}() expects '${2}' to be a file" && return 1; }

  # Ensure the target path exists and is writable.
  _lib_install_log "${1}() ${2} -> ${3}${4:+/}${4:-}"
  _path_create "${3}" && _path_writable "${3}" || return 1

  # Copy the file, command options depend on whether a new name has been passed.
  # POSIX/Alpine, cp -T (--no-target-directory).
  [ -z "${4:-}" ] && cp "${2}" "${3}" || cp -T "${2}" "${3}/${4:-}"
}

#-------------------------------------------------------------------------------
install_packages() {
  # Function to install a list of packages as ROOT.
  # @note: We do not worry about uninstalling later - i.e. to minimise
  # development container image layer sizes. If this is a hard requirement then
  # a different approach should be used.
  # ${@} - list of packages to install

  # @note we use sudo for ease and compatibility. If not installed we assume
  # root permissions and add first.

  # Use apt if available.
  # POSIX/Alpine, rm -r (--recursive), -f (--force).
  if [ -x "/usr/bin/apt-get" ]; then
    [ ! -x "/usr/bin/sudo" ] && apt-get sudo --assume-yes
    _lib_install_log "installing packages using apt-get: ${@}"
    sudo apt-get update --assume-yes \
    && sudo apt-get install --assume-yes --no-install-recommends "$@" \
    && sudo apt-get clean \
    && sudo apt-get autoclean && apt-get autoremove \
    && sudo rm -r -f /var/lib/apt/lists/*

  # APK? (i.e. on Alpine).
  elif [ -x "/sbin/apk" ]; then
    [ ! -x "/usr/bin/sudo" ] && apk add sudo
    _lib_install_log "installing packages using apk: ${@}"
    sudo apk add --no-cache "$@"

  # Pacman? (i.e. on Arch).
  elif [ -x "/sbin/pacman" ]; then
    [ ! -x "/usr/bin/sudo" ] && pacman --noconfirm sudo
    _lib_install_log "installing packages using pacman: ${@}"
    sudo pacman --noconfirm --sync --refresh "$@"

  # Otherwise not supported.
  else
    _error "could not install packages: linux distro not supported."
    return 1
  fi
}

#-------------------------------------------------------------------------------
install_library() {
  # Simple install library function.
  # ${1} - source file path
  # ${2} - target directory path
  # ${3} - optional [new] file name

  # Install the file and set its permissions.
  _install_file "install_library" "${1}" "${2}" "${3-}" || return 1
  [ -z "${3:-}" ] && chmod u=rw,go=r "${2}/${1##*/}" \
    || chmod u=rw,go=r "${2}/${3}"
}

#-------------------------------------------------------------------------------
install_script() {
  # Simple install script function.
  # ${1} - source file path
  # ${2} - target directory path
  # ${3} - optional [new] file name

  # Install the file and set its permissions.
  _install_file "install_script" "${1}" "${2}" "${3-}" || return 1
  [ -z "${3:-}" ] && chmod u=rwx,go=rx "${2}/${1##*/}" \
    || chmod u=rwx,go=rx "${2}/${3}"
}

#-------------------------------------------------------------------------------
install_file_set() {
  # Internal function to install a set of files.
  # @note: This is implemented as the 'install' utility is not in the POSIX
  # shell specification and therefore may not be available.
  # ${1} - source directory path
  # ${2} - target directory path

  # Must be a directory source and target.
  [ -d "${1}" ] || { \
    _error "install_file_set() expects '${1}' to be a directory" \
    && return 1
  }
  [ -f "${2}" ] && { \
    _error "install_file_set() expects '${2}' to be a directory" \
    && return 1
  }

  # Ensure the target path exists and is writable.
  _lib_install_log "install_file_set() ${1} -> ${2}"
  _path_create "${2}" && _path_writable "${2}" || return 1

  # Copy the files.
  # POSIX/Alpine, cp -r (--recursive), -f (--force), chmod -R (--recursive).
  cp -r -f "${1}" "${2}" && chmod -R u=rwX,go=rX "${2}"
}

#-------------------------------------------------------------------------------
install_sources() {
  # Internal function to install a set of source files.
  # @note: This is implemented as the 'install' utility is not in the POSIX
  # shell specification and therefore may not be available.
  # ${1} - source directory path
  # ${2} - target directory path

  # Install the file set and then override the permissions.
  install_file_set "${1}" "${2}" && chmod -R u=rwX,go=rwX "${2}"
}

#-------------------------------------------------------------------------------
setup_downloads() {
  # Function to ensure cURL is installed and that we have a download directory.
  # @note: tmp is available to all users so no need to run as root.

  _lib_install_log "installing cURL + creating download dir"
  install_packages curl ca-certificates
  # @note: -t is used to specify a template for the temporary directory name.
  # POSIX/Alpine, mktemp -d (--directory), -t is prepend template.
  DOWNLOAD_DIR="$(mktemp -d || mktemp -d -t 'tmp')"
}

#-------------------------------------------------------------------------------
download_and_install() {
  # Function to download and install a file.
  # ${1} - the install type library|script|download-only
  # ${2} - the file name
  # ${3} - the URL to download from

  _lib_install_log "downloading ${1} ${2} from ${3}"
  curl --silent --fail --location --retry 3 "${3}" \
    --output "${DOWNLOAD_DIR}/${2}"

  # @note: We have to hard-code the paths here as the _jjs105_lib_path variable
  # points to the development container files location during install.
  case "${1}" in
    script|SCRIPT) install_script "${DOWNLOAD_DIR}/${2}" /opt/jjs105/bin;;
    library|LIBRARY) install_library "${DOWNLOAD_DIR}/${2}" /opt/jjs105/lib;;
    download-only|DOWNLOAD-ONLY) :;;
    *) _error "invalid install type: ${1}" return 1;;
  esac
}

#-------------------------------------------------------------------------------
setup_jjs105_ini() {
  # Function to ensure that the jjs105.ini file exists.

  local _ini_path="/opt/jjs105/etc"

  # Ensure the target path exists and is writable, copy the file if it doesn't
  # already exist and ensure permissions.
  _lib_install_log "ensuring ${_ini_path}/jjs105.ini is available"
  _path_create "${_ini_path}" && _path_writable "${_ini_path}" || return 1
  [ ! -f "${INI_FILE:=${_ini_path}/jjs105.ini}" ] && \
    cp "${_jjs105_lib_path}/jjs105.ini" "${_ini_path}"
  # POSIX/Alpine, chmod -R (--recursive).
  chmod -R ugo+rw "${_ini_path}"
}

#-------------------------------------------------------------------------------
latest_git_release() {
  # Get the latest release tag from a GitHub repository.
  # ${1} - the GitHub repository in the format 'owner/repo'

  # Get the release information from the GitHub API and extract the tag name.
  # POSIX/Alpine, grep -q (--quiet), sed -E (--extended-regexp).
  curl --silent "https://api.github.com/repos/${1}/releases/latest" \
    | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' \
  || { _error "could not determine git release" && return 1; }
}

#-------------------------------------------------------------------------------
append_script_to_bashrc() {
  # Function to append a script to the .bashrc file.
  # ${1} - the script to append

  # @note: We have to hard-code the path here as the _jjs105_lib_path variable
  # points to the development container files location during install.
  local _path="/opt/jjs105/lib"

  # If the script doesn't already exist in the jjs105/lib directory copy it.
  [ ! -f "${_path}/${1}" ] && install_library "./${1}" "${_path}"

  # @todo: Change echo to printf to avoid issues with escape sequences.

  # POSIX/Alpine, grep -q (--quiet), -s (--no-messages).
  local _grep="grep -q -s \"${1}\" ~/.bashrc"
  local _echo1="echo \"\n# Load ${1} script.\" >> ~/.bashrc"
  local _echo2="echo \". ${_path}/${1}\n\" >> ~/.bashrc"
  run_command_for_users "${_grep} || { ${_echo1} && ${_echo2}; }"
}

#-------------------------------------------------------------------------------
run_command_for_users() {
  # Runs a command for all users - i.e. root, current user, _CONTAINER_USER and
  # _REMOTE_USER as necessary. Uses standard POSIX shell.
  # @note: POSIX, sh -c runs a script.
  # ${1} - the command to run

  # @note: This function should only be used in a development container feature 
  # install script. When considering other lifecycle scripts an alternative
  # approach should be found.

  # Ensure sudo is installed.
  [ ! -x "/usr/bin/sudo" ] && install_packages sudo

  # Always run the command as root.
  _lib_install_log "running command as root: ${1}"
  sudo --set-home --login -- sh -c "${1}"

  # If the current user is not root then run the command for the current user.
  [ "root" != "${USER:-root}" ] \
    && _lib_install_log "command as current user: ${USER}: ${1}" \
    && sudo --user="${USER}" --set-home --login -- sh -c "${1}"

  # Run the command for the container user if not already done so.
  if [ "root" != "${_CONTAINER_USER:-root}" ] \
  && [ "${USER:-root}" != "${_CONTAINER_USER:-root}" ]; then
    _lib_install_log "command as _CONTAINER_USER: ${_CONTAINER_USER}: ${1}"

    sudo --user="${_CONTAINER_USER}" --set-home --login -- sh -c "${1}"
  fi

  # Run the command for the remote user if not already done so.
  if [ "root" != "${_REMOTE_USER:-root}" ] \
  && [ "${_CONTAINER_USER:-root}" != "${_REMOTE_USER:-root}" ] \
  && [ "${USER:-root}" != "${_REMOTE_USER:-root}" ]; then \
    _lib_install_log "command as _REMOTE_USER: ${_REMOTE_USER}: ${1}"
    sudo --user="${_REMOTE_USER}" --set-home --login -- sh -c "${1}"
  fi
}
