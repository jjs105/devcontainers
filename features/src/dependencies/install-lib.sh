#!/usr/bin/env bash
#-------------------------------------------------------------------------------
# Copyright (c) Jon Spain (https://github.com/jjs105).
# Licensed under GNU GPL v3 or later.
# https://github.com/jjs105/devcontainers/tree/main/LICENSE
#-------------------------------------------------------------------------------

# Minimal install library containing functions for use by other development
# container feature install scripts.

# Exit on any failure or unset variable, use +eu to revert if necessary.
set -eu

# Ensure only loaded once.
[ "true" = "${_install_lib:-false}" ] && return 0 || _install_lib="true"

#-------------------------------------------------------------------------------
# General functions.

ensure_root() {
  [ "$(id -u)" != 0 ] \
    && printf "error: not running as root, exiting\n" && exit 1 || return 0
}

#-------------------------------------------------------------------------------
# apt-get specific functions.

_ensure_apt() {
  [ ! -x "/usr/bin/apt-get" ] \
    && printf "error: apt-get not found, exiting\n" && exit 1 || return 0
}

_apt_update() {
  apt-get update --assume-yes
}

_apt_cleanup () {
  apt-get clean --assume-yes
  apt-get autoclean --assume-yes
  apt-get autoremove --assume-yes
  rm -r -f /var/lib/apt/lists/*
}

update_os() {
  ensure_root
  _ensure_apt
  _apt_update
  apt-get upgrade --assume-yes --no-install-recommends
  _apt_cleanup
}

#-------------------------------------------------------------------------------
# Install and download functions.

install_packages() {
  # @note: Debian/Ubuntu specific, will require update for Alpine, Darwin etc.
  # ${...} - packages to install.
  ensure_root
  _ensure_apt
  _apt_update
  apt-get install --assume-yes --no-install-recommends "${@}"
  _apt_cleanup
}

_ensure_curl() {
  [ ! -x "/usr/bin/curl" ] \
    && printf "error: cURL not found, exiting\n" \
    && exit 1 || return 0
}

download() {
  # ${1} - the URL to download from.
  # ${2} - the path to save to.
  _ensure_curl
  curl --silent --fail --location --retry 3 "${1}" --output "${2}"
}

install_with_permissions() {
  # ${1} - the source file path to install.
  # ${2} - the directory path to install to.
  # ${3} - permissions to apply.
  # install, -D create all path components except last, -t target directory.
  install -Dt "${2%/}" "${1}"
  chmod "${3}" "${2}/$(basename "${1}")"
}

download_and_install() {
  # ${1} - the URL to download from.
  # ${2} - the path to save to.
  # ${3} - permissions to apply.
  # ${4} - optional file name to use for installation.
  _filename="${4:-$(basename "${1}")}"
  download "${1}" "/tmp/${_filename}"
  install_with_permissions "/tmp/${_filename}" "${2}" "${3}"
}

#-------------------------------------------------------------------------------
# User orientated functions.

_append_bashrc_file() {
  # ${1} - the file path to append.
  # ${2} - the comment line to append.
  # ${3} - the code to append.
  [ ! -f "${1}" ] && return 0 || :
  # grep POSIX/Alpine (bash), -q (--quiet), -s (--no-messages).
  grep -q -s "${2}" "${1}" && return 0 || :
  printf "\n${2}\n${3}\n" >> "${1}"
}

append_bashrc() {
  # ${1} - the comment line to append.
  # ${2} - the code to append.
  _append_bashrc_file "/root/.bashrc" "${1}" "${2}"
  _append_bashrc_file "/etc/skel/.bashrc" "${1}" "${2}"
  [ "root" = "${_REMOTE_USER:-root}" ] && return 0 || :
  _append_bashrc_file "/home/${_REMOTE_USER}/.bashrc" "${1}" "${2}"
}

run_user_command() {
  # ${1} - the user to run the command as/for.
  # ${2} - the command to run.
  sudo --user="${1}" --set-home --login -- sh -c "${2}"
}
