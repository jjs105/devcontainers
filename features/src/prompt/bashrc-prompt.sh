#!/usr/bin/env bash
#-------------------------------------------------------------------------------
# Copyright (c) Jon Spain (https://github.com/jjs105).
# Licensed under GNU GPL v3 or later.
# https://github.com/jjs105/devcontainers/tree/main/LICENSE
#-------------------------------------------------------------------------------

# This script provides logic and functionality to be added to a user's .bashrc
# or global /etc/bash.bashrc file by the jjs105/prompt development container
# feature.

# Set OS info string based on lsb_release or direct from release file.
# @note: The Git prompt script documentation adds this command call to the
# prompt string however it should never change so we do it now.
# @note: :+ substitution to check for final RELEASE=null.
# @note: command -v is similar to using type but more portable.
# cut POSIX/Alpine (bash), -d (--delimiter), -f (--fields).
[ -f "/etc/os-release" ] \
  && RELEASE=" $(cat /etc/os-release | grep ^ID= | cut -d = -f 2)"
# @note: lsb_release, returns a string which evaluates to true.
[ "$(command -v lsb_release)" ] \
  && RELEASE=" $(lsb_release --id --short | tr '[:upper:]' '[:lower:]')"
RELEASE="${RELEASE:+\033[35m}${RELEASE-}${RELEASE:+\033[0m}"

# Build the base prompt string.
PS1="\033[32m\u@\h\033[0m${RELEASE} \033[33m\w\033[0m"

# Add Git information if script installed.
if [ -f "/opt/jjs105/lib/git-prompt.sh" ]; then
  source "/opt/jjs105/lib/git-prompt.sh"
  PS1="${PS1}\033[36m\$(__git_ps1)\033[0m"
fi

# Set # or $ as prompt end.
# id POSIX/Alpine (bash), -u (--user).
[ "$(id -u)" = "0" ] && PS1="${PS1}\n# "
[ "$(id -u)" = "0" ] || PS1="${PS1}\n\$ "

# Export the prompt.
export PS1
