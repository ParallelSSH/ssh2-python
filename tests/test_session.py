from ssh2.session import Session, LIBSSH2_METHOD_HOSTKEY
from ssh2.flags import (FLAG_SIGPIPE, FLAG_COMPRESS, FLAG_QUOTE_PATHS, FLAG_SK_PRESENCE_REQUIRED,
                        FLAG_SK_VERIFICATION_REQUIRED)

from .base_test import SSH2TestCase


class SessionTestCase(SSH2TestCase):
    def test_session(self):
        session = Session()
        self.assertIsInstance(session, Session)

    def test_methods(self):
        session = Session()
        methods = session.methods(LIBSSH2_METHOD_HOSTKEY)
        self.assertIsNone(methods)

    def test_flags(self):
        session = Session()
        for flag in [FLAG_SIGPIPE, FLAG_COMPRESS, FLAG_QUOTE_PATHS]:
            rc = session.flag(flag)
            self.assertEqual(rc, 0)
            rc = session.flag(flag, enabled=False)
            self.assertEqual(rc, 0)
