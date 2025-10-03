import os
from base64 import b64encode

from ssh2.exceptions import KnownHostDeleteError
from ssh2.knownhost import LIBSSH2_KNOWNHOST_TYPE_PLAIN, \
    LIBSSH2_KNOWNHOST_KEYENC_RAW, LIBSSH2_KNOWNHOST_KEY_SSHRSA
from ssh2.session import Session

from .base_test import SSH2TestCase


class KnownHostTestCase(SSH2TestCase):

    def setUp(self):
        self.session = Session()

    def test_knownhost_init(self):
        kh = self.session.knownhost_init()
        self.assertTrue(kh is not None)

    def test_knownhost_readfile_get(self):
        kh = self.session.knownhost_init()
        self.assertEqual(len(kh.get()), 0)
        _filename = os.sep.join([os.path.dirname(__file__),
                                 'known_hosts'])
        hosts_in_file = len(open(_filename).readlines())
        _read = kh.readfile(_filename)
        self.assertEqual(_read, hosts_in_file)
        keys = kh.get()
        self.assertTrue(keys is not None)
        self.assertEqual(len(keys), hosts_in_file)

    def test_knownhost_add_get_delete(self):
        kh = self.session.knownhost_init()
        key = b"""AAAAB3NzaC1yc2EAAAABIwAAAQEAxacIa5+3xbfETKwLFTMg1KBOQi4XR/Kz2rRqLRhyBNg1Dok56qA2d5l3O/uTOthWy4K8qfpVIzL8/pxdehc4gtC2gbpiBTJn4ofyS2PmXFV2fCeshk5x554l2AgIObz1G1SEAw3x09xd/+2dfQgv7NJ7PPzDHkD+ifS9sncFo6AWTmS6/7gX9QGrh1y3AGziMnMGWkD+sF7u/Mgr9g7794wBzGryzLLpSmbVKdQ4yM4TLodUeAL2aYUiiO8qLK+AIox/nWSd4uixsYuhdyqCdxEQPPkHIieLUsTiMcMQDiAZEkUvyU0lv37bzqsM4yhqnTxpKJD9xD7XkMKENZ6d7Q=="""
        type_mask = LIBSSH2_KNOWNHOST_TYPE_PLAIN | \
                    LIBSSH2_KNOWNHOST_KEYENC_RAW | \
                    LIBSSH2_KNOWNHOST_KEY_SSHRSA
        host = b'127.0.0.1'
        entry = kh.addc(host, key, type_mask)
        self.assertTrue(entry is not None)
        self.assertEqual(entry.name, host)
        self.assertEqual(entry.key, key)
        self.assertEqual(entry.typemask, type_mask)
        keys = kh.get()
        self.assertTrue(len(keys) == 1)
        entry = keys[0]
        self.assertEqual(entry.key, key)
        kh.delete(entry)
        self.assertTrue(len(kh.get()) == 0)
        self.assertRaises(KnownHostDeleteError, kh.delete, entry)
        self.assertTrue(kh.addc(
            host, key, type_mask, comment=b'a comment') is not None)

    def test_writefile(self):
        kh = self.session.knownhost_init()
        _filename = os.sep.join([os.path.dirname(__file__),
                                 'known_hosts'])
        hosts_in_file = open(_filename, 'rb').readlines()
        hosts_in_file_no = len(hosts_in_file)
        _read = kh.readfile(_filename)
        self.assertEqual(_read, hosts_in_file_no)
        write_file = os.sep.join([os.path.dirname(__file__),
                                  'written_hosts'])
        kh.writefile(write_file)
        try:
            lines = open(write_file, 'rb').readlines()
            self.assertEqual(len(lines), hosts_in_file_no)
            for host_entry in hosts_in_file:
                self.assertTrue(host_entry in lines)
        finally:
            try:
                os.unlink(write_file)
            except Exception:
                pass

    def test_add_writefile(self):
        kh = self.session.knownhost_init()
        key = b"""AAAAB3NzaC1yc2EAAAABIwAAAQEAxacIa5+3xbfETKwLFTMg1KBOQi4XR/Kz2rRqLRhyBNg1Dok56qA2d5l3O/uTOthWy4K8qfpVIzL8/pxdehc4gtC2gbpiBTJn4ofyS2PmXFV2fCeshk5x554l2AgIObz1G1SEAw3x09xd/+2dfQgv7NJ7PPzDHkD+ifS9sncFo6AWTmS6/7gX9QGrh1y3AGziMnMGWkD+sF7u/Mgr9g7794wBzGryzLLpSmbVKdQ4yM4TLodUeAL2aYUiiO8qLK+AIox/nWSd4uixsYuhdyqCdxEQPPkHIieLUsTiMcMQDiAZEkUvyU0lv37bzqsM4yhqnTxpKJD9xD7XkMKENZ6d7Q=="""
        type_mask = LIBSSH2_KNOWNHOST_TYPE_PLAIN | \
                    LIBSSH2_KNOWNHOST_KEYENC_RAW | \
                    LIBSSH2_KNOWNHOST_KEY_SSHRSA
        host = b'127.0.0.1'
        entry = kh.addc(host, key, type_mask)
        self.assertTrue(entry is not None)
        write_file = os.sep.join([os.path.dirname(__file__),
                                  'written_hosts'])
        kh.writefile(write_file)
        try:
            kh = self.session.knownhost_init()
            self.assertEqual(kh.readfile(write_file), 1)
            keys = kh.get()
            self.assertEqual(len(keys), 1)
            entry = keys[0]
            self.assertEqual(entry.key, key)
        finally:
            try:
                os.unlink(write_file)
            except Exception:
                pass

    def test_readline_writeline(self):
        line = b"""10.0.0.1 ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA8ZzI0FP2Q5DOAL0q/T8QPWmnz6sMxDOVQ34u4NUo4GZZ948RpeSIVA57hmLYWkq+Hx4idsCLyyvfkEzEieY4Zm5wDtjX5uInP695TrZHd2SmPJwwq3PYwdZfyCvkDyLC8VnKe1iKGdJ4sSiD83gIXLsvHzL6nZ4TiX+N4MXpxFHIh6yA6aSmYy5FIB8Gn5veU+XunmXxUQdwIhNRkQiK5laA3X3paDFlUAWFyeS40+B+IVAQnA655+7Nxza86Xe6PROmJvLefZlqR8W1EI73ea7AKSfZijqHzxbIJYCQIh3FfQXfiaC15xKnnslEZNTOkfCblawav5jL9sIuw3wO3w=="""
        kh = self.session.knownhost_init()
        kh.readline(line)
        keys = kh.get()
        self.assertEqual(len(keys), 1)
        entry = keys[0]
        self.assertTrue(b64encode(entry.key) in line)
        written_line = kh.writeline(entry).strip()
        self.assertEqual(line, written_line)
