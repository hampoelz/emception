#!/bin/bash

SRC=$(dirname $0)

pushd $SRC/demo
  npm install
  npm run build
popd


