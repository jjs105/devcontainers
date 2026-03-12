#!/usr/bin/env bash
#-------------------------------------------------------------------------------
# Copyright (c) Jon Spain (https://github.com/jjs105).
# Licensed under GNU GPL v3 or later.
# https://github.com/jjs105/devcontainers/tree/main/LICENSE
#-------------------------------------------------------------------------------

# Install script for the jjs105/shell-history development container feature.

# Exit on any failure or unset variable, use +eu to revert if necessary.
set -eux

# Development container feature options.
METHOD="${METHOD:=shared_file}"
SHARED_PATH="${SHARED_PATH:=/command-history/.bash_history}"

# Check for and then load the minimal install library from its location in the
# container.
[ ! -f "/opt/jjs105/lib/install-lib.sh" ] \
  && printf "error: install-lib.sh not found, exiting\n" && exit 1 \
    || source "/opt/jjs105/lib/install-lib.sh"

# Check for root access.
ensure_root

#-------------------------------------------------------------------------------
# If set setup the shared path method.

if [ "shared_file" = "${METHOD}" ]; then

  # Check for a non-blank path, striping the filename if necessary.
  _path="${SHARED_PATH%\.bash_history}"
  [ -z "${_path}" ] \
    && printf "error: blank shared file path found, exiting\n" && exit 1 \
      || :

  # Ensure the path exists and create a history file placeholder.
  # POSIX/Alpine, mkdir -p (--parents).
  (mkdir -p "${_path}") \
  && touch "${_path%/}/.bash_history" \
  && chmod -R ugo+rw "${_path}" \
    || { printf "error: could not create shared file path, exiting\n" && exit 1; }  

  # Export the shared file path from appropriate .bashrc files.
  append_bashrc \
    "# Set jjs105/shell-history shared file path." \
    "export HISTFILE=${_path%/}/.bash_history"
fi

#-------------------------------------------------------------------------------
# Install fuzzy search (fzf) if necessary.
# @note: Installs against an individual user so won't affect user skeleton.

if [ "fzf" = "${METHOD##atuin_}" ]; then

  # Download the install script if not already.
  if [ ! -f "/opt/jjs105/bin/install-fzf.sh" ]; then
    download_and_install \
      "https://raw.githubusercontent.com/junegunn/fzf/refs/heads/master/install" \
      "/opt/jjs105/bin" \
      "u=rwx,go=rx" \
      "install-fzf.sh"
  fi

  _install_fzf() {
    # ${1} - the user to install fzf as/for.

    # Get home directory and check for existing installation.
    # grep POSIX/Alpine (bash), -q (--quiet), -s (--no-messages).
    _home="$(run_user_command "${1}" "cd ~; pwd")"
    grep -q -s "/.fzf.bash" "${_home}/.bashrc" && return 0 || :

    # Install.
    run_user_command "${1}" "/opt/jjs105/bin/install-fzf.sh --all"
  }

  # Run the install script for all users as necessary.
  _install_fzf "root"
  [ "root" != "${_REMOTE_USER:-root}" ] \
    && _install_fzf "${_REMOTE_USER}" || :
fi

#-------------------------------------------------------------------------------
# Install atuin if necessary.
# @note: Installs against an individual user so won't affect user skeleton.

if [ "atuin" = "${METHOD%%_fzf}" ]; then

  # Download the install script if not already.
  if [ ! -f "/opt/jjs105/bin/install-atuin.sh" ]; then
    download_and_install \
      "https://setup.atuin.sh" \
      "/opt/jjs105/bin" \
      "u=rwx,go=rx" \
      "install-atuin.sh"
    fi

  # Install the bespoke atuin script from the feature.
  install_with_permissions \
    "${PWD}/bashrc-atuin.sh" "/opt/jjs105/lib" "u=rw,go=r"

  _install_atuin() {
    # ${1} - the user to install atuin as/for.

    # Get home directory and check for existing installation.
    # grep POSIX/Alpine (bash), -q (--quiet), -s (--no-messages).
    _home="$(run_user_command "${1}" "cd ~; pwd")"
    grep -q -s "atuin init bash" "${_home}/.bashrc" && return 0 || :

    # Install and run bash to create config files.
    run_user_command "${1}" "/opt/jjs105/bin/install-atuin.sh --non-interactive"
    run_user_command "${1}" "bash -i -c :"

    # Opinionated configuration settings.
    sed --regexp-extended --in-place \
      's/atuin init bash/atuin init bash --disable-up-arrow/g' \
      "${_home}/.bashrc"
    sed --regexp-extended --in-place \
      's/(# |)enter_accept = .*/enter_accept = false/g' \
      "${_home}/.config/atuin/config.toml"
    sed --regexp-extended --in-place \
      's/(# |)inline_height = .*/inline_height = 0/g' \
      "${_home}/.config/atuin/config.toml"
  }

  # Run the install script for all users as necessary.
  _install_atuin "root"
  [ "root" != "${_REMOTE_USER:-root}" ] \
    && _install_atuin "${_REMOTE_USER:-root}" || :

  # Source the bespoke atuin script from appropriate .bashrc files.
  append_bashrc \
    "# Load jjs105/bashrc-atuin script." \
    "source /opt/jjs105/lib/bashrc-atuin.sh"
fi
