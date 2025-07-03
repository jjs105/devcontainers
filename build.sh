#!/bin/sh
# @note: We use sh as a basis for this script as bash may not be installed - e.g
# Alpine.

# Exit on any failure, use +e to revert if necessary.
# @note: -x can be used for debugging purposes.
set -eu

# Set the working and build paths.
# @todo: Must be a better way to do this in sh.
WORKING_PATH="/workspaces/devcontainers"
BUILD_PATH="${WORKING_PATH}/build"

_prepare() {

  # Delete and/or copy all template and feature files.
  [ -d "${BUILD_PATH}" ] && rm -rf "${BUILD_PATH}"
  [ ! -d "${BUILD_PATH}" ] && mkdir "${BUILD_PATH}"
  cp -rt "${BUILD_PATH}" "${WORKING_PATH}/templates" "${WORKING_PATH}/features"

  # Loop through the features and templates.
  for type in features templates; do

    # Prepare the src directories.
    for dir in "${BUILD_PATH}/${type}"/src/*/; do
      [ -d "${dir}" ] && [ ! -L "${dir}" ] || continue

      # Check for an include file, copy contained paths and remove.
      [ -f "${dir}.include" ] || continue
      sed -e "s|^|${WORKING_PATH}|" "${dir}.include" | xargs cp -t "${dir}"
      rm "${dir}/.include"
    done

    # Prepare the test directories.
    for dir in "${BUILD_PATH}/${type}"/test/*/; do
      [ -d "${dir}" ] && [ ! -L "${dir}" ] || continue

      # If the test.sh script is bash based rename it and copy the Korne shell
      # test.sh stub file.

      # Check for an include file, copy contained paths and remove.
      [ -f "${dir}.include" ] || continue
      sed -e "s|^|${WORKING_PATH}|" "${dir}.include" | xargs cp -t "${dir}"
      rm "${dir}/.include"
    done
  done
}

_prepare