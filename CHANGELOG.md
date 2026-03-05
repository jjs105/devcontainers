# Changelog (jjs105/devcontainers)

_**2026-03-05:**_

Multi line command audit - && or || being at start of additional lines

_**2026-03-04:**_

Configure Docker-in-Docker feature to disable use of Moby as opposed to
Docker CE. This is required as latest versions of Debian (Trixie onwards) do not
include the moby CLI tooling.

_**2025-08-12:**_

General

- Spelling ignored words in workspace
- ShellCheck audit and fixes

Odin Language Feature

- Added VS Code configuration files and option to add them to project
- OLS files now installed as set not individual files
- Implemented Odin language compilation option

_**2025-08-11:**_

General

- Workspace .vscode  spellings
- ShellCheck working - audit of all errors and warnings
  - Indicate shell either with !~ or directive
  - Remove $() where appropriate, surrounding quotes otherwise
  - printf instead of echo where appropriate
  - Use {} to ensure A && B || C always functions as expected
  - Use ${*} instead of ${@} in strings
  - remove use of local _var (not POSIX)
  - Use eval() instead of !indirection (POSIX)

jjs105-devcontainer Feature

- Added gitignore functionality to secrets library and called from .bashrc
- Added remove_downloads function to install library and use in install scripts
- Added shellcheck/eslint/bash-ide extensions to spec

_**2025-08-05:**_

General

- grep checks audit - i.e. no []
- local variable audit for all
- post-attach functionality of all features -> .bashrc.

jjs105-devcontainer Feature

- install-libraries-only option
- lib-ini.sh - fix to ignore comment lines
- lib-install.sh
  - added file set and sources install functions
  - added function to append script to .bashrc
- lib-secrets - all working + always use ROOT of secrets file

Odin Language Feature

- Removed option to specify examples path
- Re-write as install.sh + install-functions.ah
- Re-write in new style
- Hard-coded version until releases fixed

_**2025-08-04:**_\
New approach - jjs105-devcontainer working, others NOT

General

- \*-lib.sh -> lib-\*.sh
- separate libraries for all functionality
- libraries check for already loaded
- Alpine/ash/busybox command flags audit
- local + lowercase variables audit
- lib-ini.sh - checks for and installs gawk
- lib-install, check for and install sudo
- lib-secrets, no use of IFS

jjs105-devcontainer Feature

- Always copy all libraries to container
- Always ensure bash
- No need for post-attach script
- Opinionated atuin settings always
- Re-write as install.sh + install-functions.ah
- bash-prompt.sh -> jjs105-bashrc.sh, now git-prompt, secrets and atuin login

_**2025-07-31:**_

jjs105-devcontainer Feature

- Always install the install-lib.sh library
- Added show/log context functions to install library
- Added simple secrets function to container and install library - env/INI
- Reimplemented ini_set_value function in install library
- Added ini_get_keys function to install library
- Added atuin shell history installation + post attach command to configure
- Changed shell history logic to support bash/fzf/atuin
- Updated test script

_**2025-07-27:**_

jjs105-devcontainer Feature

- Formatting and comment changes
- Added INI file functions to install library
- 'truthy' function added to install library
- Log files writable by all users
- Remove log setup side affect from install-lib.sh and add to a function

Odin Language Feature

- ODIN -> Odin
- Added create OLS config and format options + set in INI file
- OLS configuration files copied to jjs105/lib
- Added on create lifecycle script to copy OLS config files as necessary
  (INI file)
- Make sure example files are readable
- README.md update

WSLg Support Feature

- Changed check configuration to use INI file instead of file existence

_**2025-07-21:**_

- Initial version of the Odin language feature
- Added WLSg support feature (initial working version)
- Moved WSLg support feature environment variables to install script
- Minor fixes to install-lib.sh
- Check for multiple install of jjs105-devcontainer feature

_**2025-07-18:**_

- All command options -- instead of - (or explanation)
- Return instead of exit from library functions
- Install log identifier change
- Added function to get git hub repo latest release tag
- Tidy test lib comments
- jjs105-devcontainer versioned

_**2025-07-16:**_\

Minor updates

- Move bash history mount to the feature
- Comment and README updates
- Feature options defaults changes

_**2025-07-15:**_\
Initial working version(s)

- Working jjs105-devcontainer development container feature
- Working test library and use for testing jjs105-devcontainer
- Updated README and comments etc.

_**2025-07-09:**_\
Initial commit after 2025 re-think

- Update license to LGPL 3.0
- Updated README.md
- Working project development container, inc. use of symlink
- Working version of jjs105-devcontainer feature
- Initial, incomplete jjs105devcontainer test script

_**2025-07-03:**_\
All previous code committed and moved to `initial-approach` branch.
