#!/bin/bash


ARCH=$(uname -m)
: ${DH_NAME=cromarty}
REPOSITORY="${DH_NAME}/rpi-archlinux-${ARCH}-mongodb"
: ${TAG:=1.0.0}
IMAGE=${REPOSITORY}:${TAG}

echo "${IMAGE}"

docker build -t "${IMAGE}" .

