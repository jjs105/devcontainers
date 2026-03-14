
# Dev Container Dependencies (jjs105-dependencies)

Installs various tools and a minimal install library for use by other features.

## Example Usage

```json
"features": {
    "ghcr.io/jjs105/features/jjs105-dependencies:3": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| skip_bash_check | Whether to skip check and install of the bash shell. | boolean | false |

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


---

_Note: This file was auto-generated from the [devcontainer-feature.json](devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
