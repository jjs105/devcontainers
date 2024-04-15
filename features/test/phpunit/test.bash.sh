#!/bin/bash

set -eu

# Source the development containers test library (hence reason for bash).
source dev-container-features-test-lib

# Check PHPUnit is installed and reports its version.
check "phpunit location" bash -c "ls /usr/local/bin/phpunit.phar"
check "version" bash -c "phpunit.phar --version"

# Report all test results.
reportResults