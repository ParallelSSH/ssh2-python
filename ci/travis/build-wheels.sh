#!/bin/bash -xe

# Compile wheels
# For testing
for PYBIN in `ls -1d /opt/python/cp27-cp27m/bin | grep -v cpython`; do
# for PYBIN in `ls -1d /opt/python/*/bin | grep -v cpython`; do
    "${PYBIN}/python" ci/appveyor/fix_version.py .
    "${PYBIN}/pip" wheel /io/ -w wheelhouse/
done

# Bundle external shared libraries into the wheels
for whl in wheelhouse/*.whl; do
    auditwheel repair "$whl" -w /io/wheelhouse/
done

# Install packages and test
# for PYBIN in `ls -1d /opt/python/*/bin | grep -v cpython`; do
for PYBIN in `ls -1d /opt/python/cp27-cp27m/bin | grep -v cpython`; do
    "${PYBIN}/pip" install ssh2-python --no-index -f /io/wheelhouse
    (cd "$HOME"; "${PYBIN}/python" -c 'from ssh2.session import Session; Session()')
done
