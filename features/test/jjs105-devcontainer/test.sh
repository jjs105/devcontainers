#!/bin/bash
#-------------------------------------------------------------------------------
# Copyright (c) Jon Spain (https://github.com/jjs105).
# Licensed under GNU GPL v3 or later
# https://github.com/jjs105/devcontainers/tree/main/LICENSE
#-------------------------------------------------------------------------------

# Test script for the jjs105-devcontainer development container feature.

# @note: The devcontainer CLI tool assumes that the bash shell is installed on
# the image being used to test the feature. If this is not the case the use of
# that image can be wrapped in a test scenario and the following element added
# to the container specification (assuming alpine image as an example):
#   "postCreateCommand": "apk add --no-cache bash"

# Exit on any failure, use +e to revert if necessary.
# WARNING: The use of set -e means that the script wil exit if ANY SINGLE
# COMMAND FAILS. This means that, for correct operation, tests that may fail
# as expected behaviour need to be part of a command that actually succeeds.
# @note: -x can be used for debugging purposes.
set -eu

#-------------------------------------------------------------------------------
# Feature options.
# @note: := substitution to ensure var=null => true.

INSTALL_LIB="${INSTALL_LIB:=true}"
TEST_LIB="${TEST_LIB:=false}"
ENSURE_BASH="${ENSURE_BASH:=true}"
BASH_HISTORY_PATH="${BASH_HISTORY_PATH:=}"
INSTALL_FZF="${INSTALL_FZF:=true}"
GIT_PROMPT="${GIT_PROMPT:=true}"

#-------------------------------------------------------------------------------
# Load the test library, run the checks and report.

# Check for and source our test library.
# @note: This should have been installed as part of the jjs-devcontainer feature
# itself.

# Check for our test library, exiting if not found.
if [ ! -f "/opt/jjs105/lib/test-lib.sh" ]; then
  # @note: echo -e means interpret escaped chars, -n means no ending newline.
  echo -e "\n\n!!! Test library not found (/opt/jjs105/lib/test-lib.sh)" 1>&2 
  exit 1
fi

# Include the test library.
source /opt/jjs105/lib/test-lib.sh

#-------------------------------------------------------------------------------
# Test library testing - its part of the jjs105-devcontainer feature after all.
# @note: We define these tests in a separate script to keep things tidy.

# CURRENTLY EMPTY!!!
source test-lib-test.sh

#-------------------------------------------------------------------------------
# Check all the files that should or shouldn't exist dependent on the
# development container feature options.
# @note: The check for the test-lib.sh file is superfluous because the script
# would have already exited if it didn't exist

test_section "Check Installed Files"
[ "true" = "${INSTALL_LIB}" ] \
  && check_file_exists "/opt/jjs105/lib/install-lib.sh" \
  || check_file_absent "/opt/jjs105/lib/install-lib.sh"

[ "true" = "${TEST_LIB}" ] \
  && check_file_exists "/opt/jjs105/lib/test-lib.sh" \
  || check_file_absent "/opt/jjs105/lib/test-lib.sh"

# Check if a history path is specified, and if so that the HISTFILE environment
# variable is set, matches it and points to existing file.
test_section "Check BASH History Path"
[ -n "${BASH_HISTORY_PATH}" ] \
  && check_env_exists "HISTFILE" \
  && check_env_not_blank "HISTFILE" \
  && check_env_matches "HISTFILE" \
    "${BASH_HISTORY_PATH%\.bash_history}/.bash_history" \
  && check_file_exists "${HISTFILE}" \
  || echo "History path not configured, skipping."

# Check if fuzzy search tools(s) fzf is installed and available if configured.
test_section "Check Fuzzy Search Install"
[ "true" = "${INSTALL_FZF}" ] \
  && check_installed "/opt/jjs105/bin/fzf" "fzf --version" \
  && check_installed "fzf" "fzf --version" \
  || echo "Fuzzy search install not configured, skipping."

# Check if git-prompt is installed and used.
test_section "Check Git Prompt Install"
[ "true" = "${GIT_PROMPT}" ] \
  && check_file_exists "/opt/jjs105/lib/git-prompt.sh" \
  && check_env_function_exists "__git_ps1" \
  || echo "Git prompt install not configured, skipping."

# Report all test results.
#reportResults
test_report_passed
test_report_failed
test_report_counts

# Finish testing and return overall success/failure.
test_finish_exit
