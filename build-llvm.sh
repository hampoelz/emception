#!/bin/bash
set -e

export $(cat .env | xargs)

SRC=$(dirname $0)

BUILD="$1"
LLVM_SRC="$2"

if [ "$LLVM_SRC" == "" ]; then
    LLVM_SRC=$(pwd)/upstream/llvm-project
fi

if [ "$BUILD" == "" ]; then
    BUILD=$(pwd)/build
fi

SRC=$(realpath "$SRC")
BUILD=$(realpath "$BUILD")
LLVM_BUILD=$BUILD/llvm
LLVM_NATIVE=$BUILD/llvm-native

# todo check every run if the current llvm commit is the same as the one in the .env file and the patch is applied
# If we don't have a copy of LLVM, make one
if [ ! -d $LLVM_SRC/ ]; then
    git clone --depth 1 https://github.com/llvm/llvm-project.git "$LLVM_SRC/"

    pushd $LLVM_SRC/
    git fetch origin $LLVM_COMMIT
    git reset --hard $LLVM_COMMIT

    # The clang driver will sometimes spawn a new process to avoid memory leaks.
    # Since this complicates matters quite a lot for us, just disable that.
    git apply $SRC/patches/llvm-project.patch
    popd
fi

# todo: create a way to reconfigure if the folder exists
# Cross compiling llvm needs a native build of "llvm-tblgen" and "clang-tblgen"
# if [ ! -d $LLVM_NATIVE/ ]; then
#     echo "Configuring LLVM_NATIVE"
#     cmake -G Ninja \
#         -S $LLVM_SRC/llvm/ \
#         -B $LLVM_NATIVE/ \
#         -DCMAKE_BUILD_TYPE=Release \
#         -DLLVM_TARGETS_TO_BUILD=WebAssembly \
#         -DLLVM_ENABLE_PROJECTS="clang"
# fi
# cmake --build $LLVM_NATIVE/ -- llvm-tblgen clang-tblgen

# todo: create a way to reconfigure if the folder exists
if [ ! -d $LLVM_BUILD/ ]; then
    echo "Configuring LLVM_BUILD"
    CXXFLAGS="-Dwait4=__syscall_wait4" \
    LDFLAGS="\
        -s LLD_REPORT_UNDEFINED=1 \
        -s ALLOW_MEMORY_GROWTH=1 \
        -s EXPORTED_FUNCTIONS=_main,_free,_malloc \
        -s EXPORTED_RUNTIME_METHODS=FS,PROXYFS,ERRNO_CODES,allocateUTF8 \
        -lproxyfs.js \
        --js-library=$SRC/emlib/fsroot.js \
    " emcmake cmake -G Ninja \
        -S $LLVM_SRC/llvm/ \
        -B $LLVM_BUILD/ \
        -DCMAKE_BUILD_TYPE=Release \
        -DLLVM_ENABLE_LIBXML2=OFF \
        -DLLVM_ENABLE_LLD=ON \
        -DLLVM_ENABLE_PROJECTS="lld;clang" \
        -DLLVM_ENABLE_ASSERTIONS=ON \
        -DLLVM_TARGETS_TO_BUILD=WebAssembly \
        -DLLVM_INCLUDE_EXAMPLES=OFF \
        -DLLVM_INCLUDE_TESTS=OFF
        #-DLLVM_ENABLE_DUMP=OFF \
        #-DLLVM_ENABLE_ASSERTIONS=OFF \
        #-DLLVM_ENABLE_EXPENSIVE_CHECKS=OFF \
        #-DLLVM_ENABLE_BACKTRACES=OFF \
        #-DLLVM_ENABLE_THREADS=OFF \
        #-DLLVM_BUILD_TOOLS=OFF \
        #-DLLVM_BUILD_LLVM_DYLIB=OFF \
        #-DLLVM_TABLEGEN=$LLVM_NATIVE/bin/llvm-tblgen \
        #-DCLANG_TABLEGEN=$LLVM_NATIVE/bin/clang-tblgen

    echo "Patching build.ninja"
    # Make sure we build js modules (.mjs).
    # The patch-ninja.sh script assumes that.
    sed -E 's/\.js/.mjs/g' $LLVM_BUILD/build.ninja > /tmp/build.ninja
    mv /tmp/build.ninja $LLVM_BUILD/build.ninja

    # The mjs patching is over zealous, and patches some source JS files rather than just output files.
    # Undo that.
    sed -E 's/(pre|post|proxyfs|fsroot)\.mjs/\1.js/g' $LLVM_BUILD/build.ninja > /tmp/build.ninja
    mv /tmp/build.ninja $LLVM_BUILD/build.ninja

    # fix wrong strange bug that generates 'ninja_required_version1.5' instead of 'ninja_required_version = 1.5'
    sed -E 's/ninja_required_version1\.5/ninja_required_version = 1.5/g' $LLVM_BUILD/build.ninja > /tmp/build.ninja
    mv /tmp/build.ninja $LLVM_BUILD/build.ninja

    # Patch the build script to add the "llvm-box" target.
    # This new target bundles many executables in one, reducing the total size.
    pushd $SRC
    TMP_FILE=$(mktemp)
    ./patch-ninja.sh \
        $LLVM_BUILD/build.ninja \
        llvm-box \
        $BUILD/tooling \
        clang lld llvm-nm llvm-ar llvm-objcopy llc \
        > $TMP_FILE
    cat $TMP_FILE >> $LLVM_BUILD/build.ninja
    popd

    # fix wrong strange bug that generates 'ninja_required_version1.5' instead of 'ninja_required_version = 1.5'
    sed -E 's/ninja_required_version1\.5/ninja_required_version = 1.5/g' $LLVM_BUILD/build.ninja > /tmp/build.ninja
    mv /tmp/build.ninja $LLVM_BUILD/build.ninja
fi

# llvm is memory hungry, so only use 2 threads instead of the default 4
# todo: detect memory and use more threads if we have enough
cmake --build $LLVM_BUILD/ --parallel -- llvm-box
