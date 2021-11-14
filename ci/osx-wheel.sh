#!/bin/bash -xe

pip3 install -U virtualenv
python3 -m virtualenv -p "$(which python3)" venv

set +x
source venv/bin/activate
set -x

python -V
pip3 install -U setuptools pip
pip3 install -U delocate wheel
SYSTEM_LIBSSH2=1 python3 setup.py bdist_wheel
ls -lhtr /usr/local/lib/
delocate-listdeps dist/*.whl
delocate-wheel -v -w wheels dist/*.whl
delocate-listdeps wheels/*.whl

ls -l wheels/*.whl
rm -f /usr/local/lib/libssh2*
pip3 install -v wheels/*.whl
pwd; mkdir -p temp; cd temp; pwd
python3 -c "from ssh2.session import Session; Session()" && echo "Import successful"
cd ..; pwd
set +x
deactivate
set -x
