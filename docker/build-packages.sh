#!/bin/bash -xe

for x in `ls -1d docker/{fedora,centos}*`; do
    name=`echo "$x" | awk -F/ '{print $2}'`
    dist_num=`echo "$name" | sed -r 's/[a-z]+([0-9]+)/\1/'`
    docker_tag="parallelssh/ssh2-python:$name"
    if [[ $dist_num -gt 20 ]]; then
	dist="fc${dist_num}"
    else
	dist="el${dist_num}"
    fi
    docker pull $docker_tag || echo
    docker build --cache-from $docker_tag $x -t $name
    docker tag $name $docker_tag
    docker push $docker_tag
    docker run -v "$(pwd):/src/" "$name" --rpm-dist $dist -s python -t rpm setup.py
done

for x in `ls -1d docker/{debian,ubuntu}*`; do
    name=`echo "$x" | awk -F/ '{print $2}' | awk -F. '{print $1}'`
    docker_tag="parallelssh/ssh2-python:$name"
    docker pull $docker_tag || echo
    docker build --cache-from $docker_tag $x -t $name
    docker tag $name $docker_tag
    docker push $docker_tag
    docker run -v "$(pwd):/src/" "$name" --iteration $name -s python -t deb setup.py
done
