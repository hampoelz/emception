#!/bin/bash
set -e

export $(cat .env | xargs)

SRC=$(dirname $0)
BUILD="$1"

if [ "$BUILD" == "" ]; then
    mkdir -p $(pwd)/build
    BUILD=$(pwd)/build
fi

SRC=$(realpath "$SRC")
BUILD=$(realpath "$BUILD")

mkdir -p "$BUILD/emsdk_cache"

echo "#Building Tooling:"
$SRC/build-tooling.sh "$BUILD"

echo "#Building LLVM:"
$SRC/build-llvm.sh "$BUILD" "$LLVM_SRC"

echo "#Building Binaryen:"
$SRC/build-binaryen.sh "$BUILD" "$BINARYEN_SRC"

echo "#Building CPython:"
$SRC/build-cpython.sh "$BUILD" "$CPYTHON_SRC"

echo "#Building Quicknode:"
$SRC/build-quicknode.sh "$BUILD" "$QUICKNODE_SRC"

echo "#Building Brotli:"
$SRC/build-brotli.sh "$BUILD" "$BROTLI_SRC"

echo "#Building Emception:"
$SRC/build-emception.sh "$BUILD"

# todo: make it work on only one shot!
echo "#Building Demo"
$SRC/build-demo.sh "$BUILD"