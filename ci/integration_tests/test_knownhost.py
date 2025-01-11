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
