#-------------------------------------------------------------------------------
# Copyright (c) Jon Spain (https://github.com/jjs105).
# Licensed under GNU GPL v3 or later
# https://github.com/jjs105/devcontainers/tree/main/LICENSE
#-------------------------------------------------------------------------------

# Defines a set of functions to manager INI files

# @note: We assume that only the most basic POSIX shell (sh) is available to aid
# in OS compatibility etc.

#-------------------------------------------------------------------------------
# Script setup etc.

# Load library only once.
[ "true" = "${_lib_ini_loaded:-false}" ] && return 0 \
  || _lib_ini_loaded="true"

# POSIX shell doesn't have a way to get the current script path so we need to
# have set it, defaulting to /opt/jjs105/lib.
_jjs105_lib_path="${_jjs105_lib_path:-/opt/jjs105/lib}"

# Check if we should be logging and load library as necessary
[ "true" = "${_lib_ini_log:=false}" ] \
  && . "${_jjs105_lib_path}/lib-log.sh" || :
_lib_ini_log() {
  [ "true" = "${_lib_ini_log}" ] && \
    log "lib-ini" "${1}" || :
}

# If on BusyBox ensure gawk is installed.
$(awk 2>&1 | grep -q BusyBox) \
  && _lib_ini_log "installing GAWK on BusyBox" \
  && apk add --no-cache gawk \
    || :

#-------------------------------------------------------------------------------
# Internal functions.

_error() {
  # Simple internal error function.
  # @note: Centralised to a function in case we change approach.
  # ${1} - the error message

  echo "${1}" | tee "/dev/stderr"
}

_ini_readable() {
  # Internal function to check an INI file is readable. Reports on error.
  # ${1} - the INI file path to check

  [ -r "${1}" ] || { _error "INI file is not readable (${1})" && return 1; }
}

_ini_writable() {
  # Internal function to check an INI file is writeable. Reports on error.
  # on error.
  # ${1} - the INI file path to check

  [ -w "${1}" ] || { _error "INI file is not writable (${1})" && return 1; }
}

_ini_value() {
  # Internal function to print a value from an INI file using awk.
  # Exits with status 0 if the value is found, or 1 if not.
  # @note: This function is internal to allow multiple usages.
  # ${1} - the INI file path
  # ${2} - the section name or ROOT
  # ${3} - the key name

  _ini_readable "${1}" || return 1
  # -F is the delimiter, -v is a variable.
  awk -F '=' -v section="${2}" -v key="${3}" '

    # Init functions, variables and regular expressions.
    function trim(s) { gsub(/^[ \t"]+|[ \t"]+$/, "", s); return s; }
    BEGIN {
      in_root = 1; in_section = 0;
      found = 0;
      re_section = "\\["section"\\]";
      re_key = "^[ \t]*"key"[ \t]*";
    }

    # New section, update state variables.
    # @note: Next 2 lines - ORDER IS IMPORTANT.
    $0 ~ "^\\[" { in_root = 0; in_section = 0; }
    $0 ~ re_section { in_root = 0; in_section = 1; }

    # Matching key in correct section, return the value.
    $1 ~ re_key && (in_root == 1 && section == "ROOT" || in_section == 1) {
      print trim($2); found = 1; exit 0;
    }

    # At the end check if a value was found and exit as appropriate.
    END { if (found == 0) exit 1; }

  ' "${1}"
}

#-------------------------------------------------------------------------------
ini_has_section() {
  # Check if a section exists in an INI file.
  # ${1} - the INI file path
  # ${2} - the section name

  _ini_readable "${1}" || return 1
  _lib_ini_log "checking for INI section ${2} (${1})"
  # POSIX/Alpine, grep -q (--quiet).
  grep -q "^\[${2}\]" "${1}"; echo "${?}"
}

#-------------------------------------------------------------------------------
ini_ensure_section() {
  # Ensures a section exists in an INI file, adding if necessary.
  # ${1} - the INI file path
  # ${2} - the section name

  _ini_readable "${1}" || return 1
  _lib_ini_log "ensuring INI section ${2} (${1})"
  # POSIX/Alpine, grep -q (--quiet).
  grep -q "\[${2}\]" "${1}" || echo "\n[${2}]" >> "${1}"
}

#-------------------------------------------------------------------------------
ini_set_value() {
  # Set a value in an INI file.
  # @note: The logic of this function used to be more similar to that of the
  # _ini_value function but it never quite worked and the current logic is
  # easier to follow.
  # ${1} - the INI file path
  # ${2} - the section name or ROOT
  # ${3} - the key name
  # ${4} - the value to set

  # @todo: Don't strip empty lines.

  _ini_writable "${1}" || return 1
  _lib_ini_log "setting INI value ${2}/${3} = ${4} (${1})"
  # -F is the delimiter, -v is a variable.
  awk -F '=' -v section="${2}" -v key="${3}" -v value="${4}" '

    # Init functions, variables and regular expressions.
    function trim(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s; }

    BEGIN {
      in_root = 1; in_section = 0; key_found = 0; section_found = 0;
      re_section = "\\["section"\\]"; re_key = "^[ \t]*"key"[ \t]*";
    }

    # If in root and setting root key which matches.
    in_root == 1 && section == "ROOT" && $1 ~ re_key  {
      print key "=\"" trim(value) "\""; key_found = 1; next;
    }

    # If leaving root and setting root key which has not been found, add it.
    $0 ~ "^\\[" && in_root && section == "ROOT" && key_found == 0 {
      print key "=\"" trim(value) "\""; print ""; print;
      key_found = 1; in_root = 0; next;
    }

    # If in correct section and key which matches.
    in_section == 1 && $1 ~ re_key  {
      print key "=\"" trim(value) "\""; key_found = 1; next;
    }

    # If leaving correct section and key which has not been found, add it.
    $0 ~ "^\\[" && in_section && key_found == 0 {
      print key "=\"" trim(value) "\""; print ""; print;
      key_found = 1; in_section = 0; next;
    }

    # If entering a section update the in_section flag as necessary.
    $0 ~ "^\\[" {
      section_found = section_found || $0 ~ re_section;
      in_section = $0 ~ re_section; print ""; print; next;
    }

    # Add the line if not blank.
    0 != NF { print }

    END {
      # If root key not found add it at the end.
      # @note: This will only happen if no sections were found (i.e. left root).
      if (section == "ROOT" && key_found == 0) {
        print key "=\"" trim(value) "\""
      }
      # If section key not found add it at the end.
      if (section != "ROOT" && key_found == 0) {
        if (section_found == 0) { print ""; print "[" trim(section) "]" }
        print key "=\"" trim(value) "\""
      }
    }

  ' "${1}" > "${1}.tmp" && mv "${1}.tmp" "${1}"
}

#-------------------------------------------------------------------------------
ini_has_value() {
  # Check if a value exists in an INI file.
  # ${1} - the INI file path
  # ${2} - the section name or ROOT
  # ${3} - the key name

  _ini_readable "${1}" || return 1
  _lib_ini_log "checking for INI value ${2}/${3} (${1})"
  _ini_value "${1}" "${2}" "${3}" > /dev/null
}

#-------------------------------------------------------------------------------
ini_get_value() {
  # Get a value from an INI file or "" if not found.
  # ${1} - the INI file path
  # ${2} - the section name or ROOT
  # ${3} - the key name

  _ini_readable "${1}" || return 1
  _lib_ini_log "getting INI value ${2}/${3} (${1})"
  echo "$(_ini_value "${1}" "${2}" "${3}")" || ""
}

#-------------------------------------------------------------------------------
ini_get_keys() {
  # Gets the list of keys in an INF file section.
  # ${1} - the INI file path
  # ${2} - the section name or ROOT

  _ini_readable "${1}" || return 1
  _lib_ini_log "getting INI keys for section ${2} (${1})"
  # -F is the delimiter, -v is a variable.
  awk -F '=' -v section="${2}" '

    # Init functions, variables and regular expressions.
    function trim(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s; }
    BEGIN {
      result = ""
      in_root = 1; in_section = 0;
      section_found = 0;
      re_section = "\\["section"\\]";
    }

    # New section, update state variables.
    # @note: Next 2 lines - ORDER IS IMPORTANT.
    $0 ~ "^\\[" { in_root = 0; in_section = 0; }
    $0 ~ re_section { in_root = 0; in_section = 1; section_found = 1; }

    # Move to next line if a section header.
    $0 ~ "^\\[" { next; }

    # Move to next line if a comment.
    $0 ~ "^[ \t]*(#|;)" { next; }

    # Non-blank, non-comment, line in correct section, add to the list.
    0 != NF && (in_root == 1 && section == "ROOT" || in_section == 1) {
      result = result trim($1) ",";
    }

    # Re-create the file adding our value at the target line.
    END {
      if (result != "") { result = substr(result, 1, length(result)-1); }
      print result;
    }

  ' "${1}"
}
