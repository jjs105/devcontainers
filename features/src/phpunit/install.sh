# Installs the PHPUnit application https://phar.phpunit.de/
# Feature options:
#   - version: The version to install (defaults to latest).
#   - install-php: Whether to install supporting PHP packages (defaults to
#     false, other = cli|all).

# @note: We do not specify the shell when developing features and ensure
# compatibility by assuming use of sh.

set -eu

# Feature options.
VERSION="${VERSION=latest}"
INSTALL_PHP="${INSTALL_PHP=false}"

# Include the development containers common library.
. ./devcontainers-lib.sh

# Make sure we have cUrl.
install_curl

# If INSTALL_PHP is anything other than 'false' we need to ...
if [ "false" != "${INSTALL_PHP}" ]; then

  # If on Ubuntu/using apt ...
  if [ -x "/usr/bin/apt-get" ]; then

    # Add the ppa:ondrej/php to our list of sources.
    # @note: We could add the required PHP PPA using the standard script using
    # the following commands.

    # install_packages software-properties-common curl ca-certificates
    # add-apt-repository ppa:ondrej/php
    
    # However we instead do this by hand to avoid installing bloat as part of
    # the feature. Additionally this feature is only ever likely to be installed
    # on a PHP base development container anyway!

    # More information about installing packages from PPAs can be found at the 
    # following URLs.

    # https://linuxize.com/post/how-to-add-apt-repository-in-ubuntu/
    # https://dev.to/pallade/ppaondrejphp-on-ubuntu-2304-lunar-ia1
    # https://gist.github.com/joerx/d16dc49046c9f9807bf5
    # https://launchpad.net/~ondrej/+archive/ubuntu/php
    # https://askubuntu.com/questions/1312464/how-to-get-the-gpg-key-for-a-repository#:~:text=Go%20to%20the%20page%20of,specific%20directory%20on%20your%20system.

    # Before we can add the source  we need some other packages.
    echo "==>> Installing PPA required packages ..."
    install_packages lsb-release gnupg

    # The fingerprint value as specified in the PPA specification.
    FINGERPRINT="14AA40EC0831756756D7F66C4F4EA0AAE5267A6C"

    # Get the public key for the PPA using the fingerprint and add to apt.
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys "${FINGERPRINT}"

    # Add the PPA(s) to the apt sources list.
    echo "deb https://ppa.launchpadcontent.net/ondrej/php/ubuntu $(lsb_release -cs) main" \
      | tee -a /etc/apt/sources.list
    echo "deb-src https://ppa.launchpadcontent.net/ondrej/php/ubuntu $(lsb_release -cs) main" \
      | tee -a /etc/apt/sources.list

    # If we got to here we need to install the PHP CLI and common libraries.
    echo "==>> Installing PHP 8.2 and PHPUnit required packages ..."
    install_packages php8.2-common php8.2-cli php8.2-xml php8.2-mbstring

    # And if 'all' is specified install the remaining packages.
    echo "==>> Installing additional packages ..."
    [ "all" = "${INSTALL_PHP}" ] && install_packages php8.2-pcov php8.2-xdebug

  # If on Alpine/using apk ...
  elif [ -x "/sbin/apk" ]; then

    # If we got to here we need to install the PHP CLI and common libraries.
    echo "==>> Installing PHP 8.2 and PHPUnit required packages ..."
    install_packages \
      php82-common php82-cli php82-phar \
      php82-xml php82-dom php82-xmlwriter \
      php82-tokenizer php82-ctype php82-mbstring

    # And if 'all' is specified install the remaining packages.
    echo "==>> Installing additional packages ..."
    [ "all" = "${INSTALL_PHP}" ] \
      && install_packages php82-pecl-pcov php82-pecl-xdebug

    # For some reason no generic PHP executable/link is created on Alpine.
    [ ! -f /usr/bin/php ] && [ -f /usr/bin/php82 ] \
      && ln -s /usr/bin/php82 /usr/bin/php
    [ ! -f /usr/bin/php ] && [ -f /usr/bin/php8 ] \
      && ln -s /usr/bin/php8 /usr/bin/php
  fi
  
else
  echo "==>> Not installing PHP/packages - feature tests etc. may/will fail."
fi

# Set up.
DEST_DIR="/usr/local/bin"
BASE_URL="https://phar.phpunit.de"
LATEST_URL="${BASE_URL}/phpunit.phar"
VERSION_URL="${BASE_URL}/phpunit-${VERSION}.phar"

# Work out the URL and report.
[ "latest" = "${VERSION}" ] && RELEASE_URL="${LATEST_URL}" \
    || RELEASE_URL="${VERSION_URL}"
echo "==>> Installing PHPUnit: v${VERSION}"
echo "==>> from: ${RELEASE_URL}"
echo "==>> to: ${DEST_DIR}"

# Download and install.
# @note: the cUrl --output-dir option is only supported by v7.73+ so change to
# the directory to be on the safe side.
download_and_install "${RELEASE_URL}"
