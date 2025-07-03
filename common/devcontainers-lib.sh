# Library containing functions useful when developing development containers, 
# templates and features. Heavily based on the library_scripts.sh library used
# by many of the official, or community supported, dev container features found
# at the following URL: https://containers.dev/features.

# @note: We do not specify the shell when developing and ensure compatibility by
# assuming use of sh.

os_id() {
  # Function to get the simple OS identifier.
  echo "$(cat /etc/os-release | grep ^ID= | cut -d = -f 2)" && return 0
}

install_packages() {
  # Function to install a list of packages.
  # @note: We do not worry about uninstalling later - i.e. to minimise
  # container image layer sizes. If this is a hard requirement then a
  # different approach should be used.
  # ${@} - list of packages to install

  # Use apt if available.
  if [ -x "/usr/bin/apt-get" ]; then
    apt-get update --assume-yes \
    && apt-get install --assume-yes --no-install-recommends "$@" \
    && apt-get clean && apt-get autoclean && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

  # APK? (i.e. on Alpine).
  elif [ -x "/sbin/apk" ]; then
    apk add --no-cache "$@"

  # Pacman? (i.e. on Arch).
  elif [ -x "/sbin/pacman" ]; then
    pacman --noconfirm -Sy "$@"

  # Otherwise not supported.
  else
    echo "Linux distro not supported."
    exit 1
  fi
}

install_curl() {
  # Function to install cUrl and CA-certificates packages.
  # @note: For some reason the latest version of cURL breaks OPENSSL on Arch,
  # but the versions installed by default are fine.
  if [ "arch" = "$(os_id)" ]; then
    echo "==>> Skipping cUrl installation on Arch Linux ..."
  else
    echo "==>> Installing cUrl ..."
    install_packages curl ca-certificates
  fi
}

download_and_install() {
  # Function to download and install a script.
  # ${1} - URL Of script to download
  # ${2} - Destination dir, defaults to /usr/local/bin
  # ${3} - Name of the command, defaults to the downloaded file name (with the
  #        archive extension stripped).

  # Make sure we have cUrl.
  install_curl

  # Ensure we have a temporary folder and download the file.
  DOWNLOAD_DIR="$(mktemp -d || mktemp -d -t 'tmp')"
  curl -sfL --retry 3 "${1}" --output "${DOWNLOAD_DIR}/${FILENAME="${1##*/}"}"
  
  # Check for a tar.* based extension, i.e. tar.(bz|bz2|gz).
  [ "gz" = "${TAR_EXTENSION="${FILENAME##*.tar.}"}" ] && EXTENSION="tgz"
  ([ "bz" = "${TAR_EXTENSION}" ] || [ "bz2" = "${TAR_EXTENSION}" ]) \
    && EXTENSION="tbz"

  # Work out the command if archived.
  [ -n "${TAR_EXTENSION}" ] && COMMAND="${FILENAME%.tar.*}"
  [ -z "${TAR_EXTENSION}" ] && COMMAND="${FILENAME%.*}"

  # Switch on the expected file extension and extract as necessary.
  case "${EXTENSION-"${1##*.}"}" in
    bz|bz2)
      bzip2 -d "${DOWNLOAD_DIR}/${FILENAME}"
      ;;
    gz)
      gunzip "${DOWNLOAD_DIR}/${FILENAME}"
      ;;
    tar)
      tar -xf "${DOWNLOAD_DIR}/${FILENAME}" -C "${DOWNLOAD_DIR}"
      ;;
    tbz|tbz2)
      tar -xjf "${DOWNLOAD_DIR}/${FILENAME}" -C "${DOWNLOAD_DIR}"
      ;;
    tgz)
      tar -xzf "${DOWNLOAD_DIR}/${FILENAME}" -C "${DOWNLOAD_DIR}"
      ;;
    zip)
      unzip "${DOWNLOAD_DIR}/${FILENAME}"
      ;;
    *)
      ;;
  esac

  # Check for a command/file with the same name.
  [ ! -f "${DOWNLOAD_DIR}/${COMMAND-"${FILENAME}"}" ] && FILENAME="${3}"

  # Install the file and remove the download directory.
  install \
    "${DOWNLOAD_DIR}/${COMMAND="${FILENAME}"}" \
    "${2-/usr/local/bin}/${3-"${COMMAND}"}"
  rm -r "${DOWNLOAD_DIR}"
}