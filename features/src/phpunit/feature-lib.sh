# Library containing functions useful when developing dev container features. Heavily based on the library_scripts.sh
# library used by many of the official, or community supported, dev container features found at the following URL:
# https://containers.dev/features.

# @note: We do not specify the shell when developing features and ensure compatibility by assuming use of sh.

install_packages() {
    # Function to install a list of packages.
    # @note: We do not worry about uninstalling later - i.e. to minimise container image layer sizes. If this is a hard
    # requirement then a different approach should be used.
    # ${@} - list of packages to install

    # Use apt if available.
    if [ -x "/usr/bin/apt-get" ]; then
        apt-get update --assume-yes \
        && apt-get install --assume-yes --no-install-recommends "$@" \
        && apt-get clean && apt-get autoclean && apt-get autoremove \
        && rm -rf /var/lib/apt/lists/*

    # Fall back to using APK (i.e. on Alpine).
    elif [ -x "/sbin/apk" ] ; then
        apk add --no-cache "$@"

    # Otherwise noy supported.
    else
        echo "Linux distro not supported."
        exit 1
    fi
}