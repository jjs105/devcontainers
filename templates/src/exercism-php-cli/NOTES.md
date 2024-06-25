## Description

Provides a PHP environment suitable for carrying out PHP based Erercism
exercises locally. Uses an official PHP container image as a base and then adds
the `exercism` cli tool and PHPUnit using the development container features
also contained in this repository.

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