from ssh2.session import Session, LIBSSH2_METHOD_HOSTKEY

from .base_test import SSH2TestCase


class SessionTestCase(SSH2TestCase):
    def test_session(self):
        session = Session()
        self.assertIsInstance(session, Session)

    def test_methods(self):
        session = Session()
        methods = session.methods(LIBSSH2_METHOD_HOSTKEY)
        self.assertIsNone(methods)
