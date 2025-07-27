# Changelog (jjs105/devcontainers)

_**2025-07-27:**_\
jjs105-devcontainer Feature

* Formatting and comment changes
* Added INI file functions to install library
* 'truthy' function added to install library
* Log files writable by all users
* Remove log setup side affect from install-lib.sh and add to a function

Odin Language Feature

* ODIN -> Odin
* Added create OLS config and format options + set in INI file
* OLS configuration files copied to jjs105/lib
* Added on create lifecycle script to copy OLS config files as necessary
  (INI file)
* Make sure example files are readable
* README.md update

WSLg Support Feature

* Changed check configuration to use INI file instead of file existence

_**2025-07-21:**_\
Initial version of the Odin language feature
Added WLSg support feature (initial working version)
Moved WSLg support feature environment variables to install script
Minor fixes to install-lib.sh
Check for multiple install of jjs105-devcontainer feature

_**2025-07-18:**_\
All command options -- instead of - (or explanation)
Return instead of exit from library functions
Install log identifier change
Added function to get git hub repo latest release tag
Tidy test lib comments
jjs105-devcontainer versioned

_**2025-07-16:**_\
Minor updates:

* Move bash history mount to the feature
* Comment and README updates
* Feature options defaults changes

_**2025-07-15:**_\
Initial working version(s)

* Working jjs105-devcontainer development container feature
* Working test library and use for testing jjs105-devcontainer
* Updated README and comments etc.

_**2025-07-09:**_\
Initial commit after 2025 re-think

* Update license to LGPL 3.0
* Updated README.md
* Working project development container, inc. use of symlink
* Working version of jjs105-devcontainer feature
* Initial, incomplete jjs105devcontainer test script

_**2025-07-03:**_\
All previous code committed and moved to `initial-approach` branch.
