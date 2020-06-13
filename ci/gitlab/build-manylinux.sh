#!/bin/sh

export DOCKER_TAG=red_m/redlibssh2
rm -rf build dist ssh2/libssh2.*

docker build -t $DOCKER_TAG ci/docker/manylinux_2010
docker run --rm -v `pwd`:/io $DOCKER_TAG /io/ci/gitlab/build-wheels.sh
ls wheelhouse/
