<!-- markdownlint-disable-file MD041 -->

## Implementation

Development container feature to add a non-root user to the container. Based on
the functionality/logic found in the [`common-utils`] development container
feature, summarised as follows:

* Determine the username using `username` option, or if set to `auto` then
  `REMOTE_USER` (if set), exiting user with UID = 1000, falling back to `devc`
* Determine the UID and GID using the `username` chosen above if the account
  already exists, then any set option value, falling back to the OS default if
  set to `auto`
* Configures the user such that it can use `sudo`

[`common-utils`]: https://github.com/devcontainers/features/tree/main/src/common-utils
