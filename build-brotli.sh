#!/bin/bash
set -e

export $(cat .env | xargs)

SRC=$(dirname $0)

BUILD="$1"
BROTLI_SRC="$2"

if [ "$BROTLI_SRC" == "" ]; then
    BROTLI_SRC=$(pwd)/upstream/brotli
fi

if [ "$BUILD" == "" ]; then
    BUILD=$(pwd)/build
fi

SRC=$(realpath "$SRC")
BUILD=$(realpath "$BUILD")
BROTLI_BUILD=$BUILD/brotli

# If we don't have a copy of binaryen, make one
if [ ! -d $BROTLI_SRC/ ]; then
    git clone --depth 1 https://github.com/google/brotli.git "$BROTLI_SRC/"

    pushd $BROTLI_SRC/
    git fetch origin $BROTLI_COMMIT
    git reset --hard $BROTLI_COMMIT
    popd
fi

# todo: create a way to reconfigure if the folder exists
if [ ! -d $BROTLI_BUILD/ ]; then
    CFLAGS="-flto" \
    LDFLAGS="\
        -flto \
        -s ALLOW_MEMORY_GROWTH=1 \
        -s EXPORTED_FUNCTIONS=_main,_free,_malloc \
        -s EXPORTED_RUNTIME_METHODS=FS,PROXYFS,ERRNO_CODES,allocateUTF8 \
        -lproxyfs.js \
        --js-library=$SRC/emlib/fsroot.js \
    " emcmake cmake -G Ninja \
        -S $BROTLI_SRC/ \
        -B $BROTLI_BUILD/ \
        -DCMAKE_BUILD_TYPE=Release
    
    # Make sure we build js modules (.mjs).
    sed -E 's/brotli\.js/brotli\.mjs/g' $BROTLI_BUILD/build.ninja > /tmp/build.ninja
    mv /tmp/build.ninja $BROTLI_BUILD/build.ninja

    # The mjs patching is over zealous, and patches some source JS files rather than just output files.
    # Undo that.
    #sed -i -E 's/(pre|post|proxyfs|fsroot)\.mjs/\1.js/g' $BROTLI_BUILD/build.ninja
fi
cmake --build $BROTLI_BUILD/ -- brotli.mjs

# the build script for brotli doesn't create a `bin` folder like binaryen or llvm
# so lets create and populate one
mkdir -p $BROTLI_BUILD/bin
cp $BROTLI_BUILD/brotli.{mjs,wasm} $BROTLI_BUILD/bin
