from ssh2.session import (Session, LIBSSH2_METHOD_HOSTKEY, LIBSSH2_FLAG_SIGPIPE, LIBSSH2_FLAG_COMPRESS,
                          LIBSSH2_FLAG_QUOTE_PATHS, LIBSSH2_FLAG_SK_PRESENCE_REQUIRED,
                          LIBSSH2_FLAG_SK_VERIFICATION_REQUIRED,
                          )

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
        for bad_flag in (LIBSSH2_FLAG_QUOTE_PATHS, LIBSSH2_FLAG_SK_PRESENCE_REQUIRED,
                         LIBSSH2_FLAG_SK_VERIFICATION_REQUIRED):
            self.assertRaises(ValueError, session.flag, bad_flag)
