#!/usr/bin/env bash

# Example
#
# build.sh /path/to/defconfig /path/to/build/dir

set -e

export OPEN_ATLAS_URL="https://codeload.github.com/xianyi/OpenBLAS/tar.gz/v0.3.10"

echo "BUILD: " $*

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


BASE_CONFIG=$1
WORK_DIR=$2

echo BASE_CONFIG: $BASE_CONFIG
echo WORK_DIR: $WORK_DIR

if [[ -z $BASE_CONFIG ]] || [[ -z $WORK_DIR ]]; then
    echo "build.sh <defconfig> <work directory>"
    exit 1
fi

ARTIFACT_NAME=$(basename "$WORK_DIR")

READLINK=readlink
BUILD_ARCH=$(uname -m)
BUILD_OS=$(uname -s)

if [[ $BUILD_OS = "CYGWIN_NT-6.1" ]]; then
    # A simple Cygwin looks better.
    BUILD_OS="cygwin"
elif [[ $BUILD_OS = "Darwin" ]]; then
    # Make sure that we use GNU readlink on OSX
    READLINK=greadlink
fi
BUILD_OS=$(echo "$BUILD_OS" | awk '{print tolower($0)}')

if [[ -z $HOST_ARCH ]]; then
    HOST_ARCH=$BUILD_ARCH
fi
if [[ -z $HOST_OS ]]; then
    HOST_OS=$BUILD_OS
fi

echo HOST_ARCH: $HOST_ARCH
echo HOST_OS: $HOST_OS

# Ensure that the config and work paths are absolute
BASE_CONFIG=$($READLINK -f "$BASE_CONFIG")
WORK_DIR=$($READLINK -f "$WORK_DIR")

if [[ ! -e $BASE_CONFIG ]]; then
    echo "Can't find $BASE_CONFIG. Check that it exists."
    exit 1
fi

DL_DIR=$HOME/.nerves/dl

env | sort >> /tmp/build-env.log

curl $OPEN_ATLAS_URL -o $DL_DIR/OpenBLAS-v0.3.10.tar.gz
