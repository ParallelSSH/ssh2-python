import unittest
import pwd
import os
import socket
from sys import version_info

from .embedded_server.openssh import OpenSSHServer
from ssh2.session import Session
from ssh2.exceptions import SSH2Error


PKEY_FILENAME = os.path.sep.join([os.path.dirname(__file__), 'unit_test_key'])
PUB_FILE = "%s.pub" % (PKEY_FILENAME,)


class SSH2TestCase(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        _mask = int('0600') if version_info <= (2,) else 0o600
        os.chmod(PKEY_FILENAME, _mask)
        cls.server = OpenSSHServer()
        cls.server.start_server()

    @classmethod
    def tearDownClass(cls):
        cls.server.stop()
        del cls.server

    def setUp(self):
        self.host = '127.0.0.1'
        self.port = 2222
        self.cmd = 'echo me'
        self.resp = u'me'
        self.user_key = PKEY_FILENAME
        self.user_pub_key = PUB_FILE
        self.user = pwd.getpwuid(os.geteuid()).pw_name
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.connect((self.host, self.port))
        self.sock = sock
        self.session = Session()
        try:
            self.session.handshake(self.sock)
        except SSH2Error as e:
            print('libssh2>', e, self.session.last_error())
            raise

    def tearDown(self):
        self.session.disconnect()
        self.sock.close()

    def _auth(self):
        return self.session.userauth_publickey_fromfile(
            self.user, self.user_key)
