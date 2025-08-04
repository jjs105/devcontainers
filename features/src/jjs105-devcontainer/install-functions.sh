#-------------------------------------------------------------------------------
# Copyright (c) Jon Spain (https://github.com/jjs105).
# Licensed under GNU GPL v3 or later
# https://github.com/jjs105/devcontainers/tree/main/LICENSE
#-------------------------------------------------------------------------------

# Install script functions for the jjs105-devcontainer development container
# feature.

# @note: We assume that only the most basic POSIX shell (sh) is available to aid
# in OS compatibility etc.

#-------------------------------------------------------------------------------
_install_library_files() {
  # Function to copy all of our library files.

  local _path="/opt/jjs105/lib"
  _log "installing library files to ${_path}"
  _path_create "${_path}" && _path_writable "${_path}" || return 1
  # cp -r for recursive, -f for overwrite
  # POSIX/Alpine, cp -r (--recursive), -f (--force), chmod -R (--recursive).
  cp -r -f "./lib/." "${_path}" && chmod -R u=rwx,go=rx "${_path}"
}

#-------------------------------------------------------------------------------
_ensure_bash() {
  # Function to check for bash and install if necessary.

  # @note: command -v is similar to using type but more portable.
  [ ! $(command -v bash) ] \
    && _log "installing bash" && install_packages bash \
      || :
}

#-------------------------------------------------------------------------------
_set_history_path() {
  # Function to set the history path.
  # @note: We allow this code to run from multiple installs of the development
  # container feature - just in case the user has set different paths.
  # ${1} - the history path

  # Check for a non-blank path, striping the filename if necessary.
  [ -z "${_path:="${1%\.bash_history}"}" ] && return 0

  _log "ensuring bash history location of ${_path}"
  _path_create "${_path}" && _path_writable "${_path}" || return 1
  # POSIX/Alpine, chomd -R (--recursive).
  touch "${_path%/}/.bash_history" && chmod -R ugo+rw "${_path}"

  _log "setting user bash history location(s)"
  local _snippet="export HISTFILE=${_path%/}/.bash_history"
  # @note: echo -e means interpret escaped chars, -n means no ending newline.
  run_command_for_users "echo -e \"\n\n${_snippet}\" >> ~/.bashrc"
}

#-------------------------------------------------------------------------------
_install_git_prompt() {
  # Function to configure the Git prompt.

  # Check whether already configured in the current user's .bashrc file.
  # POSIX/Alpine, grep -q (--quiet), -s (--no-messages).
  $(grep -q -s "/opt/jjs105/lib/git-prompt.sh" ~/.bashrc) \
    && _log "git-prompt already configured, skipping" \
      && return 0 || :

  download_and_install "library" "git-prompt.sh" \
    "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh"
}

#-------------------------------------------------------------------------------
_install_fzf() {
  # Function to install fzf search and history tool.

  # Check whether already configured in the current user's .bashrc file.
  # POSIX/Alpine, grep -q (--quiet), -s (--no-messages).
  $(grep -q -s "~/.fzf.bash" ~/.bashrc) \
    && _log "fzf already installed, skipping" \
      && return 0 || :

  # @note: We download and move the file ourselves as the install script
  # hardcodes adding /bin to the install path.
  download_and_install "download-only" "fzf-install.sh" \
    "https://raw.githubusercontent.com/junegunn/fzf/refs/heads/master/install"
  install_script "${DOWNLOAD_DIR}/fzf-install.sh" "/opt/jjs105"

  _log "installing fzf for users"
  run_command_for_users "/opt/jjs105/fzf-install.sh --all"
  rm "/opt/jjs105/fzf-install.sh"
}

#-------------------------------------------------------------------------------
_install_atuin() {
  # Function to install atuin history tool.

  # Check whether already configured in the current user's .bashrc file.
  # POSIX/Alpine, grep -q (--quiet), -s (--no-messages).
  $(grep -q -s "atuin init bash" ~/.bashrc) \
    && _log "atuin already installed, skipping" \
      && return 0 || :

  # @note: We download and move the file ourselves as the install script
  # hardcodes adding /bin to the install path.
  download_and_install "script" "atuin-install.sh" "https://setup.atuin.sh"

  _log "installing atuin for users"
  run_command_for_users "/opt/jjs105/bin/atuin-install.sh"
  rm "/opt/jjs105/bin/atuin-install.sh"

  # Run a bash shell to ensure that the atuin config file is created.
  # POSIX/Alpine, bash -c (--command), -i (--interactive).
  run_command_for_users "bash -i -c :"

  # Opinionated atuin configuration.
  # POSIX/Alpine, sed -E (--extended-regexp), -i (--in-place).
  local _pattern="atuin init bash"; _flag="--disable-up-arrow"
  _pattern="s/${_pattern}/${_pattern} ${_flag}/g"
  run_command_for_users "sed -E -i '${_pattern}' ~/.bashrc"
  _pattern="s/(# |)enter_accept = .*/enter_accept = false/g"
  run_command_for_users "sed -E -i '${_pattern}' ~/.config/atuin/config.toml"
  _pattern="s/(# |)inline_height = .*/inline_height = 0/g" 
  run_command_for_users "sed -E -i '${_pattern}' ~/.config/atuin/config.toml"
}
