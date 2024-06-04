# Installs the Exercism CLI tool https://github.com/exercism/cli
# Feature options:
#   - version: The version to install (defaults to latest).
#   - os: The target operating system (defaults to linux).
#   - arch: The target CPU architecture (defaults to 'x86_64').

# @note: We do not specify the shell when developing features and ensure
# compatibility by assuming use of sh.

# Exit on any failure, use +e to revert if necessary.
# @note: -x can be used for debugging purposes.
set -eu

# Feature options.
WORKSPACE=${WORKSPACE=}
TOKEN=${TOKEN=}
VERSION=${VERSION=latest}
OS=${OS=linux}
ARCH=${ARCH=x86_64}

# Include the development containers common library.
. ./devcontainers-lib.sh

# Our required packages.
echo "==>> Installing cUrl ..."
install_packages curl ca-certificates

# Set up.
DEST_DIR=/usr/local/bin
BASE_URL=https://github.com/exercism/cli
LATEST_URL=${BASE_URL}/releases/latest/

# Work out the version.
if [ -z ${VERSION} ] || [ "latest" = ${VERSION} ]; then
  VERSION=$(curl -sLI -o /dev/null -w '%{url_effective}' ${LATEST_URL})
  VERSION=$(echo "${VERSION}" | cut -d v -f 2)
fi

# Work out the URL and report.
BINARY=exercism-${VERSION}-${OS}-${ARCH}.tar.gz
RELEASE_URL=${BASE_URL}/releases/download/v${VERSION}/${BINARY}
echo "==>> Installing exercism-cli: v${VERSION}"
echo "==>> from: ${RELEASE_URL}"
echo "==>> to: ${DEST_DIR}"

# Download and install.
DOWNLOAD_DIR=$(mktemp -d || mktemp -d -t 'tmp')
curl -sfL --retry 3 ${RELEASE_URL} | tar -xz -C ${DOWNLOAD_DIR}
install ${DOWNLOAD_DIR}/exercism ${DEST_DIR}
rm -r ${DOWNLOAD_DIR}

# Configure token and/or workspace if set.
# @note: A token must be specified when configuring otherwise an error occurs.
if [ ! -z ${WORKSPACE_PATH} ]; then WORKSPACE=${WORKSPACE_PATH}; fi
if [ ! -z ${EXERCISM_TOKEN} ]; then TOKEN=${EXERCISM_TOKEN}; fi
if [ -z ${TOKEN} ]; then TOKEN=DUMMY_AUTH_TOKEN; fi

# We have a workspace so set as well as ...
if [ ! -z ${WORKSPACE} ]; then
  echo "==>> Configuring Workspace as: ${WORKSPACE}"
  echo "==>> Configuring Token as: ${TOKEN}"
  # A real or dummy token.
  if [ "DUMMY_AUTH_TOKEN" != ${TOKEN} ]; then
    exercism configure --workspace=${WORKSPACE} --token=${TOKEN}
  else
    exercism configure --workspace=${WORKSPACE} --token=${TOKEN} --no-verify
  fi
# Otherwise if a non-dummy token (only) is specified set that.
elif [ "DUMMY_AUTH_TOKEN" != ${TOKEN} ]; then
  echo "==>> Configuring Token as: ${TOKEN}"
  exercism configure --token=${TOKEN}
fi
