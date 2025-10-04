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
SYSTEM_LIBSSH2_DIR="/opt/homebrew/opt/libssh2/lib"
MY_LIBSSH2_DIR="build_dir/src/"
LIBSSH2_INCLUDE_DIR="/opt/homebrew/opt/libssh2/include"
export CPPFLAGS="-I${LIBSSH2_INCLUDE_DIR}"
sudo cp -a libssh2/include/* /opt/homebrew/opt/libssh2/include/

pip3 install -U virtualenv
python3 -m virtualenv -p "$(which python3)" venv

set +x
source venv/bin/activate
set -x

python -V
pip3 install -U setuptools pip
pip3 install -U delocate wheel
python3 setup.py bdist_wheel
sudo cp -a ${MY_LIBSSH2_DIR}/libssh2* ${SYSTEM_LIBSSH2_DIR}/
ls -lhtr ${SYSTEM_LIBSSH2_DIR}

delocate-listdeps dist/*.whl
delocate-wheel -v -w wheels dist/*.whl
delocate-listdeps wheels/*.whl

ls -l wheels/*.whl
rm -f ${SYSTEM_LIBSSH2_DIR}/libssh2*
rm -f ${MY_LIBSSH2_DIR}/libssh2*
pip3 install -v wheels/*.whl
pwd; mkdir -p temp; cd temp; pwd
python3 -c "from ssh2.session import Session; Session()" && echo "Import successful"
cd ..; pwd
set +x
deactivate
set -x
