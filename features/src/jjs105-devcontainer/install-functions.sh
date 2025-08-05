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
_ensure_bash() {
  # Function to check for bash and install if necessary.

  # @note: command -v is similar to using type but more portable.
  # @note: bash -v (--version), returns a string which evaluates to true.
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
  local _path="${1%\.bash_history}"; [ -z "${_path}" ] && return 0

  _log "ensuring bash history location of ${_path}"
  _path_create "${_path}" && _path_writable "${_path}" || return 1
  # POSIX/Alpine, chomd -R (--recursive).
  touch "${_path%/}/.bash_history" && chmod -R ugo+rw "${_path}"

  _log "setting user bash history location(s)"
  local _snippet="export HISTFILE=${_path%/}/.bash_history"
  run_command_for_users "echo \"${_snippet}\n\" >> ~/.bashrc"
}

#-------------------------------------------------------------------------------
_install_git_prompt() {
  # Function to configure the Git prompt.

  # Check if the script has already been downloaded - i.e. by a previous install
  # of this feature - to avoid re-installation.
  [ -f "/opt/jjs105/lib/git-prompt.sh" ] \
    && _log "git-prompt already installed, skipping" \
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
  # hard-codes adding /bin to the install path.
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
  # hard-codes adding /bin to the install path.
  download_and_install "script" "atuin-install.sh" "https://setup.atuin.sh"

  _log "installing atuin for users"
  run_command_for_users "/opt/jjs105/bin/atuin-install.sh"
  rm "/opt/jjs105/bin/atuin-install.sh"

  # Run a bash shell to ensure that the atuin config file is created.
  # POSIX/Alpine, bash -c (--command), -i (--interactive).
  run_command_for_users "bash -i -c :"

  # Add the expected secrets to the INI file.
  secrets_add_expected_to_ini "ATUIN_USERNAME,ATUIN_PASSWORD,ATUIN_KEY"

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
