#!/bin/bash
set -e

export $(cat .env | xargs)

if [ "$(uname)" == "Darwin" ]; then
    alias nproc="sysctl -n hw.ncpu"
fi

SRC=$(dirname $0)

BUILD="$1"
CPYTHON_SRC="$2"

if [ "$CPYTHON_SRC" == "" ]; then
    CPYTHON_SRC=$(pwd)/upstream/cpython
fi

if [ "$BUILD" == "" ]; then
    BUILD=$(pwd)/build
fi

# to be safe and guarantee the folder exists
mkdir -p "$BUILD"

SRC=$(realpath "$SRC")
BUILD=$(realpath "$BUILD")
CPYTHON_BUILD=$BUILD/cpython
CPYTHON_NATIVE=$BUILD/cpython-native

# If we don't have a copy of cpython, make one
if [ ! -d $CPYTHON_SRC/ ]; then
    git clone --depth 1 -b emception https://github.com/InfiniBrains/cpython.git "$CPYTHON_SRC/"
fi

pushd $CPYTHON_SRC/

#    # This is the last tested commit of cpython.
#    # Feel free to try with a newer version
#    COMMIT=b8a9f13abb61bd91a368e2d3f339de736863050f
#    git fetch origin $COMMIT
#    git reset --hard $COMMIT

popd

# todo: create a way to reconfigure if the folder exists
if [ ! -d $CPYTHON_NATIVE/ ]; then
    # Rever the cpython patch in case this runs after the wasm version reconfigures it.
    pushd $CPYTHON_SRC/
#    git apply -R $SRC/patches/cpython.patch
    autoreconf -i
    popd

    mkdir -p $CPYTHON_NATIVE/

    pushd $CPYTHON_NATIVE/

    $CPYTHON_SRC/configure -C --host=x86_64-pc-linux-gnu --build=$($CPYTHON_SRC/config.guess) --with-suffix=""
    make -j$(nproc)

    popd
fi

# todo: create a way to reconfigure if the folder exists
if [ ! -d $CPYTHON_BUILD/ ]; then
    # Patch cpython to add a module to evaluate JS code.
    pushd $CPYTHON_SRC/
#    git apply $SRC/patches/cpython.patch
    autoreconf -i
    popd

    mkdir -p $CPYTHON_BUILD/

    pushd $CPYTHON_BUILD/

    # for compatibility reasons check if filesystem is case sensitive. if it is case sensitive set PYTHONEXE to python, if not set it to python.exe
    touch filename fileName
    if [ $(du -a file* | wc -l | xargs) -eq 2 ]; then
        PYTHONEXE=python
    else
        PYTHONEXE=python.exe
    fi
    rm -rf filename fileName
    echo $PYTHONEXE

    # Build cpython with asyncify support.
    # Disable sqlite3, zlib and bzip2, which cpython enables by default
    CONFIG_SITE=$CPYTHON_SRC/Tools/wasm/config.site-wasm32-emscripten \
    LIBSQLITE3_CFLAGS=" " \
    BZIP2_CFLAGS=" " \
    LDFLAGS="\
        -s ALLOW_MEMORY_GROWTH=1 \
        -s EXPORTED_FUNCTIONS=_main,_free,_malloc \
        -s EXPORTED_RUNTIME_METHODS=FS,PROXYFS,ERRNO_CODES,allocateUTF8 \
        -lproxyfs.js \
        --js-library=$SRC/emlib/fsroot.js \
    " emconfigure $CPYTHON_SRC/configure -C \
        --host=wasm32-unknown-emscripten \
        --build=$($CPYTHON_SRC/config.guess) \
        --with-emscripten-target=browser \
        --disable-wasm-dynamic-linking \
        --with-suffix=".mjs" \
        --disable-wasm-preload \
        --enable-wasm-js-module \
        --with-build-python=$CPYTHON_NATIVE/$PYTHONEXE \

    emmake make -j$(nproc)

    popd
fi

pushd $CPYTHON_BUILD/

emmake make -j$(nproc)

popd
