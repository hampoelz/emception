#!/bin/bash
set -e

export $(cat .env | xargs)

SRC=$(dirname $0)
SRC=$(realpath "$SRC")

echo "Building docker image"
pushd $SRC/docker
docker build \
    -t emception_build \
    --build-arg EMSCRIPTEN_VERSION=$EMSCRIPTEN_VERSION \
    .
popd

mkdir -p $(pwd)/build/emsdk_cache

docker run \
    -i --rm \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v $(pwd):$(pwd) \
    -v $(pwd)/build/emsdk_cache:/emsdk/upstream/emscripten/cache \
    emception_build \
    bash -c "cd $(pwd) && ./build.sh"

#./build-demo.sh