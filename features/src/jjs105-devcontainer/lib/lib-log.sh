#-------------------------------------------------------------------------------
# Copyright (c) Jon Spain (https://github.com/jjs105).
# Licensed under GNU GPL v3 or later
# https://github.com/jjs105/devcontainers/tree/main/LICENSE
#-------------------------------------------------------------------------------

# Defines a set of functions to support logging in the context of jjs105
# development containers.

# @note: We assume that only the most basic POSIX shell (sh) is available to aid
# in OS compatibility etc.

#-------------------------------------------------------------------------------
# Script setup etc.

# Load library only once.
[ "true" = "${_lib_log_loaded:-false}" ] && return 0 \
  || _lib_log_loaded="true"

_error() {
  # Simple internal error function.
  # @note: Centralised to a function in case we change approach.
  # ${1} - the error message

  echo "${1}" | tee "/dev/stderr"
}

# Create the log file and set permissions (as root).
# POSIX/Alpine, su -c for command, chmod -R (--recursive), mkdir -p (--parents).
su -c "mkdir -p /var/log/jjs105" - "root" \
  && su -c "touch /var/log/jjs105/install-log" - "root" \
  && su -c "chmod -R ugo+rw /var/log/jjs105" - "root"  \
  || { _error "could not create log dir" && return 1; }

#-------------------------------------------------------------------------------
log() {
  # Simple log function.
  # ${1} - the package identifier
  # ${2} - the string to log

  # Log to stdout and log file (we don't assume that 'tee' is available).
  echo "===>>> ${1}: ${2}"
  echo "===>>> ${1}: ${2}" >> /var/log/jjs105/install-log
}

#-------------------------------------------------------------------------------
show_context() {
  # Shows the current context.
  # ${1} - the heading to display

  [ -n "${1:-}" ] && echo "${1}" || :

  # @note: echo -e means interpret escaped chars, -n means no ending newline.
  # @note: ls -l means long format, -a means show all files.
  echo -n "user: " && whoami
  echo "environment: " && printenv
  echo -n "current dir: " && pwd && ls -l -a
  echo "root dir: " &&  ls -l -a /
  [ -d "/workspaces" ] && echo "workspaces dir: " && ls -l -a /workspaces || :
}

#-------------------------------------------------------------------------------
log_context() {
  # Run the context function adding to the log file.
  # ${1} - the package identifier

  echo "===>>> ${1}: context"; show_context
  echo "===>>> ${1}: context" >> /var/log/jjs105/install-log
  show_context >> /var/log/jjs105/install-log
}
