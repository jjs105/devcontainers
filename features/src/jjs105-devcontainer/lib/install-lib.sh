#-------------------------------------------------------------------------------
# Copyright (c) Jon Spain (https://github.com/jjs105).
# Licensed under GNU GPL v3 or later
# https://github.com/jjs105/devcontainers/tree/main/LICENSE
#-------------------------------------------------------------------------------

# Defines (helper) functions for the implementation of development container and
# feature install scripts.

# @note: We assume that only the most basic POSIX shell (sh) is available to aid
# in OS compatibility etc.

#-------------------------------------------------------------------------------
# Main install orientated functions.

#-------------------------------------------------------------------------------
install_packages() {
  # Function to install a list of packages.
  # @note: We do not worry about uninstalling later - i.e. to minimise
  # development container image layer sizes. If this is a hard requirement then
  # a different approach should be used.
  # ${@} - list of packages to install

  # Use apt if available.
  if [ -x "/usr/bin/apt-get" ]; then
    apt-get update --assume-yes \
    && apt-get install --assume-yes --no-install-recommends "$@" \
    && apt-get clean && apt-get autoclean && apt-get autoremove \
    && rm --recursive --force /var/lib/apt/lists/*

  # APK? (i.e. on Alpine).
  elif [ -x "/sbin/apk" ]; then
    apk add --no-cache "$@"

  # Pacman? (i.e. on Arch).
  elif [ -x "/sbin/pacman" ]; then
    pacman --noconfirm --sync --refresh "$@"

  # Otherwise not supported.
  else
    echo "Linux distro not supported."
    return 1
  fi
}

#-------------------------------------------------------------------------------
install_library() {
  # Simple install library function.
  # @note: This is implemented as the 'install' utility is not in the POSIX
  # shell specification and therefore may not be available.
  # ${1} - source file path
  # ${2} - target directory path

  # We only support installing single (library) files.
  [ ! -f "${1}" ] \
    && log "jjs105/install-lib" \
      "install_library() expects '${1}' to be a file" \
    && return 1

  # Ensure that the target path exists copy the file and set permissions.
  log "jjs105/install-lib" "installing library ${1} -> ${2}"
  mkdir --parents "${2}" && cp "${1}" "${2}" \
    && chmod u=rw,go=r "${2}/${1##*/}"
}

#-------------------------------------------------------------------------------
install_script() {
  # Simple install script function.
  # @note: This is implemented as the 'install' utility is not in the POSIX
  # shell specification and therefore may not be available.
  # ${1} - source file path
  # ${2} - target directory path

  # We only support installing single (script) files.
  [ ! -f "${1}" ] \
    && log "jjs105/install-lib" "install_script() expects '${1}' to be a file" \
    && return 1

  # Ensure that the target path exists copy the file and set permissions.
  log "jjs105/install-lib" "installing script ${1} -> ${2}"
  mkdir --parents "${2}" && cp "${1}" "${2}" \
    && chmod u=rwx,go=rx "${2}/${1##*/}"
}

#-------------------------------------------------------------------------------
install_workspace_file() {
  # Simple install workspace file function.
  # @note: This is implemented as the 'install' utility is not in the POSIX
  # shell specification and therefore may not be available.
  # ${1} - source file path
  # ${2} - target directory path

  # We only support installing single files.
  [ ! -f "${1}" ] \
    && log "jjs105/install-lib" \
      "install_workspace_file() expects '${1}' to be a file" \
    && return 1

  # Ensure that the target path exists copy the file and set permissions.
  log "jjs105/install-lib" "installing library ${1} -> ${2}"
  mkdir --parents "${2}" && cp "${1}" "${2}" \
    && chmod ugo=rw "${2}/${1##*/}"
}

#-------------------------------------------------------------------------------
# Utility functions.

#-------------------------------------------------------------------------------
truthy() {
  # Checks if a value is truthy - 1, y, yes, t, true
  # ${1} - the value to check

  case "${1}" in
    1|[yY]|[yY][eE][sS]|[tT]|[tT][rR][uU][eE]) return 0;;
    *) return 1;;
  esac
}

#-------------------------------------------------------------------------------
latest_git_release() {
  # Get the latest release tag from a GitHub repository.
  # ${1} - the GitHub repository in the format 'owner/repo'

  # Get the release information from the GitHub API and extract the tag name.
  curl --silent "https://api.github.com/repos/${1}/releases/latest" \
    | grep '"tag_name":' \
    | sed --regexp-extended 's/.*"([^"]+)".*/\1/'
}

#-------------------------------------------------------------------------------
run_command_for_users() {
  # Runs a command for all users - i.e. root, _CONTAINER_USER and _REMOTE_USER
  # ${1} - the command to run

  # Run the command for root.
  log "jjs105/install-lib" "running command as root: ${1}"
  /bin/su --command "${1}" - root
  
  # Run the command for the container user if not root.
  if [ "root" != "${_CONTAINER_USER}" ]; then
    log "jjs105/install-lib" \
      "running command as _CONTAINER_USER: ${_CONTAINER_USER}: ${1}"
    /bin/su --command "${1}" - "${_CONTAINER_USER}"
  fi

  # Run the command for the remote user if not root or the container user.
  if [ "root" != "${_REMOTE_USER}" ] \
    && [ "${_CONTAINER_USER}" != "${_REMOTE_USER}" ]; then
      log "jjs105/install-lib" \
        "running command as _REMOTE_USER: ${_REMOTE_USER}: ${1}" \
      && /bin/su --command "${1}" - "${_REMOTE_USER}"
    fi
}

#-------------------------------------------------------------------------------
ensure_jjs105_ini() {
  # Function to ensure that the jjs105.ini file exists.
  # ${1} - the INI file name to create, defaults to jjs105.ini

  # Create path and file separately.
  [ ! -d "${INI_PATH=/opt/jjs105/etc}" ] \
    && _log "creating jjs105 /etc directory" \
    && mkdir --parents "${INI_PATH}"
  [ ! -f "${INI_FILE=/opt/jjs105/etc/"${1:-jjs105.ini}"}" ] \
    && _log "creating jjs105 INI file (${INI_FILE})" \
    && touch "${INI_FILE}"

  # Ensure permissions of all.
  chmod --recursive ugo+w "${INI_PATH}"
}

#-------------------------------------------------------------------------------
# INI file functions.

ini_has_section() {
  # Check if a section exists in an INI file.
  # ${1} - the INI file path
  # ${2} - the section name

  grep --quiet "^\[${2}\]" "${1}"; echo "${?}"
}

ini_ensure_section() {
  # Ensures a section exists in an INI file, adding if necessary.
  # ${1} - the INI file path
  # ${2} - the section name

  grep --quiet "\[${2}\]" "${1}" || echo "\n[${2}]" >> "${1}"
}

ini_set_value() {
  # Set a value in an INI file.
  # ${1} - the INI file path
  # ${2} - the section name or ROOT
  # ${3} - the key name
  # ${4} - the value to set

  # Set = as the delimiter (-F) and set variables (-v).
  awk -F '=' -v section="${2}" -v key="${3}" -v value="${4}" '

    # Init functions, variables and regular expressions.
    function trim(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s; }
    BEGIN {
      in_root = 1; in_section = 0;
      key_found = 0; section_found = 0; last_line = 1;
      re_section = "\["section"\]";
      re_key = "^[ \t]*"key"[ \t]*";
    }

    # New section, update state variables.
    # @note: Next 2 lines - ORDER IS IMPORTANT.
    $0 ~ "^\[" { in_root = 0; in_section = 0; }
    $0 ~ re_section { in_root = 0; in_section = 1; section_found = 1; }

    # Non-blank line in correct section, update target line.
    0 != NF && (in_root == 1 && section == "ROOT" || in_section == 1) {
      last_line = NR;
    }

    # Matching key in correct section, update target line and state.
    $1 ~ re_key && (in_root == 1 && section == "ROOT" || in_section == 1)  {
      last_line = NR; key_found = 1; in_root = 0; in_section = 0;
    }

    # Add the line to the list.
    { lines[NR] = $0; }

    # Re-create the file adding our value at the target line.
    END {
      for (i = 1; i <= NR; i++) {

        # If we found the key and we are on the target line update the line.
        if (key_found && i == last_line) {
          print key "=" trim(value); continue;
        }

        # If we are on the target line copy it and add the value line after.
        # @note: If no section found then target_line is outside of this loop.
        if (i == last_line) {
          print lines[i]; print key "=" trim(value); continue;
        }

        # Otherwise just copy the line.
        print lines[i];
      }

      # If the section was not found, add it (if not root) and the value.
      if (section_found == 0) {
        if (NR > 0) { print "";}
        if (section != "ROOT") { print "[" section "]"; }
        print key "=" trim(value)
      }
    }

  ' "${1}" > "${1}.tmp" && mv "${1}.tmp" "${1}"
}

_ini_value() {
  # Internal function to print a value from an INI file using awk.
  # Exits with status 0 if the value is found, or 1 if not.
  # @note: Very similar logic to ini_set_value but merging would confuse.
  # @note: This function is internal to allow multiple usages.
  # ${1} - the INI file path
  # ${2} - the section name or ROOT
  # ${3} - the key name

  # Set = as the delimiter (-F) and set variables (-v).
  awk -F '=' -v section="${2}" -v key="${3}" '

    # Init functions, variables and regular expressions.
    function trim(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s; }
    BEGIN {
      in_root = 1; in_section = 0;
      found = 0;
      re_section = "\["section"\]";
      re_key = "^[ \t]*"key"[ \t]*";
    }

    # New section, update state variables.
    # @note: Next 2 lines - ORDER IS IMPORTANT.
    $0 ~ "^\[" { in_root = 0; in_section = 0; }
    $0 ~ re_section { in_root = 0; in_section = 1; }

    # Matching key in correct section, return the value.
    $1 ~ re_key && (in_root == 1 && section == "ROOT" || in_section == 1) {
      print trim($2); found = 1; exit 0;
    }

    # At the end check if a value was found and exit as appropriate.
    END { if (found == 0) exit 1; }

  ' "${1}"
}

ini_has_value() {
  # Check if a value exists in an INI file.
  # ${1} - the INI file path
  # ${2} - the section name or ROOT
  # ${3} - the key name

  _ini_value "${1}" "${2}" "${3}" > /dev/null
}

ini_get_value() {
  # Get a value from an INI file or "" if not found.
  # ${1} - the INI file path
  # ${2} - the section name or ROOT
  # ${3} - the key name

  echo "$(_ini_value "${1}" "${2}" "${3}")" || ""
}

#-------------------------------------------------------------------------------
# Log file functionality.

log_setup() {
  # Ensure the log directory exists and is writable.
  # @note: This should only be during install as development container feature
  # install scripts run as root.

  mkdir --parents /var/log/jjs105 && touch /var/log/jjs105/install-log
  chmod --recursive ugo+rw /var/log/jjs105
}

log() {
  # Simple log function.
  # ${1} - package identifier
  # ${2} - string to log

  # Log to stdout and log file (we don't assume that 'tee' is available).
  echo "===>>> ${1}: ${2}"
  echo "===>>> ${1}: ${2}" >> /var/log/jjs105/install-log
}
