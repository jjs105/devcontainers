#!/bin/bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Jon Spain (https://github.com/jjs105).
# Licensed under GNU GPL v3 or later
# https://github.com/jjs105/devcontainers/tree/main/LICENSE
#-------------------------------------------------------------------------------------------------------------

# Test script for the jjs105-devcontainer development container feature.

# @note: The devcontainer CLI tool assumes that the bash shell is installed on
# the image being used to test the feature. If this is not the case the use of
# that image can be wrapped in a test scenario and the following element added
# to the container specification (assuming alpine image as an example):
#   "postCreateCommand": "apk add --no-cache bash"

# Exit on any failure, use +e to revert if necessary.
# @note: -x can be used for debugging purposes.
set -eu

#-------------------------------------------------------------------------------------------------------------
# Feature options.
# @note: := substitution to ensure var=null => true.

INSTALL_LIB="${INSTALL_LIB:=false}"
ENSURE_BASH="${ENSURE_BASH:=true}"
BASH_HISTORY_PATH="${BASH_HISTORY_PATH:=}"
INSTALL_FZF="${INSTALL_FZF:=true}"
GIT_PROMPT="${GIT_PROMPT:=true}"

#-------------------------------------------------------------------------------------------------------------
# Common test script housekeeping.

# Check for an original script name - i.e. as may set when using a scenario
# based test script.
ORIGINAL_SCRIPT="${ORIGINAL_SCRIPT:=unknown-script.sh}"

# Attempt to check for mismatch against darwin (Mac) OS.
# @note: =~ search comparison is bash only (i.e. not POSIX shell).
if [[ "${ORIGINAL_SCRIPT}" =~ "darwin" && "Darwin" != $(uname -s) ]]; then
    echo -e "\n🔄 Skipping tests, not on Darwin/Mac OS."
    exit 0
elif [[ ! ${ORIGINAL_SCRIPT} =~ "darwin" && "Darwin" == $(uname -s) ]]; then
    echo -e "\n🔄 Skipping tests, on Darwin/Mac OS."
    exit 0
fi

#-------------------------------------------------------------------------------------------------------------
# Load the test library, run the checks and report.

# Source the devcontainer CLI tool test library (hence reason for bash).
source dev-container-features-test-lib

# Check the install-lib.sh library is installed or not as required.
[ "true" = "${INSTALL_LIB}" ] && \
  check "install-lib.sh found in /opt/jjs105/lib" \
    test -f /opt/jjs105/lib/install-lib.sh
[ "true" != "${INSTALL_LIB}" ] && \
  check "install-lib.sh found in /opt/jjs105/lib" \
    test ! -f /opt/jjs105/lib/install-lib.sh

# Report all test results.
reportResults
