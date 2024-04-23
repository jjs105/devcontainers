#!/bin/sh
# @note: We use sh as a basis for this launch script as bash may not be
# installed - e.g Alpine.

# Exit on any failure, use +e to revert if necessary.
# @note: -x can be used for debugging purposes.
set -eu

# Check for bash and install if necessary (assuming Alpine/apk).
[ ! $(command -v bash) ] && apk add --no-cache bash

# Execute the main test script.
[ ! -f ./test.bash.sh ] && echo "test.bash.sh script not found!"
[ -f ./test.bash.sh ] && exec ./test.bash.sh