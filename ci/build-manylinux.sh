#!/bin/bash -xe
# This file is part of ssh2-python.
# Copyright (C) 2017-2022 Panos Kittenis and contributors.
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation, version 2.1.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

docker_tag="parallelssh/ssh2-manylinux"
docker_files=("ci/docker/manylinux/Dockerfile" "ci/docker/manylinux/Dockerfile.2014_x86_64")

rm -rf build ssh2/libssh2.* ssh2/*.so
python ci/appveyor/fix_version.py .

if [[ $(uname -m) == "aarch64" ]]; then
    docker_tag="${docker_tag}:aarch64"
    docker_files=("ci/docker/manylinux/Dockerfile.aarch64")
fi

for docker_file in "${docker_files[@]}"; do
    if [[ ${docker_file} == "ci/docker/manylinux/Dockerfile.2014_x86_64" ]]; then
        docker_tag="${docker_tag}:2014_x86_64"
    fi
    docker pull $docker_tag || echo
    docker build --pull --cache-from $docker_tag ci/docker/manylinux -t $docker_tag -f ${docker_file}
    if [[ -z "${CIRCLE_PULL_REQUEST}" ]]; then docker push $docker_tag; fi
    docker run --rm -v "$(pwd)":/io $docker_tag /io/ci/build-wheels.sh
    ls wheelhouse/
done
