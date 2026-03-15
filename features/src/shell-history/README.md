
# Shell History Tools (shell-history)

Installs atuin shell history and fzf fuzzy search tools.

## Example Usage

```json
"features": {
    "ghcr.io/jjs105/features/shell-history:3": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| method | The method used to control shell history. | string | shared_file |
| shared-path | The path to use shared shell history path (shared_file). | string | /command-history/.bash_history |

<!-- markdownlint-disable-file MD041 -->

## Implementation

Development container feature to add a shell history tools to the container.
Supports the following approaches.

## Shared File

Configures the bash history path to the value in the `shared-path` option via
setting the `HISTFILE` environment variable in the users' `~/.bashrc` file.

This configured path (in the container) should mounted to the host filesystem
allowing the command history to be saved between container restarts and/or
between development containers.

## FZF

Installs the [`fzf`] command-line fuzzy finder tool which has options for
integration with the bash shell history.

[`fzf`]: https://github.com/junegunn/fzf

## Atuin

Installs the [`atuin`] command-line shell tool allowing backup and sync of shell
history across development containers as well as separate hosts and physical
machines.

[`atuin`]: https://atuin.sh/

## Account Settings and Sync

To enable Atuin's sync feature(s) you must have registered, and be logged into,
an account. To facilitate this the development container feature utilises an INI
file, `.jjs105.ini` at the root of your project workspace.

If this file is not found an exemplar version is created and it is added to a
`.gitignore` file (which it also creates if necessary).

### Configuration

Note the following opinionated Atuin options are set as part of the install:

* [Disable Up Arrow]
* [Disable Enter Accept]
* [Set Inline Height = 0 (max)]

[Disable Up Arrow]: https://docs.atuin.sh/cli/configuration/key-binding/?h=disable+up+arrow#disable-up-arrow
[Disable Enter Accept]: https://docs.atuin.sh/cli/configuration/config/?h=enter_accept#enter_accept
[Set Inline Height = 0 (max)]: https://docs.atuin.sh/cli/configuration/config/?h=inline#inline_height

## Atuin and FZF

Installs both of the above tools configured such that fuzzy search works with
Atuin.


---

_Note: This file was auto-generated from the [devcontainer-feature.json](devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
