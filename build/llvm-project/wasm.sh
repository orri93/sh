#!/bin/bash

GOS_PROJECT_NAME="LLVM WASM"

GOS_PROJECT_SRC_DIR=/opt/src/llvm-project/llvm
GOS_PROJECT_BUILD_DIR=/opt/build/llvm-project/wasm
GOS_CMAKE_OPT="-DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_PROJECTS='lld;clang' -DLLVM_TARGETS_TO_BUILD='host;WebAssembly' -DLLVM_INCLUDE_EXAMPLES=OFF -DLLVM_INCLUDE_TESTS=OFF -G Ninja"

GOS_CMAKE=cmake
GOS_CTEST=ctest

die() {
  printf '%s\n' "$1" >&2
  exit 1
}

show_help() {
cat << EOF
Usage: ${0##*/} [-h] [-nc]
Build the LLVM WASM

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

# Resolve the Current Script Directory
# https://stackoverflow.com/questions/59895/how-to-get-the-source-directory-of-a-bash-script-from-within-the-script-itself
#!/bin/bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  TARGET="$(readlink "$SOURCE")"
  if [[ $TARGET == /* ]]; then
    echo "SOURCE '$SOURCE' is an absolute symlink to '$TARGET'"
    SOURCE="$TARGET"
  else
    DIR="$( dirname "$SOURCE" )"
    echo "SOURCE '$SOURCE' is a relative symlink to '$TARGET' (relative to '$DIR')"
    SOURCE="$DIR/$TARGET" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
  fi
done
echo "SOURCE is '$SOURCE'"
RDIR="$( dirname "$SOURCE" )"
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
if [ "$DIR" != "$RDIR" ]; then
  echo "DIR '$RDIR' resolves to '$DIR'"
fi
echo "DIR is '$DIR'"

# Silent pushd and popd
silent_pushd () {
  command pushd "$@" > /dev/null
}
silent_popd () {
  command popd "$@" > /dev/null
}

#GOS_ROOT_DIR=`readlink -f "$DIR/.."`
GOS_ROOT_DIR=`realpath "$DIR/.."`

echo "---------------------------------------------------------------------------"
echo "Build script for the ${GOS_PROJECT_NAME} project"
echo "${GOS_PROJECT_NAME} root directory is defined as ${GOS_ROOT_DIR}"

echo "*** Generate build"
GOS_GENERATE_BUILD_CMD="${GOS_CMAKE} -E chdir ${GOS_PROJECT_BUILD_DIR} ${GOS_CMAKE} ${GOS_CMAKE_OPT} ${GOS_PROJECT_SRC_DIR}"
echo "${GOS_GENERATE_BUILD_CMD}"
${GOS_GENERATE_BUILD_CMD}

echo "*** Build"
GOS_BUILD_CMD="${GOS_CMAKE} --build ${GOS_PROJECT_BUILD_DIR}"
echo "${GOS_BUILD_CMD}"
${GOS_BUILD_CMD}

