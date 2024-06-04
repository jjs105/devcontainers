
# Exercism PHP (exercism-php-cli)

An environment suitable for local development of Exercism PHP solutions.

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| imageVariant | PHP image variant to use. | string | 8-cli-alpine |


## Using the Exercism CLI

Note this tool requires configuration to a) set up your Exercism authentication
using your Exercism token and b) set your workspace, as follows:

```shell
exercism configure \
  --token=<token> \
  --workspace=<workspace>
```

Alternatively the values can be set using the local environment variables
`EXERCISM_TOKEN` and `WORKSPACE_PATH` which are then passed ot the development
container.

---

_Note: This file was auto-generated from the [devcontainer-template.json](devcontainer-template.json).  Add additional notes to a `NOTES.md`._
