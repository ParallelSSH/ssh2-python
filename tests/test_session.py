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
