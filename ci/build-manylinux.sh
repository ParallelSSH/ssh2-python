#!/bin/bash -xe

docker_tag="parallelssh/ssh2-manylinux"
docker_files=("ci/docker/manylinux/Dockerfile" "ci/docker/manylinux/Dockerfile.2014_x86_64")

rm -rf build ssh2/libssh2.* ssh2/*.so
python ci/appveyor/fix_version.py .

if [[ `uname -m` == "aarch64" ]]; then
    docker_tag="${docker_tag}:aarch64"
    docker_files=("ci/docker/manylinux/Dockerfile.aarch64")
fi

for docker_file in ${docker_files[@]}; do
    if [[ ${docker_file} == "ci/docker/manylinux/Dockerfile_2014_x86_64" ]]; then
        docker_tag = "${docker_tag}:2014_x86_64"
    fi
    docker pull $docker_tag || echo
    docker build --pull --cache-from $docker_tag ci/docker/manylinux -t $docker_tag -f ${docker_file}
    if [[ -z "$CIRCLE_PR_NUMBER" ]]; then docker push $docker_tag; fi
    docker run --rm -v `pwd`:/io $docker_tag /io/ci/build-wheels.sh
    ls wheelhouse/
done
