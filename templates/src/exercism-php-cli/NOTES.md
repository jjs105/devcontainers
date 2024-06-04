
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