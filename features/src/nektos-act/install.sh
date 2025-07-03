# Installs the nektos/act tool https://github.com/nektos/act
# Feature options:
#   - version: The version/release to install (defaults to latest).
#   - install-dir: The target install directory (defaults to /usr/local/bin).
#   - debugging: "Whether to enable debug logging (defaults to false).

# @note: We do not specify the shell when developing features and ensure
# compatibility by assuming use of sh.

set -eu

# Feature options.
VERSION="${VERSION=latest}"
INSTALL_DIR="${INSTALL_DIR=/usr/local/bin}"
DEBUGGING="${DEBUGGING=false}"

# Include the development containers common library.
. ./devcontainers-lib.sh

# Make sure we have cUrl.
install_curl

# Work out the URL and report.
echo "==>> Installing nektos-act: v${VERSION}"
echo "==>> to: ${INSTALL_DIR}"
echo "==>> debugging: ${DEBUGGING}"

# Set the debugging flag.dev
[ "true" = "${DEBUGGING}" ] && DEBUG_FLAG="true"

# Download and run the install script.
curl \
  --proto '=https' \
  --tlsv1.2 \
  -sSf https://raw.githubusercontent.com/nektos/act/master/install.sh \
  | bash -s -- "${DEBUG_FLAG:+-d}" -b "${INSTALL_DIR}" "${VERSION}"
