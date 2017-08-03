#!/bin/bash -xe

for x in `ls -1d docker/centos*`; do
    name=`echo "$x" | awk -F/ '{print $2}'`
    dist_num=`echo "$name" | sed -r 's/[a-z]+([0-9]+)/\1/'`
    if [[ $dist_num > 20 ]]; then
	dist="f${dist_num}"
    else
	dist="el${dist_num}"
    fi
    echo docker build $x -t $name
    echo docker run -v "$(pwd):/src/" "$name" --rpm-dist $dist -s python -t rpm setup.py
done

for x in `ls -1d docker/{debian,ubuntu}*`; do
    name=`echo "$x" | awk -F/ '{print $2}'`
    echo docker build $x -t "$x"
    echo docker run -v "$(pwd):/src/" "$name" --iteration $name -s python -t deb setup.py
done
