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
  test [type]     Run tests for 'all' (default), 'features' or 'templates'
  docs [type]     Generate documentation for 'all' (default), 'features' or
                  'templates'
  package [type]  Package 'all' (default), 'features' or 'templates' in to the
                  'dist' directory.
  publish [type]  Publish 'all' (default), 'features' or 'templates' to ghcr.io.
  cp-test         Copies the master test.sh shell script to all feature and
                  template directories.
  cp-lib          Copies the master devcontainers shell library to all feature
                  and template directories.
  help            Show this help text.
"

# The prepend string used to mark automatically copied files.
COPY_PREPEND="
# @WARNING - This file is an automatically copied version of the master file
# which may be found in the scripts/lib/ directory of this repository.
"

# Switch on the command.
case "${_command:="${1:-}"}" in

  # Runs tests for features and/or templates.
  test)

    # Work out the test type and remove the argument(s) as necessary.
    _type=$(echo "${2:-NONE}" | tr '[:lower:]' '[:upper:]')
    shift; [ ! "NONE" = ${_type} ] && shift || _type="ALL"

    # Execute as necessary.
    if [ "ALL" = ${_type} ] || [ "FEATURES" = ${_type} ]; then
      devcontainer features test \
        --project-folder=./features \
        "${@}"
    fi
    if [ "ALL" = ${_type} ] || [ "TEMPLATES" = ${_type} ]; then
      devcontainer templates test \
        --project-folder=./templates \
        "${@}"
    fi
    ;;

  # Generates documentation for features and/or templates.
  docs)

    # Work out the documentation type and remove the argument(s) as necessary.
    _type=$(echo "${2:-NONE}" | tr '[:lower:]' '[:upper:]')
    shift; [ ! "NONE" = ${_type} ] && shift || _type="ALL"

    # Execute as necessary.
    if [ "ALL" = ${_type} ] || [ "FEATURES" = ${_type} ]; then
      devcontainer features generate-docs \
        --project-folder=./features/src \
        --namespace=jjs105/devcontainers
    fi
    if [ "ALL" = ${_type} ] || [ "TEMPLATES" = ${_type} ]; then
      devcontainer templates generate-docs \
        --project-folder=./templates/src
    fi
    ;;

  # Packages features and/or templates to the dist directory.
  package)

    # Work out the package type and remove the argument(s) as necessary.
    _type=$(echo "${2:-NONE}" | tr '[:lower:]' '[:upper:]')
    shift; [ ! "NONE" = ${_type} ] && shift || _type="ALL"

    # Execute as necessary.
    if [ "ALL" = ${_type} ] || [ "FEATURES" = ${_type} ]; then
      devcontainer features package \
        ./features/src \
        --force-clean-output-folder \
        --output-folder ./dist/features
    fi
    if [ "ALL" = ${_type} ] || [ "TEMPLATES" = ${_type} ]; then
      devcontainer templates publish \
        ./templates/src \
        --namespace jjs105/devcontainers/features
    fi
    ;;

  # Publish features and/or templates to ghcr.io.
  # @note: Could be merged into above command - in fact all are similar!
  publish)

    # Work out the package type and remove the argument(s) as necessary.
    _type=$(echo "${2:-NONE}" | tr '[:lower:]' '[:upper:]')
    shift; [ ! "NONE" = ${_type} ] && shift || _type="ALL"

    # Execute as necessary.
    if [ "ALL" = ${_type} ] || [ "FEATURES" = ${_type} ]; then
      devcontainer features publish \
        ./features/src \
        --namespace jjs105/devcontainers/features
    fi
    if [ "ALL" = ${_type} ] || [ "TEMPLATES" = ${_type} ]; then
      devcontainer templates publish \
        ./templates/src \
        --registry ghcr.io \
        --namespace jjs105/devcontainers/templates \
        --log-level trace
    fi
    ;;

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
        (echo "#!/bin/sh\n${COPY_PREPEND}"; tail -n +2 ${FILE_PATH}) \
          > ${dir}/test.sh
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
        (echo "${COPY_PREPEND}"; cat ${FILE_PATH}) \
          > ${dir}/devcontainers-lib.sh
      done
    done
    ;;    

  # Show help if asked and/or help command specified.
  help|*)
    echo "${USAGE}"
    ;;

esac