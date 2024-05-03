#!/bin/sh

# Test scenario launch script that simply runs the main (automated) test.sh
# script.

# @note: This is required as the development containers CLI command requires a
# test script with the same name as the test scenario ID.

# Execute the main test script.
exec ./test.sh