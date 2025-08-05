#-------------------------------------------------------------------------------
# Copyright (c) Jon Spain (https://github.com/jjs105).
# Licensed under GNU GPL v3 or later
# https://github.com/jjs105/devcontainers/tree/main/LICENSE
#-------------------------------------------------------------------------------

# This script provides logic and functionality to be added to the user's .bashrc
# file by the jjs105-devcontainer development container feature.

# This file is not intended to be run as a script, although it is possible.
# Rather it should be sourced by, or appended to, a user's .bashrc file.

#-------------------------------------------------------------------------------
# Update the prompt

# Set OS info string based on lsb_release or direct from release file.
# @note: The Git prompt script documentation adds this command call to the
# prompt string however it should never change so we do it now.
# @note: :+ substitution to check for final RELEASE=null.
# @note: command -v is similar to using type but more portable.
# POSIX/Alpine, cut -d (--delimiter), -f (--fields)
[ -f "/etc/os-release" ] && \
  RELEASE=" $(cat /etc/os-release | grep ^ID= | cut -d = -f 2)"
# @note: lsb_release, returns a string which evaluates to true.
[ $(command -v lsb_release) ] && \
  RELEASE=" $(lsb_release --id --short | tr '[:upper:]' '[:lower:]')"
RELEASE="${RELEASE:+\033[35m}${RELEASE-}${RELEASE:+\033[0m}"

# Build the base prompt string.
PS1="\033[32m\u@\h\033[0m${RELEASE} \033[33m\w\033[0m"

# Add Git information if script installed.
if [ -f "/opt/jjs105/lib/git-prompt.sh" ]; then
  . "/opt/jjs105/lib/git-prompt.sh"
  PS1="${PS1}\033[36m\$(__git_ps1)\033[0m"
fi

# Set # or $ as prompt end.
# POSIX/Alpine, id -u (--user).
[ "$(id -u)" = "0" ] && PS1="${PS1}\n# "
[ "$(id -u)" = "0" ] || PS1="${PS1}\n\$ "

# Export the prompt.
export PS1

#-------------------------------------------------------------------------------
# Secrets processing.

# Load the secrets library.
. "/opt/jjs105/lib/lib-secrets.sh"

# Only care if there is an INI file and there are expected secrets.
# @note: grep check does not need [].
# POSIX/Alpine, grep -q (--quiet).
if [ -f "${INI_FILE:=/opt/jjs105/etc/jjs105.ini}" ] \
&& { grep -q "\[expected-secrets\]" "${INI_FILE}"; }; then

  # If there is no secrets example file then create the example file.
  [ ! -f "./.jjs105-secrets.example" ] && secrets_create_example_file || :

  # If there is a secrets file then add the secrets to environment variables.
  [ -f "./.jjs105-secrets" ] && secrets_add_to_environment || :
fi

#-------------------------------------------------------------------------------
# Login into atuin if not already logged in.

# POSIX/Alpine, grep -q (--quiet), -v (--invert-match).
if [ -x ~/.atuin/bin/atuin ] \
&& ! { ~/.atuin/bin/atuin status | grep -q "Username"; }; then
  USERNAME=$(secrets_get "ATUIN_USERNAME")
  PASSWORD=$(secrets_get "ATUIN_PASSWORD")
  KEY=$(secrets_get "ATUIN_KEY")
  if [ -n "${USERNAME}" ] && [ -n "${PASSWORD}" ] && [ -n "${KEY}" ]; then
    ~/.atuin/bin/atuin login \
      --username "${USERNAME}" --password "${PASSWORD}" --key "${KEY}"
    ~/.atuin/bin/atuin sync
  fi
fi  
