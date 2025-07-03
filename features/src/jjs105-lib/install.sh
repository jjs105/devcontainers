# Ensures that Bash is installed, along with installing a useful command prompt.

# @note: We do not specify the shell when developing features and ensure
# compatibility by assuming use of sh.

# Exit on any failure, use +e to revert if necessary.
# @note: -x can be used for debugging purposes.
set -ex

# Feature options.
GIT_PROMPT="${GIT_PROMPT=true}"

# Include the development containers common library.
. ./devcontainers-lib.sh

# Check for bash and install if necessary.
[ ! $(command -v bash) ] \
  && echo "==>> Installing Bash ..." \
  && install_packages bash

# Install the Git prompt script if necessary.
if [ "true" = "${GIT_PROMPT}" ]; then
  
  # Download and install.
  SCRIPT_URL="https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh"
  echo "==>> Installing the Git prompt script ..."
  download_and_install "${SCRIPT_URL}" "/usr/local/lib"
fi
