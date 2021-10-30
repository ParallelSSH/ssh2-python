#!/bin/bash -xe

docker_tag="parallelssh/ssh2-manylinux"
docker_file="ci/docker/manylinux/Dockerfile"

rm -rf build ssh2/libssh2.*
python ci/appveyor/fix_version.py .

if [[ `uname -m` == "aarch64" ]]; then
    docker_tag=${docker_tag}-aarch64
    docker_file=${docker_file}.aarch64
fi

docker pull $docker_tag || echo
docker build --cache-from $docker_tag ci/docker/manylinux -t $docker_tag -f ${docker_file}
if [[ "$TRAVIS_PULL_REQUEST" == "false" ]]; then docker push $docker_tag; fi
docker run -e TRAVIS_TAG="$TRAVIS_TAG" --rm -v `pwd`:/io $docker_tag /io/ci/travis/build-wheels.sh
ls wheelhouse/
