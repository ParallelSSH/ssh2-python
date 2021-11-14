#!/bin/bash -xe

echo "Travis tag: $TRAVIS_TAG"

# Compile wheels
# For testing
# for PYBIN in `ls -1d /opt/python/cp36-cp36m/bin | grep -v cpython`; do
for PYBIN in `ls -1d /opt/python/*/bin | grep -v cpython`; do
    "${PYBIN}/pip" wheel /io/ -w wheelhouse/
done

# Bundle external shared libraries into the wheels
for whl in wheelhouse/*.whl; do
    auditwheel repair "$whl" -w /io/wheelhouse/
done

# Install packages and test
if [[ ! -z "$TRAVIS_TAG" ]]; then
    for PYBIN in `ls -1d /opt/python/*/bin | grep -v cpython`; do
        "${PYBIN}/pip" install ssh2-python --no-index -f /io/wheelhouse
        (cd "$HOME"; "${PYBIN}/python" -c 'from ssh2.session import Session; Session()')
    done
fi
