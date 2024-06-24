#!/bin/sh

# Test scenario launch script that simply runs the main (automated) test.sh
# script.

# @note: This is required as the development containers CLI command requires a
# test script with the same name as the test scenario ID.

# Save the name of the original script.
export ORIGINAL_SCRIPT=$(basename ${0})

# Execute the main test script.
exec ./test.sh