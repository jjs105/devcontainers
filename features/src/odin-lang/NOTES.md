_Please note that compiling of the Odin language is not yet supported by this
feature._

## Development Container Build Times

This feature, especially when setting the `compile` option to true, can add a
lot of time to any development container build.

For this reason, when using Odin in ernest, the Odin development container
template - which is yet to be implemented - should be used.

## Features

This development container feature can be used to setup a working development
environment for the Odin programming language as follows:

* Linux or MacOS based using VSCode
* Install the Odin toolset, core + vendor libraries (/opt/jjs105/lib)  
  \+ Optionally create/add VSCode tasks to the `tasks.json` file
* Add the Odin Language Server (OLS) via VSCode extension  
  \+ Optionally create a set of OLS configuration files  
* Add the LLDB debugger via VSCode extension  
  \+ Optionally create/add VSCode 
* Optionally create, or add to an existing, set of VSCode configuration files
* Optionally install the Odin language examples

## References

<!-- markdownlint-disable-file MD041 -->