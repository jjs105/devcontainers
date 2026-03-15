
# Dev Container Prompt (prompt)

Sets the shell/bash prompt for all users including Git information.

## Example Usage

```json
"features": {
    "ghcr.io/jjs105/features/prompt:3": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|


<!-- markdownlint-disable-file MD041 -->

## Implementation

Development container feature to add a more useful prompt to the container. The
prompt should contain:

* User @ hostname
* OS release
* Current directory path
* Git information provided by standard `git-prompt.sh` script
* 2nd line trailing $ for non-root user and # for root user


---

_Note: This file was auto-generated from the [devcontainer-feature.json](devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
