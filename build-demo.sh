#!/bin/bash
set -e

export $(cat .env | xargs)

SRC=$(dirname $0)

pushd $SRC/demo-monaco
  npm install
  npm run build
popd


