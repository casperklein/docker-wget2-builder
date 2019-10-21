#!/bin/bash

set -ueo pipefail

APP=$(grep APP= Dockerfile | cut -d'"' -f2)
USER="casperklein"
NAME="$APP-builder"
TAG=$(grep VERSION= Dockerfile | cut -d'"' -f2)
IMAGE="$USER/$NAME:$TAG"

DIR=${0%/*}
cd "$DIR"

echo "Building $APP $TAG"
echo 
docker build -t "$IMAGE" .
echo

echo "Copy $APP $TAG debian package to $(pwd)/"
docker run --rm -v "$(pwd)":/mnt/ "$IMAGE"
echo
