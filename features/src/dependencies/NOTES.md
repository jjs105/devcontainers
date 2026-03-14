<!-- markdownlint-disable-file MD041 -->

## Implementation

Development container feature to provide simplified setup and set of libraries
useful for implementation of [other] development container templates and
features.

Carries out the following actions:

* Checks for availability of `apt-get` based installation
* Checks for `bash` and installs if necessary
* Updates the Operating System
* Installs `coreutils` and `sudo` support tools
* Installs `curl` (and `ca-certificates`) for download support
* Installs `vim` and `nano` editors
* Adds the  jjs105 `install` and `bashrc` script libraries to the container
