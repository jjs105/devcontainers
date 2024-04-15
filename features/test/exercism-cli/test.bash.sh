#!/bin/bash

set -eu

# Source the development containers test library (hence reason for bash).
source dev-container-features-test-lib

# Check Exercism is installed and reports its version.
check "exercism location" bash -c "ls /usr/local/bin/exercism"
check "version" bash -c "exercism version"

# Report all test results.
reportResults