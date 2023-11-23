# This file is part of ssh2-python.
# Copyright (C) 2017-2021 Panos Kittenis and contributors.
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
import os

from sys import stderr
from subprocess import check_call
from glob import glob
from shutil import copy2


def build_ssh2():
    if bool(os.environ.get('SYSTEM_LIBSSH', False)):
        stderr.write("Using system libssh2..%s" % (os.sep))
        return
    if os.path.exists('/usr/local/opt/openssl'):
        os.environ['OPENSSL_ROOT_DIR'] = '/usr/local/opt/openssl'

    if not os.path.exists('build_dir'):
        os.mkdir('build_dir')

    os.chdir('build_dir')
    check_call('cmake ../libssh2 -DBUILD_SHARED_LIBS=ON \
    -DENABLE_ZLIB_COMPRESSION=ON -DENABLE_CRYPT_NONE=ON \
    -DENABLE_MAC_NONE=ON -DCRYPTO_BACKEND=OpenSSL \
    -DBUILD_EXAMPLES=OFF -DBUILD_TESTING=OFF',
               shell=True, env=os.environ)
    check_call('cmake --build . --config Release', shell=True, env=os.environ)
    os.chdir('..')

    for src in glob('build_dir/src/libssh2.so*'):
        copy2(src, 'ssh2/')
