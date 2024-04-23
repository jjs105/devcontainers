
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
| version | The version to install. | string | latest |
| os | The target operating system. | string | linux |
| arch | The target CPU architecture. | string | x86_64 |

## Description

Provides the `exercism` command in the shell. This command is used when working
locally on (programming) exercises provided by the Exercism site.

Further information about working on Exercism solutions locally may be found at
the following URL:
* https://exercism.org/docs/using/solving-exercises/working-locally

Note this tool requires authentication using your Exercism token specified as
follows:

```shell
exercism configure --token=<token>
```

## Sources

Existing examples of this same feature were found at the following URLs:

* https://github.com/CodeMan99/features/tree/main/src/exercism-cli
* https://github.com/devcontainers-contrib/features/tree/main/src/exercism-cli

These implementations use different approaches, both of which are as described
in the main README.md file of this repository.


---

_Note: This file was auto-generated from the [devcontainer-feature.json](devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
