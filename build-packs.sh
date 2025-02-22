#!/bin/bash
set -e

export $(cat .env | xargs)

SRC=$(dirname $0)
BUILD="$1"

if [ "$BUILD" == "" ]; then
    BUILD=$(pwd)/build
fi

SRC=$(realpath "$SRC")
BUILD=$(realpath "$BUILD")

if [ ! -d $BUILD/packs/ ]; then
    mkdir -p $BUILD/packs/
fi

echo "build pack emscripten"
$SRC/packs/emscripten/package.sh $BUILD

echo "build pack cpython"
$SRC/packs/cpython/package.sh $BUILD

echo "build pack wasm"
$SRC/packs/wasm/package.sh $BUILD
