
# jjs105 Development Container Base (jjs105-devcontainer)

Installs tools useful for development of development containers.

## Example Usage

```json
"features": {
    "ghcr.io/jjs105/features/jjs105-devcontainer:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| install-lib | Copy install-lib.sh to the container for future use. | boolean | true |
| test-lib | Copy test-lib.sh to the container for future use. | boolean | false |
| ensure-bash | Ensure the Bash shell is installed. | boolean | true |
| bash-history-path | The path to use for the (common) bash history file. | string | /command-history/.bash_history |
| install-fzf | Install the fzf fuzzy search tool(s). | boolean | true |
| git-prompt | Install the Git prompt script. | boolean | true |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
