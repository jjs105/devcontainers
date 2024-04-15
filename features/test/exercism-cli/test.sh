#!/bin/sh
# @note: We use sh as a basis for this launch script as bash may not be installed - e.g Alpine.

set -eu

# Check for bash and install if necessary (assuming Alpine/apk).
[ ! $(command -v bash) ] && apk add --no-cache bash

# Execute the main test script.
exec ./test.bash.sh