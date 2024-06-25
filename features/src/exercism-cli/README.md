
# Exercism CLI (exercism-cli)

Installs the Exercism CLI application.

## Example Usage

```json
"features": {
    "ghcr.io/jjs105/devcontainers/exercism-cli:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| workspace | The workspace path to configure for the exercism CLI tool. | string | /workspaces/exercism |
| token | The authentication token to configure for the exercism CLI tool. | string | - |
| version | The version to install. | string | latest |
| os | The target operating system. | string | linux |
| arch | The target CPU architecture. | string | x86_64 |

## Description

Provides the `exercism` command in the shell. This command is used when working
locally on (programming) exercises provided by the Exercism site.

Further information about working on Exercism solutions locally may be found at
the following URL:
* https://exercism.org/docs/using/solving-exercises/working-locally

## Using the Exercism CLI

Note the `exercism` tool requires configuration to a) set up your Exercism
authentication using your Exercism token and b) set your workspace, as follows:

```shell
exercism configure \
  --token=<token> \
  --workspace=<workspace>
```

Alternatively the values can be set using the local environment variables
`EXERCISM_TOKEN` and `WORKSPACE_PATH` which are then passed ot the development
container.

## Sources

Existing examples of this same feature were found at the following URLs:

* https://github.com/CodeMan99/features/tree/main/src/exercism-cli
* https://github.com/devcontainers-contrib/features/tree/main/src/exercism-cli

These implementations use different approaches, both of which are as described
in the main README.md file of this repository.

## Tests

The tests associated with this feature check that the Exercism CLI tool:

1) Is installed in the correct location
1) Can be run with the `version` command without error

The tests are run against the following scenarios:

* Latest Ubuntu base image with no options set (auto-generated)
* Latest Alpine base image
* Latest Archlinux base image
* Latest Debian base image
* Latest ARM64 based Alpine base image using Darwin (Mac) OS and ARM64 Exercism
CLI tool binary 

Note: The Darwin/ARM64 test will fail unless run on a Mac (or compatible)
system. If this is the case all other tests will fail.


---

_Note: This file was auto-generated from the [devcontainer-feature.json](devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
