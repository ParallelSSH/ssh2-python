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

from select import select

from cpython.version cimport PY_MAJOR_VERSION

cimport c_ssh2
from session cimport Session


ENCODING='utf-8'


cdef char* to_bytes(_str):
    if isinstance(_str, bytes):
        return _str
    elif isinstance(_str, unicode):
        return _str.encode(ENCODING)
    return _str


def version(int required_version=0):
    """Get libssh2 version string.

    Passing in a non-zero required_version causes the function to return
    `None` if version is less than required_version

    :param required_version: Minimum required version
    :type required_version: int
    """
    cdef const char *version
    with nogil:
        version = c_ssh2.libssh2_version(required_version)
    if version is NULL:
        return
    return version


def ssh2_exit():
    """Call libssh2_exit"""
    c_ssh2.libssh2_exit()


def wait_socket(_socket, Session session, timeout=0):
    """Helper function for testing non-blocking mode.

    This function blocks the calling thread for <timeout> seconds -
    to be used only for testing purposes.
    """
    cdef int directions = session.blockdirections()
    if directions == 0:
        return 0
    readfds = [_socket] \
              if (directions & c_ssh2._LIBSSH2_SESSION_BLOCK_INBOUND) else ()
    writefds = [_socket] \
               if (directions & c_ssh2._LIBSSH2_SESSION_BLOCK_OUTBOUND) else ()
    return select(readfds, writefds, (), timeout)
