#  This file is part of ssh2-python.
#  Copyright (C) 2017-2025 Panos Kittenis
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation, version 2.1.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

from ssh2.session import Session
from ssh2.sftp import SFTP
from ssh2.sftp_handle import SFTPAttributes, SFTPHandle

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

    def test_sftp_handle(self):
        session = Session()
        sftp = SFTP(session)
        sftp_fh = SFTPHandle(sftp)
        self.assertFalse(sftp_fh.closed)
