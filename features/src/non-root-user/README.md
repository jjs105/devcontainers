
# Dev Container Non-Root User (non-root-user)

Sets up a non-root user for the development container.

## Example Usage

```json
"features": {
    "ghcr.io/jjs105/features/non-root-user:3": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| username | Non-root development container user name. | string | auto |
| user_uid | Non-root development container user UID. | string | auto |
| user_gid | Non-root development container user GID. | string | auto |

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


---

_Note: This file was auto-generated from the [devcontainer-feature.json](devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
