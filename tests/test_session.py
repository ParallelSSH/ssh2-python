from ssh2.session import Session, LIBSSH2_METHOD_HOSTKEY, LIBSSH2_FLAG_SIGPIPE, LIBSSH2_FLAG_COMPRESS, FlagType

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
        for flag in [LIBSSH2_FLAG_SIGPIPE, LIBSSH2_FLAG_COMPRESS]:
            session.flag(flag)
            session.flag(flag, enabled=False)
        for bad_flag in (FlagType(99),):
            self.assertRaises(ValueError, session.flag, bad_flag)
