# Changelog (jjs105/devcontainers)

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

jjs105-devcontainer

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
