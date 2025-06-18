#!/bin/bash
set -e

app=dasmlab-security-suite
version=latest
ARCH="amd64"

docker build -t ${app}:${version} \
  --build-arg ARCH=$ARCH \
  -f Dockerfile .

