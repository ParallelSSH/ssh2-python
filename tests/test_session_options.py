import pwd
import os
import socket

from .base_test import SSH2TestCase, PKEY_FILENAME, PUB_FILE
from ssh2.session import Session, LIBSSH2_METHOD_COMP_CS, \
LIBSSH2_METHOD_COMP_SC, LIBSSH2_METHOD_CRYPT_CS, LIBSSH2_METHOD_CRYPT_SC, \
LIBSSH2_METHOD_KEX, LIBSSH2_METHOD_MAC_CS, LIBSSH2_METHOD_MAC_SC, \
LIBSSH2_METHOD_LANG_CS, LIBSSH2_METHOD_LANG_SC, LIBSSH2_METHOD_HOSTKEY, \
LIBSSH2_FLAG_SIGPIPE, LIBSSH2_FLAG_COMPRESS

import ssh2.exceptions as ssh2_exceptions


KEX_BTYES = b'curve25519-sha256,curve25519-sha256@libssh.org,' \
b'ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,' \
b'diffie-hellman-group-exchange-sha256,diffie-hellman-group16-sha512,' \
b'diffie-hellman-group18-sha512,diffie-hellman-group14-sha256,' \
b'diffie-hellman-group14-sha1'
HOSTKEY_BTYES = b'rsa-sha2-512,rsa-sha2-256,ssh-rsa,ecdsa-sha2-nistp256,' \
b'ssh-ed25519'
CIPTHERS_BTYES = b'chacha20-poly1305@openssh.com,aes128-ctr,aes192-ctr,' \
b'aes256-ctr,aes128-gcm@openssh.com,aes256-gcm@openssh.com'
MAC_BTYES = b'umac-64-etm@openssh.com,umac-128-etm@openssh.com,' \
b'hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,' \
b'hmac-sha1-etm@openssh.com,umac-64@openssh.com,umac-128@openssh.com,' \
b'hmac-sha2-256,hmac-sha2-512,hmac-sha1'
COMP_BTYES = b'zlib,zlib@openssh.com,none'


TEST_PREFERENCES = {
    LIBSSH2_METHOD_KEX: KEX_BTYES,
    LIBSSH2_METHOD_HOSTKEY: HOSTKEY_BTYES,
    LIBSSH2_METHOD_CRYPT_SC: CIPTHERS_BTYES,
    LIBSSH2_METHOD_CRYPT_CS: CIPTHERS_BTYES,
    LIBSSH2_METHOD_MAC_SC: MAC_BTYES,
    LIBSSH2_METHOD_MAC_CS: MAC_BTYES,
    LIBSSH2_METHOD_COMP_SC: COMP_BTYES,
    LIBSSH2_METHOD_COMP_CS: COMP_BTYES
}


class LocalSSH2TestCase(SSH2TestCase):

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


class SessionOptionsTestCase(LocalSSH2TestCase):

    def set_method_preferences(self, perferences):
        for key in perferences:
            self.session.method_pref(key,perferences[key])

    def test_method_pref(self):
        self.session = Session()
        self.set_method_preferences(TEST_PREFERENCES)
        self.session.handshake(self.sock)
        for key in TEST_PREFERENCES:
            assert self.session.methods(key) in TEST_PREFERENCES[key]

    def test_set_flag(self):
        self.session = Session()
        self.session.flag(LIBSSH2_FLAG_COMPRESS,True)
        self.set_method_preferences(TEST_PREFERENCES)
        self.session.handshake(self.sock)
        response = self.session.methods(LIBSSH2_METHOD_COMP_CS)
        assert not b'none'==response

    def test_supported_algs(self):
        self.session = Session()
        self.session.flag(LIBSSH2_FLAG_COMPRESS,True)
        response = self.session.supported_algs(LIBSSH2_METHOD_COMP_CS,COMP_BTYES)
        assert response[0] in COMP_BTYES

    def test_internal_methods(self):
        self.session = Session()
        self.session.flag(LIBSSH2_FLAG_COMPRESS,True)
        self.session.handshake(self.sock)
        response = self.session.methods(LIBSSH2_METHOD_COMP_CS)
        assert response[0] in COMP_BTYES

    def test_bad_method_pref(self):
        failed = False
        self.session = Session()
        perferences = {
            LIBSSH2_METHOD_HOSTKEY: b'blah'
        }
        try:
            self.set_method_preferences(perferences)
            self.session.handshake(self.sock)
        except ssh2_exceptions.MethodNotSupported:
            failed = True
        except Exception as e:
            print(e)
        assert failed==True

    def test_bad_set_flag(self):
        failed = False
        self.session = Session()
        try:
            self.session.flag(LIBSSH2_METHOD_COMP_CS,7)
        except ssh2_exceptions.MethodNotSupported:
            failed = True
        assert failed==True

    def test_bad_supported_algs(self):
        failed = False
        self.session = Session()
        self.session.flag(LIBSSH2_FLAG_COMPRESS,True)
        try:
            self.session.supported_algs(LIBSSH2_METHOD_COMP_CS,None)
        except ssh2_exceptions.MethodNotSupported:
            failed = True
        assert failed==True

    def test_bad_internal_methods(self):
        failed = False
        self.session = Session()
        try:
            self.session.flag(LIBSSH2_FLAG_COMPRESS,True)
            self.session.methods(2222)
        except ssh2_exceptions.MethodNotSupported:
            failed = True
        assert failed==True
