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

# @todo: Utilise 3rd party bash test library.

# Exit on any failure, use +e to revert if necessary.
# WARNING: The use of set -e means that the script wil exit if ANY SINGLE
# COMMAND FAILS. This means that, for correct operation, tests that may fail
# as expected behaviour need to be part of a command that actually succeeds.
# @note: -x can be used for debugging purposes.
set -eu

#-------------------------------------------------------------------------------
# Feature options.
# @note: := substitution to ensure var=null => true.

EXPECTED_SECRETS="${EXPECTED_SECRETS:=}"
SHELL_HISTORY_METHOD="${SHELL_HISTORY_METHOD:=atuin_fzf}"
BASH_HISTORY_PATH="${BASH_HISTORY_PATH:=/command-history/.bash_history}"
GIT_PROMPT="${GIT_PROMPT:=true}"

#-------------------------------------------------------------------------------
# Load the test library, run the checks and report.

# Check for and source our test library.
# @note: This should have been installed as part of the jjs-devcontainer feature
# itself.

# Check for our test library, exiting if not found.
if [ ! -f "/opt/jjs105/lib/lib-test.sh" ]; then
  # @note: echo -e means interpret escaped chars, -n means no ending newline.
  echo -e "\n\n!!! Test library not found (/opt/jjs105/lib/lib-test.sh)" 1>&2 
  exit 1
fi

# Include the test library.
source /opt/jjs105/lib/lib-test.sh

#-------------------------------------------------------------------------------
# Install library function testing.
# @note: We define these tests in a separate script to keep things tidy.

# Check for our install library, exiting if not found.
if [ ! -f "/opt/jjs105/lib/lib-install.sh" ]; then
  # @note: echo -e means interpret escaped chars, -n means no ending newline.
  echo -e "\n\n!!! Install library not found (/opt/jjs105/lib/lib-install.sh)" 1>&2 
  exit 1
fi

# Header and superfluous file exists check for completeness.
test_section "Install Library Testing"
check_file_exists "/opt/jjs105/lib/lib-install.sh"

# CURRENTLY EMPTY!!!
source test-lib-install.sh

# Create mock environment variables and test retrieval.
# Create mock secrets file variables and test retrieval.

#-------------------------------------------------------------------------------
# Test library function testing.
# @note: We define these tests in a separate script to keep things tidy.

# Header and superfluous file exists check for completeness.
test_section "Test Library Testing"
check_file_exists "/opt/jjs105/lib/lib-test.sh"

# CURRENTLY EMPTY!!!
source test-lib-test.sh

#-------------------------------------------------------------------------------
# General testing.

# @todo: Check cUrl is installed.
# @todo: Check for the INI file.
# @todo: Check for lifecycle scripts.
# @todo:@ Configure the container user and check it exists.

#-------------------------------------------------------------------------------
# Shell history configuration testing [TBC].
# @todo: Separate out into a separate file.

# @todo: If shell history is set to 'shared_file' ensure a path has been set.

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

# Check if fuzzy search tools(s) fzf ar installed and available if configured.
test_section "Check Fuzzy Search Install"
[ "fzf" = "${SHELL_HISTORY_METHOD##atuin_}" ] || \
  && check_installed "/opt/jjs105/bin/fzf" "fzf --version" \
  && check_installed "fzf" "fzf --version" \
  || echo "Fuzzy search install not required, skipping."
  
# Check if atuin history tools(s) are installed and available if configured.
test_section "Check Atuin History Install"
[ "atuin" = "${SHELL_HISTORY_METHOD%%_fzf}" ] \
  && check_installed "~/.atuin/bin/atuin" "atuin --version" \
  && check_installed "atuin" "atuin --version" \
  || echo "Atuin history install not required, skipping."

# @todo: Check atuin configuration .bashrc/disable-up-arrow - user+root
# @todo: Check atuin configuration config.toml/enter_accept - user+root
# @todo: Check atuin configuration config.toml/inline_height - user+root
# @todo: Check atuin configuration INI file/shell/shell_history_method 
# @todo: Check atuin configuration INI file/atuin/atuin_enter_accept
# @todo: Check atuin configuration INI file/atuin/atuin_inline_height
# @todo: Check logged in + history size if key file found - user+root

#-------------------------------------------------------------------------------
# Shell prompt configuration testing.

# Check if git-prompt is installed and used.
test_section "Check Git Prompt Install"
[ "true" = "${GIT_PROMPT}" ] \
  && check_file_exists "/opt/jjs105/lib/git-prompt.sh" \
  && check_env_function_exists "__git_ps1" \
  || echo "Git prompt install not configured, skipping."

#-------------------------------------------------------------------------------
# Secrets testing [TBC].
# @todo: Separate out into a separate file.

# @todo: Check for the secrets example file.
# @todo: Check that any expected secrets have been added to the INI file.

#-------------------------------------------------------------------------------
# Report all test results and finish.

#reportResults
test_report_passed
test_report_failed
test_report_counts

# Finish testing and return overall success/failure.
test_finish_exit
