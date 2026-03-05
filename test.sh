#!/usr/bin/env bash

#set -eux

_jjs105_lib_path=/workspace/features/src/jjs105-devcontainer/lib/
_lib_install_log=true

. "${_jjs105_lib_path}/lib-install.sh"
. "${_jjs105_lib_path}/lib-install.sh"
. "${_jjs105_lib_path}/lib-install.sh"

#setup_downloads
#setup_jjs105_ini

run_command_for_users "whoami"
run_command_for_users "pwd"
run_command_for_users "cd /var/log && pwd"
run_command_for_users 'cd /var/log && echo "${HOME}"'
run_command_for_users "cd /var/log && cd ~ && pwd"