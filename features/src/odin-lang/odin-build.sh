#!/usr/bin/env bash
#-------------------------------------------------------------------------------
# Copyright (c) Jon Spain (https://github.com/jjs105).
# Licensed under GNU GPL v3 or later
# https://github.com/jjs105/devcontainers/tree/main/LICENSE
#-------------------------------------------------------------------------------

# Generic build script for the Odin language.

# Exit on any failure, use +e to revert if necessary.
# WARNING: The use of set -e means that the script wil exit if ANY SINGLE
# COMMAND FAILS. This means that, for correct operation, tests that may fail
# as expected behaviour need to be part of a command that actually succeeds.
# @note: -x can be used for debugging purposes.
set -eu

#-------------------------------------------------------------------------------
# The usage string.

_usage=$(cat << EOF
Generic build script for the Odin language compiler.
Usage:
  odin-build.sh \\
    [-rdR] [-o level] \\
    [ -S | [-n name] [-p path] ] \\
    -T|<src> \\
    [-- odin-options]

Odin command options:
  -r          Use the Odin run command instead of build

Execution context options:
  -f          Build using the Odin -file context
  -S          Get the source path from ENV_ODB_SOURCE environment variable 

Target options:
  -d          Debug build
  -R          Release build
  -o level    Optimization level, none|minimal|size|speed, (default minimal)

Output options:
  -n name     The output name, defaults to output.bin
  -p path     The output path, defaults to /build under the working path
  -T          Get the full output path from ENV_ODB_TARGET environment variable 

Other options:
  -v          Displays the Odin version
  -h          Display this help message
EOF
)

#-------------------------------------------------------------------------------
# Flags used for release target build.

_release_flags=(
  "-strict-style"
  "-vet"
  "-vet-cast"
  "-vet-semicolon"
  "-vet-shadowing"
  "-vet-style"
  "-vet-unused"
  "-vet-unused"
  "-vet-using-param"
  "-vet-using-stmt"
  "-warnings-as-errors"
)

#-------------------------------------------------------------------------------
# Option parsing.

# Defaults.
_flags=()
_command="build"
_source=""
_op_level="minimal"
_set_name_or_path="false"
_name="output.bin"
_path="./build"
_target=""

# Loop through the options.
while getopts ":rfSdRo:n:p:Tvh" opt; do
  case "${opt}" in

    "r") _command="run";;

    "f") _flags+=("-file");;
    "S") [ -n "${ENV_ODB_SOURCE:-}" ] && _source="${ENV_ODB_SOURCE}" \
          || { echo "ENV_ODB_SOURCE must be set when using -S"; exit 1; }
         ;;

    "d") _flags+=("-debug");;
    "o") _op_level="${OPTARG}";;
    "R") _flags=("${_flags[@]}" "${_release_flags[@]}")
         _op_level="speed"
         ;;

    "n") _name="${OPTARG}"; _set_name_or_path="true";;
    "p") _path="${OPTARG}"; _set_name_or_path="true";;
    "T") [ -n "${ENV_ODB_TARGET:-}" ] && _target="${ENV_ODB_TARGET}" \
          || { echo "ENV_ODB_TARGET must be set when using -T"; exit 1; }
         ;;

    "v") odin version; exit 0;;
    "h") echo "${_usage}"; exit 0;;

    "?") echo "Unknown option: -${OPTARG}"; echo "${_usage}"; exit 1;;
    ":") echo "Missing value for option: -${OPTARG}"; echo "${_usage}"; exit 1;;
  esac
done; shift $((OPTIND - 1))

# Can't use -S and pass a source path.
[ -n "${_source}" ] && [ -n "${1:-}" ] && [ "--" != "${1:-}" ] \
  && echo "Can't use -S and pass a source path" && echo "${_usage}" \
    && exit 1 || :
    
# Can't use -T with -n or -p
[ -n "${_target}" ] && [ "true" = "${_set_name_or_path}" ] \
  && echo "Can't use -T with -n or -p" && echo "${_usage}" \
    && exit 1 || :

#-------------------------------------------------------------------------------
# Check for a first argument which is our src path.

{ [ -z "${_source:=${1:-}}" ] \
  && echo "Missing source path <src>" && echo "${_usage}" \
    && exit 1; } || { [ -n "${1:-}" ] && shift; }

#-------------------------------------------------------------------------------
# There should be no other arguments UNLESS -- is passed. If it is we pass all
# arguments following it directly to the odin command.

[ -n "${1:-}" ] && [ "--" != "${1:-}" ] \
  && echo "Please use -- to indicate options to pass to Odin command" \
    && echo "${_usage}" \
      && exit 1 || :

[ "--" = "${1:-}" ] && shift || :

#-------------------------------------------------------------------------------
# Build the command and run.

set -- \
  "odin" \
  "${_command}" \
  "${_source}" \
  "-out:${_target:-${_path}/${_name}}" \
  "-o:${_op_level}" \
  "${_flags[@]}" \
  "$@"

exec "${@}"
