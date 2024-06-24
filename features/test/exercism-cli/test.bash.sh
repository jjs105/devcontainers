#!/bin/bash

# Exit on any failure, use +e to revert if necessary.
# @note: -x can be used for debugging purposes.
set -eu

# Source the development containers test library (hence reason for bash).
source dev-container-features-test-lib

# Check for mismatch against darwin (Mac) OS.
if [ "alt-os-darwin" = ${ORIGINAL_SCRIPT} ] && [ "Darwin" != $(uname -s) ]; then
    echo -e "\n🔄 Skipping tests, not on Darwin/Mac OS."
    exit 0
elif [ "alt-os-darwin" != ${ORIGINAL_SCRIPT} ] && [ "Darwin" == $(uname -s) ]; then
    echo -e "\n🔄 Skipping tests, on Darwin/Mac OS."
    exit 0
fi

# Check Exercism is installed and reports its version.
check "exercism location" bash -c "ls /usr/local/bin/exercism"
check "version" bash -c "exercism version"

# Report all test results.
reportResults