#!/bin/bash

GOS_PROJECT_NAME="Open 62541"

GOS_PROJECT_BUILD_DIR=/opt/build/open62541
GOS_PROJECT_SRC_DIR=/opt/src/open62541

GOS_CMAKE_OPT="-DCMAKE_BUILD_TYPE=Release -G Ninja"

GOS_CMAKE=cmake
GOS_CTEST=ctest

die() {
  printf '%s\n' "$1" >&2
  exit 1
}

show_help() {
cat << EOF
Usage: ${0##*/} [-h] [-nc]
Build the ${GOS_PROJECT_NAME}

     -h --help       display this help and exit
     -v              verbose mode. Can be used multiple times for increased
                     verbosity.
EOF
}

GOS_BUILD_NUMBER=0

# http://mywiki.wooledge.org/BashFAQ/035
while :; do
  case $1 in
    -h|-\?|--help)
      show_help      # Display a usage synopsis.
      exit
      ;;
    -nc|--no-clean|--not--clean)
      echo "Not Clean detected"
      GOS_NOT_CLEAN=NOT_CLEAN
      ;;
    -nb|--no-build|--not-build)
      GOS_NOT_BUILD=NOT_BUILD
      ;;
    -nd|--no_doc|--not-doc|--no_docs|--not-docs)
      GOS_BUILD_DOCS=OFF
      ;;
    -n|--build-number)
      GOS_BUILD_NUMBER=$2
      ;;
    --)              # End of all options.
      shift
      break
      ;;
    -?*)
      printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
      ;;
    *)               # Default case: No more options, so break out of the loop.
      break
  esac
  shift
done

echo "---------------------------------------------------------------------------"
echo "Build script for the ${GOS_PROJECT_NAME} project"
echo "${GOS_PROJECT_NAME} build directory is defined as ${GOS_PROJECT_BUILD_DIR}"
echo "${GOS_PROJECT_NAME} src directory is defined as ${GOS_PROJECT_SRC_DIR}"

echo "*** Generate build"
GOS_GENERATE_BUILD_CMD="${GOS_CMAKE} -E chdir ${GOS_PROJECT_BUILD_DIR} ${GOS_CMAKE} ${GOS_CMAKE_OPT} ${GOS_PROJECT_SRC_DIR}"
echo "${GOS_GENERATE_BUILD_CMD}"
${GOS_GENERATE_BUILD_CMD}

echo "*** Build"
GOS_BUILD_CMD="${GOS_CMAKE} --build ${GOS_PROJECT_BUILD_DIR}"
echo "${GOS_BUILD_CMD}"
${GOS_BUILD_CMD}

