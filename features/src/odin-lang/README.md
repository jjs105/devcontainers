
# ODIN Language Support (odin-lang)

Adds the ODIN language support and tools.

## Example Usage

```json
"features": {
    "ghcr.io/jjs105/features/odin-lang:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| release | The ODIN release version to install. 'latest' for latest official release, 'master' for GitHub master. | string | latest |
| os | The target operating system (when downloading, not compiling. | string | linux |
| arch | The target architecture (when downloading, not compiling. | string | amd64 |
| examples | Whether to install the ODIN example projects. | boolean | true |
| examples-path | The path where the ODIN example projects will be installed. | string | /opt/jjs105/src |

## Customizations

### VS Code Extensions

- `DanielGavin.ols`

_Please note that compiling of the ODIN language is not yet supported by this
feature._

## Development Container Build Times

This feature, especially when setting the `compile` option to true, can add a
lot of time to any development container build.

For this reason, when using ODIN in ernest, the ODIN development container
template - which is yet to be implemented - should be used.

<!-- markdownlint-disable-file MD041 -->


---

_Note: This file was auto-generated from the [devcontainer-feature.json](devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
