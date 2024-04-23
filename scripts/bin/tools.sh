#!/bin/sh
# @note: We use sh as a basis for this script as bash may not be installed - e.g
# Alpine.

# Exit on any failure, use +e to revert if necessary.
# @note: -x can be used for debugging purposes.
set -eu

# Set the working path.
# @todo: Must be a better way to do this in sh.
WORKING_PATH=/workspaces/devcontainers

# Simple usage string.
USAGE="
Usage:
  ${0} <command>

Commands:
  cp-lib    Copies the master devcontainers shell library to all feature and
            template directories.
  help      Show this help text.
"

# The prepend string used to mark automatically copied files.
COPY_PREPEND="
# @WARNING - This file is an automatically copied version of the master file
# which may be found in the scripts/lib/ directory of this repository.
"

# Switch on the command.
case "${_command:="${1:-}"}" in

  # Generates `test.sh` files based on the master bootstrap file.
  # @note: This means the main test script can now utilise bash and should be
  # called `test.bash.sh`.
  cp-test)
    for type in features templates; do
      for dir in ${WORKING_PATH}/${type}/test/*/; do
        [ -d "${dir}" ] && [ ! -L "${dir}" ] || continue

        # Report and copy the test file including the top of file note.
        # @note: We need to place the note after the #! line at the start.
        echo "Copying test boostrap script to ${dir}"
        FILE_PATH=${WORKING_PATH}/scripts/lib/test.bootstrap.sh
        (echo "#!/bin/sh\n${COPY_PREPEND}"; tail -n +2 ${FILE_PATH}) > ${dir}/test.sh
      done
    done
    ;;

  # Copies the master development containers shell library into every template
  # and feature.
  cp-lib)

    # Loop through the features and templates.
    for type in features templates; do
      for dir in ${WORKING_PATH}/${type}/src/*/; do
        [ -d "${dir}" ] && [ ! -L "${dir}" ] || continue

        # Report and copy the library file including the prepended note.
        # @note: We can safely prepend as the library file does/should not have
        # the #! line at the start.
        echo "Copying development containers library to ${dir}"
        FILE_PATH=${WORKING_PATH}/scripts/lib/devcontainers-lib.sh
        (echo "${COPY_PREPEND}"; cat ${FILE_PATH}) > ${dir}/devcontainers-lib.sh
      done
    done
    ;;    

  # Show help if asked and/or help command specified.
  help) echo "${USAGE}" ;;
  *)    echo "${USAGE}" ;;

esac