import unittest
import pwd
import os
import socket

from ssh2 import Session
from embedded_server.openssh import OpenSSHServer


PKEY_FILENAME = os.path.sep.join([os.path.dirname(__file__), 'unit_test_key'])

# ssh_logger.setLevel(logging.DEBUG)
# logging.basicConfig()


class SSH2TestCase(unittest.TestCase):

    def __init__(self, methodname):
        unittest.TestCase.__init__(self, methodname)
        self.fake_cmd = 'echo me'
        self.fake_resp = 'me'
        self.user_key = PKEY_FILENAME
        self.host = '127.0.0.1'
        self.port = 2222
        self.server = OpenSSHServer()
        self.server.start_server()
        self.user = pwd.getpwuid(os.geteuid()).pw_name

    def setUp(self):
        self.session = Session()
        # Make socket, connect
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.connect((self.host, self.port))
        self.sock = sock

    def test_fromfile_auth(self):
        self.session.handshake(self.sock)
        rc = self.session.userauth_publickey_fromfile(
            self.user, PKEY_FILENAME + ".pub", PKEY_FILENAME,
            '')
        self.assertEqual(rc, 0)
        self.assertTrue(self.session.userauth_authenticated())

    def test_auth_list(self):
        self.session.handshake(self.sock)
        auth_list = self.session.userauth_list(self.user)
        expected = [b'publickey', b'password', b'keyboard-interactive']
        self.assertListEqual(auth_list, expected)
