#!/bin/bash

# Exit on any failure, use +e to revert if necessary.
# @note: -x can be used for debugging purposes.
set -eu

# Source the development containers test library (hence reason for bash).
source dev-container-features-test-lib

# Check act is installed and reports its version.
check "act location" bash -c "ls /usr/local/bin/act"
check "version" bash -c "act --version"

# Report all test results.
reportResults