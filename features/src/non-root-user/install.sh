#!/usr/bin/env bash
#-------------------------------------------------------------------------------
# Copyright (c) Jon Spain (https://github.com/jjs105).
# Licensed under GNU GPL v3 or later.
# https://github.com/jjs105/devcontainers/tree/main/LICENSE
#-------------------------------------------------------------------------------

# Install script for the jjs105/jjs105-non-root-user development container
# feature.

# Exit on any failure or unset variable, use +eu to revert if necessary.
set -eu

# Development container feature options.
USERNAME="${USERNAME:=auto}"
USER_UID="${USER_UID:=auto}"
USER_GID="${USER_GID:=auto}"

# Trying to use root as the non-root username is an error.
[ "root" = "${USERNAME}" ] \
  && printf "error: cannot set root as non-root user, exiting\n" && exit 1 || :

# Check for and then load the minimal install library from its location in the
# container.
[ ! -f "/opt/jjs105/lib/install-lib.sh" ] \
  && printf "error: install-lib.sh not found, exiting\n" && exit 1 \
    || source "/opt/jjs105/lib/install-lib.sh"

# Check for root access.
ensure_root

#-------------------------------------------------------------------------------
# Determine the non-root user username.

# If set to automatic user and a remote user is set use it.
[ "auto" = "${USERNAME}" ] && [ "root" != "${_REMOTE_USER:-root}" ] \
  && USERNAME="${_REMOTE_USER}" || :

# If set to automatic and there is a user with ID 1000 then use it.
# grep POSIX/Alpine (bash), -s (--no-messages).
# cut POSIX/Alpine (bash), -d (--delimiter), -f (--fields).
USER_1000="$(grep -s ^[^:]*:[^:]*:1000: /etc/passwd | cut -d: -f1)"
[ "auto" = "${USERNAME}" ] && [ "" != "${USER_1000}" ] \
  && USERNAME="${USER_1000}" || :

# Default the automatic username to devcontainer.
[ "auto" = "${USERNAME}" ] && USERNAME="devc" || :

#-------------------------------------------------------------------------------
# Ensure the user exists with the correct UID and GID.
# @note: Debian/Ubuntu specific, will require update for Alpine (shadow).

# User already exists make sure UID and GID matches as necessary.
if id -u "${USERNAME}" > /dev/null 2>&1; then
  [ "${USER_UID}" != "auto" ] && [ "${USER_UID}" != "$(id -u ${USERNAME})" ] \
    && usermod --uid "${USER_UID}" "${USERNAME}" || :
  [ "${USER_GID}" != "auto" ] && [ "${USER_GID}" != "$(id -g ${USERNAME})" ] \
    && groupmod --gid "${USER_GID}" "$(id -gn ${USERNAME})" \
    && usermod --gid "${USER_GID}" "${USERNAME}" || :

# No existing user, create one (no password, bash shell, create directory) with
# correct or default IDs.
# @note: We need to create user home directory to avoid permission issues when
# any created development container is run.
else
  if [ "${USER_GID}" = "auto" ]; then
    groupadd "${USERNAME}"
  else
    groupadd --gid "${USER_GID}" "${USERNAME}"
  fi
  if [ "${USER_UID}" = "auto" ]; then
    useradd --shell /bin/bash --gid "${USERNAME}" --create-home \
      "${USERNAME}"
  else
    useradd --shell /bin/bash --gid "${USERNAME}" --create-home \
      --uid "${USER_UID}" "${USERNAME}"
  fi
fi

#-------------------------------------------------------------------------------
# Configure the user to allow use of sudo without a password.

printf "${USERNAME} ALL=(root) NOPASSWD:ALL\n" > "/etc/sudoers.d/${USERNAME}"
chmod 0440 "/etc/sudoers.d/${USERNAME}"
