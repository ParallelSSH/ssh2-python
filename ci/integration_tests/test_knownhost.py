#  This file is part of ssh2-python.
#  Copyright (C) 2017-2025 Panos Kittenis.
#  Copyright (C) 2017-2025 ssh2-python Contributors.
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation, version 2.1.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

import os

from ssh2.exceptions import KnownHostCheckError
from ssh2.knownhost import LIBSSH2_KNOWNHOST_TYPE_PLAIN, \
    LIBSSH2_KNOWNHOST_KEYENC_RAW, LIBSSH2_KNOWNHOST_KEY_SSHRSA, LIBSSH2_KNOWNHOST_KEY_SSHDSS
from ssh2.session import LIBSSH2_HOSTKEY_TYPE_RSA, LIBSSH2_HOSTKEY_HASH_SHA1

from .base_test import SSH2TestCase


class KnownHostTestCase(SSH2TestCase):
    def test_check(self):
        kh = self.session.knownhost_init()
        host_key, key_type = self.session.hostkey()
        key_type = LIBSSH2_KNOWNHOST_KEY_SSHRSA \
            if key_type in (
            LIBSSH2_HOSTKEY_TYPE_RSA,
            LIBSSH2_HOSTKEY_HASH_SHA1,
        ) else LIBSSH2_KNOWNHOST_KEY_SSHDSS
        type_mask = LIBSSH2_KNOWNHOST_TYPE_PLAIN | \
                    LIBSSH2_KNOWNHOST_KEYENC_RAW | \
                    key_type
        # Verification should fail before key is added
        self.assertRaises(
            KnownHostCheckError, kh.checkp, b'127.0.0.1', self.port,
            host_key, type_mask)
        server_known_hosts = os.sep.join([os.path.dirname(__file__),
                                          'embedded_server',
                                          'known_hosts'])
        self.assertEqual(kh.readfile(server_known_hosts), 1)
        entry = kh.checkp(b'127.0.0.1', self.port, host_key, type_mask)
        self.assertTrue(entry is not None)
