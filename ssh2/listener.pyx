# This file is part of ssh2-python.
# Copyright (C) 2017 Panos Kittenis

# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation, version 2.1.

# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.

# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

from session cimport Session
from channel cimport PyChannel
from utils cimport handle_error_codes

cimport c_ssh2


cdef object PyListener(c_ssh2.LIBSSH2_LISTENER *listener, Session session):
    cdef Listener _listener = Listener.__new__(Listener, session)
    _listener._listener = listener
    return _listener


cdef class Listener:

    def __cinit__(self, session):
        self._listener = NULL
        self._session = session

    def forward_accept(self):
        cdef c_ssh2.LIBSSH2_CHANNEL *channel
        with nogil:
            channel = c_ssh2.libssh2_channel_forward_accept(
                self._listener)
        if channel is NULL:
            return handle_error_codes(c_ssh2.libssh2_session_last_errno(
                self._session._session))
        return PyChannel(channel, self._session)

    def forward_cancel(self):
        cdef int rc
        with nogil:
            rc = c_ssh2.libssh2_channel_forward_cancel(
                self._listener)
        return handle_error_codes(rc)
