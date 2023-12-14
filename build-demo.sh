#!/bin/bash
set -e

export $(cat .env | xargs)

SRC=$(dirname $0)

pushd $SRC/demo
  npm install
  npm run build
popd
