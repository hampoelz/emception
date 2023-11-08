#!/bin/bash

SRC=$(dirname $0)
BUILD="$1"

if [ "$BUILD" == "" ]; then
    BUILD="."
fi

# force clang to be the first
PATH="${EMSDK}/upstream/bin:${PATH}"

WASM_UTILS="$SRC/../wasm-utils"

SRC=$(realpath $SRC)
BUILD=$(realpath $BUILD)
WASM_UTILS=$(realpath $WASM_UTILS)

clang++ -O3 -I$WASM_UTILS -std=c++20 $WASM_UTILS/*.cpp $SRC/wasm-package.cpp -o $BUILD/wasm-package
