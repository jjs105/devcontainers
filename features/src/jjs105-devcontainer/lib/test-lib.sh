#-------------------------------------------------------------------------------
# Copyright (c) Jon Spain (https://github.com/jjs105).
# Licensed under GNU GPL v3 or later
# https://github.com/jjs105/devcontainers/tree/main/LICENSE
#-------------------------------------------------------------------------------

# Defines a bespoke functionality allowing enhanced testing of development
# container scripts and templates.

# @note: echo -e means interpret escaped chars, -n means no ending newline.

#-------------------------------------------------------------------------------
log() {
  # Simple log function.
  # @note: We need to check for the (writable) log directory as it will only
  # exist if the development container is one of our own.
  # ${1} - package identifier
  # ${2} - string to log

  # Log to stdout.
  echo "===>>> ${1}: ${2}"
  # Check for our log location and log to file if we can (we don't assume that
  # 'tee' is available).
  [ -d "/var/log/jjs105/" ] && \
    echo "===>>> ${1}: ${2}" >> /var/log/jjs105/test-log
}

#-------------------------------------------------------------------------------
# Check that we are running under bash.
# @note: There isn't a suitable way to run this reliably, the below check seems
# to be the least worst option. We also use an if;then construct rather than &&
# in case the log command fails for any reason.

if [ "bash" != "$(readlink /proc/$$/exe | sed "s/.*\///")" ]; then
  log "test-lib" "Test scripts must be run using the bash shell, exiting."
  exit 1
fi

#-------------------------------------------------------------------------------
# Functions equivalent to that provided by the devcontainer CLI tool.

# Count of failed tests.
DC_CLI_FAILED=()

check() {
  # Function to run a single command as a check/test.
  # ${1} - test label
  # ${2...} - test command to run

  local _LABEL="${1}"; shift
  echo -e "🔄 Testing '${_LABEL}'\033[37m"

  # Run the test reporting the result, adding to the failed list if it fails.
  if "${@}"; then
    echo "✅ Passed '${_LABEL}'" && return 0
  else
    DC_CLI_FAILED+=("${_LABEL}")
    echo "❌ Failed '${_LABEL}'" 1>&2 && return 1
  fi
}

checkMultiple() {
  # Function to run a multiple commands as a check/test.
  # ${1} - test label
  # ${2} - minimum number of successful commands required to pass
  # ${3...} - test commands to run

  local _LABEL="${1}"; shift;
  local _MIN_TO_PASS="${1}"; shift
  echo -e "🔄 Testing '${_LABEL}'\033[37m"

  # Loop through the multiple tests.
  local _PASSED=0; local _EXPRESSION="${1}"
  while [ "" != "${_EXPRESSION}" ]; do
    if "${_EXPRESSION}"; then ((_PASSED++)); fi
    shift; _EXPRESSION="${1}"
  done

  # Check the tests against minimum required reporting the result, adding to the
  # failed list if it fails.
  if [ "${_PASSED}" -ge "${_MIN_TO_PASS}" ]; then
    echo "✅ Passed '${_LABEL}'" && return 0
  else
    DC_CLI_FAILED+=("${_LABEL}")
    echo "❌ Failed '${_LABEL}'" 1>&2 && return 1
  fi
}

reportResults() {
  # Function to report test results of testing created with check* function(s).

  [ 0 = "${#DC_CLI_FAILED[@]}" ] && echo "✅✅✅ All Tests Passed" && return 0
  echo "💥💥💥 Failed tests: ${DC_CLI_FAILED[@]}" 1>&2 && return 1
}

#-------------------------------------------------------------------------------
# Our internal test tracking functions.

# Passed and failed test lists.
PASSED_TESTS=(); FAILED_TESTS=()

# The label of the most recent started test and whether it has sub results.
CURRENT_TEST_LABEL=""; CURRENT_TEST_HAS_SUB=0

_test_start() {
  # Function to start a test - simply displays a label but could be enhanced for
  # performance metrics etc.
  # ${1} - the test label to display

  CURRENT_TEST_LABEL="${1}"; CURRENT_TEST_HAS_SUB=0
  echo -n "Testing: ${CURRENT_TEST_LABEL} ... "
}

_test_sub_result() {
  # Function to process a test sub-result.
  # ${1} - the sub-test result 0|1
  # ${2} - the sub-test label to display

  # Increment the sub-test count, run the test and display the result.
  ((CURRENT_TEST_HAS_SUB++))
  [ 0 = "${1}" ] \
    && echo -en "\n  ... ${2} ... \033[032mPASSED\033[0m" \
    || echo -en "\n  ... ${2} ... \033[031mFAILED\033[0m"
}

_test_result() {
  # Function to process a test result.
  # ${1} - the test result 0|1

  local _result=""
  local _LABEL="${CURRENT_TEST_LABEL:-unknown test, call _test_start!}"

  # Display and log the test result.
  if [ 0 = "${1}" ]; then
    _result="\033[092mPASSED\033[0m"
    PASSED_TESTS+=("${_LABEL}")
  else
    _result="\033[091mFAILED\033[0m"
    FAILED_TESTS+=("${_LABEL}")
  fi

  # If there are sub-tests then display the overall result.
  [ 0 != "${CURRENT_TEST_HAS_SUB}" ] && echo -en "\n  ... overall result ... "
  echo -e "${_result}"
  
  # Reset the current test label and sub-test count.
  CURRENT_TEST_LABEL=""; CURRENT_TEST_HAS_SUB=0
}

#-------------------------------------------------------------------------------
# General test functionality.

test_section() {
  # Function to start a test section.
  # ${1} - the section label

  echo -e "\n=== Starting Tests: ${1}"
}

test_report_counts() {
  # Function to report the test counts.

  echo -en "\nTotal Tests = $((${#PASSED_TESTS[@]}+${#FAILED_TESTS[@]}))"
  [ 0 = "${#PASSED_TESTS[@]}" ] \
    || echo -en ", ${#PASSED_TESTS[@]} \033[092mPASSED\033[0m"
  [ 0 = "${#FAILED_TESTS[@]}" ] \
    || echo -en ", ${#FAILED_TESTS[@]} \033[091mFAILED\033[0m"
  echo ""
}

test_report_passed() {
  # Function to report the passed tests.

  echo -e "\nThe following tests \033[092mPASSED\033[0m:"
  printf '  %s\n' "${PASSED_TESTS[@]}"
}

test_report_failed() {
  # Function to report the failed tests.

  echo -e "\nThe following tests \033[091mFAILED\033[0m:"
  printf '  %s\n' "${FAILED_TESTS[@]}"
}

test_finish_return() {
  # Function to finish testing and return.

  [ 0 = "${#FAILED_TESTS[@]}" ] && return 0 || return 1
}

test_finish_exit() {
  # Function to finish testing and exit.

  [ 0 = "${#FAILED_TESTS[@]}" ] && exit 0 || exit 1
}

#-------------------------------------------------------------------------------
# Environment/OS tests etc.

check_env_exists() {
  # Function to check that an environment variable exists.
  # ${1} - the environment variable to check
  
  _test_start "env variable exists: ${1}"
  local _RESULT=1; [ -v "${1}" ] && _RESULT=0
  _test_result "${_RESULT}"
}

check_env_function_exists() {
  # Function to check that an environment function exists
  # ${1} - the environment function to check

  _test_start "env function exists: ${1}"
  # @note: bash -i means run in interactive mode, -c run the following command.
  local _RESULT=0; $(bash -ic "${1}" > /dev/null 2>&1)  || _RESULT=1
  _test_result "${_RESULT}"
}

check_env_not_blank() {
  # Function to check that an environment variable exists and is is not blank.
  # ${1} - the environment variable to check

  _test_start "env variable not blank: ${1}"
  local _RESULT=1; [ -n "${!1}" ] && _RESULT=0
  _test_result "${_RESULT}"
}

check_env_matches() {
  # Function to check that an environment matches the passed value.
  # ${1} - the environment variable to check
  # ${2} - the value to check against
  
  _test_start "env variable matches: ${1} = ${2}"
  local _RESULT=1; [ "${!1}" = "${2}" ] && _RESULT=0
  _test_result "${_RESULT}"
}

#-------------------------------------------------------------------------------
# File tests.

check_file_exists() {
  # Function to check that a file exists.
  # ${1} - the file path to check

  _test_start "file exists: ${1}"
  local _RESULT=1; [ -f "${1}" ] && _RESULT=0
  _test_result "${_RESULT}"
}

check_file_absent() {
  # Function to check that a file does not exist.
  # ${1} - the file path to check

  _test_start "file absent: ${1}"
  local _RESULT=1; [ ! -f "${1}" ] && _RESULT=0
  _test_result "${_RESULT}"
}

#-------------------------------------------------------------------------------
# Program test functions.

check_installed() {
  # Function to check for an installed program (and that it works as expected).
  # ${1} - the command, or path to it, to check
  # ${2..} - any extra checks to carry out

  local _PATH="${1}"; shift; local _RESULT=1
  local _LABEL="installed: ${_PATH}"; _test_start "${_LABEL}" "true"

  # Main file path/command exists check.
  [ -f "${_PATH}" ] || _PATH=$(which "${_PATH}")
  [ 0 != "${?}" ] || _RESULT=0
  _test_sub_result "${_RESULT}" "path exists ${_PATH}" \

  # Loop through all passed extra checks.
  local _EXPRESSION="${1}"
  while [ "" != "${_EXPRESSION}" ]; do
    [ 0 = "${_RESULT}" ] && ${_EXPRESSION} > /dev/null 2>&1 || _RESULT=1
    _test_sub_result "${_RESULT}" "${_EXPRESSION}"
    shift; _EXPRESSION="${1:-}"
  done

  # And finish the test.
  _test_result "${_RESULT}"
}
