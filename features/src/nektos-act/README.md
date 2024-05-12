
# nektos/act Tool (nektos-act)

Installs the nektos/act tool.

## Example Usage

```json
"features": {
    "ghcr.io/jjs105/devcontainers/nektos-act:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | The version/release to install. | string | latest |
| install-dir | The target install directory. | string | /usr/local/bin |
| debugging | Whether to enable debug logging. | boolean | false |

## Description

Provides the `act` command in the shell. This command can be used to run GitHub 
actions and/or woorkflows on the local machine - i.e. utilising Docker to create
and use local runners.

Further information about this tool and its use can be found at the following
URL:
* https://github.com/nektos/act

## Tests

This feature has a single (auto-generated) test which checks that 

The tests associated with this feature checks that the act binary:

1) Is installed in the correct location
1) Can be run with the `--version` flag without error


---

_Note: This file was auto-generated from the [devcontainer-feature.json](devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
