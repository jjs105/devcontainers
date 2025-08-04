
# jjs105 Development Container Base (jjs105-devcontainer)

Installs tools useful for development of development containers.

## Example Usage

```json
"features": {
    "ghcr.io/jjs105/devcontainers/jjs105-devcontainer:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| expected_secrets | Secrets to expect either in ENV variables or /workspace/.jjs105-secrets file. Comma separated list. | string | ATUIN_USERNAME,ATUIN_PASSWORD,ATUIN_KEY |
| shell_history_method | The method used to control shell history. | string | atuin_fzf |
| bash-history-path | The path to use shared shell history path (shared_file). | string | /command-history/.bash_history |
| git-prompt | Install the Git prompt script. | boolean | true |


## Install Library

## Test Library

## INI File

## Secrets

## Bash History FZF and Atuin

## Git Prompt

## References

<!-- markdownlint-disable-file MD041 -->

---

_Note: This file was auto-generated from the [devcontainer-feature.json](devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
