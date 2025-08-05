
# Odin Language Support (odin-lang)

Adds the Odin language support and tools.

## Example Usage

```json
"features": {
    "ghcr.io/jjs105/features/odin-lang:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| release | The Odin language release version to install. 'latest' for latest official release, 'master' for GitHub master. | string | latest |
| os | The target operating system (when downloading, not compiling. | string | linux |
| arch | The target architecture (when downloading, not compiling. | string | amd64 |
| examples | Whether to install the Odin language example projects. | boolean | true |
| ols-create-config | Whether to create ant OLS configuration file. | boolean | true |
| ols-create-format | Whether to create ant OLS format file. | boolean | true |

## Customizations

### VS Code Extensions

- `DanielGavin.ols`
- `vadimcn.vscode-lldb`

_Please note that compiling of the Odin language is not yet supported by this
feature._

## Development Container Build Times

This feature, especially when setting the `compile` option to true, can add a
lot of time to any development container build.

For this reason, when using the Odin language in ernest, the Odin language
development container template - which is yet to be implemented - should be
used.

## Features

This development container feature can be used to setup a working development
environment for the Odin language as follows:

* Linux or MacOS based using VSCode
* Install the Odin language toolset, core + vendor libraries (/opt/jjs105/lib)  
  \+ Optionally create/add VSCode tasks to the `tasks.json` file
* Add the Odin Language Server (OLS) via VSCode extension  
  \+ Optionally create a set of OLS configuration files  
* Add the LLDB debugger via VSCode extension  
  \+ Optionally create/add VSCode 
* Optionally create, or add to an existing, set of VSCode configuration files
* Optionally install the Odin language examples

## References

<!-- markdownlint-disable-file MD041 -->

---

_Note: This file was auto-generated from the [devcontainer-feature.json](devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
