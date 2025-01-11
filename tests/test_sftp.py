from ssh2.session import Session
from ssh2.sftp import SFTP
from ssh2.sftp_handle import SFTPAttributes

from .base_test import SSH2TestCase


class SFTPTestCase(SSH2TestCase):

    def test_init(self):
        session = Session()
        sftp = SFTP(session)
        self.assertIsInstance(sftp, SFTP)
        self.assertIsInstance(sftp.session, Session)
        self.assertEqual(sftp.session, session)

    def test_sftp_attrs_cls(self):
        attrs = SFTPAttributes()
        self.assertIsInstance(attrs, SFTPAttributes)

    def test_session(self):
        session = Session()
        self.assertIsInstance(session, Session)
