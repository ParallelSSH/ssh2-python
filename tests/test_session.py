from ssh2.session import Session

from .base_test import SSH2TestCase


class SessionTestCase(SSH2TestCase):
    def test_session(self):
        session = Session()
        self.assertIsInstance(session, Session)
