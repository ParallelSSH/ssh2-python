#!/bin/bash -xe

for x in `ls -1d ci/docker/{fedora,centos}*`; do
    name=`echo "$x" | awk -F/ '{print $3}'`
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
    # docker push $docker_tag
    sudo rm -rf build dist
    # Fix version used by versioneer to current git tag so the generated .c files
    # do not cause a version change.
    python ci/appveyor/fix_version.py .
    # C files need re-generating
    sudo rm -f ssh2/*.c
    docker run -v "$(pwd):/src/" "$name" fpm --rpm-dist $dist -s python -t rpm -d libssh2 -d python setup.py
done

for x in `ls -1d ci/docker/{debian,ubuntu}*`; do
    name=`echo "$x" | awk -F/ '{print $3}' | awk -F. '{print $1}'`
    docker_tag="parallelssh/ssh2-python:$name"
    docker pull $docker_tag || echo
    docker build --cache-from $docker_tag $x -t $name
    docker tag $name $docker_tag
    # docker push $docker_tag
    sudo rm -rf build dist
    # Fix version used by versioneer to current git tag so the generated .c files
    # do not cause a version change.
    python ci/appveyor/fix_version.py .
    # C files need re-generating
    sudo rm -f ssh2/*.c
    docker run -v "$(pwd):/src/" "$name" fpm --iteration $name -s python -t deb -d libssh2-1 -d python setup.py
done

sudo chown -R ${USER} *

ls -ltrh *.{rpm,deb}

for x in *.rpm; do
    echo "Package: $x"
    rpm -qlp $x
done

for x in *.deb; do
    echo "Package: $x"
    dpkg-deb -c $x
done

echo "Modified files should be reset now -- run 'git checkout -- .' to do so for all files in the repository."
