#!/usr/bin/env bash
#-------------------------------------------------------------------------------
# Copyright (c) Jon Spain (https://github.com/jjs105).
# Licensed under GNU GPL v3 or later.
# https://github.com/jjs105/devcontainers/tree/main/LICENSE
#-------------------------------------------------------------------------------

# Minimal library containing functions for use by other development container
# feature init/bashrc scripts.

# Ensure only loaded once.
[ "true" = "${_bashrc_lib:-false}" ] && return 0 || _bashrc_lib="true"

setup_jjs105_ini() {
  # ${...} - any exemplar variables to add to the ini file.

  # If there is no jjs105.ini file in the workspace create it and add to git
  # ignore file.
  [ ! -f "./.jjs105.ini" ] && touch "./.jjs105.ini" || :
  [ ! -f "./.gitignore" ] && touch "./.gitignore" || :
  grep --quiet "/.jjs105.ini" "./.gitignore" || \
    printf "\n/.jjs105.ini\n" >> "./.gitignore"

  # Add the note regarding double quotes.
  grep --quiet "# Please ensure values" "./.jjs105.ini" || \
    printf "\n# Please ensure values are surrounded by double quotes!\n" \
      >> "./.jjs105.ini"

  # Create the exemplar lines to add to the jjs105.ini file as necessary.
  _snippet=""; for var in "${@}"; do
    grep --quiet "${var}" "./.jjs105.ini" \
      || printf -v _snippet "%s%s=\"\"\n" "${_snippet}" "${var}"
  done

  # Add the snippet to the jjs105.ini if it is not blank.
  [ -n "${_snippet}" ] && printf "\n%s" "${_snippet}" >> "./.jjs105.ini"
}
