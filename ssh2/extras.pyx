# This file is part of ssh2-python.
# Copyright (C) 2017-2025 Panos Kittenis
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation, version 2.1.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

"""
Additional functionality not part of the libssh2 API.
"""

from . cimport error_codes


def eagain_errcode(func, poller_func, *args, **kwargs):
    """Helper function for reading in non-blocking mode.

    Any additional arguments and keyword arguments provided are used as arguments to the session function `func`.
    `func` should return an integer return code.

    :param func: The session function to call to read data from.
    :param poller_func: A python function to handle socket polling that takes no arguments.

    :returns: Output of func.
    :rtype: int
    """
    cdef int ret = func(*args, **kwargs)
    while ret == error_codes._LIBSSH2_ERROR_EAGAIN:
        poller_func()
        ret = func(*args, **kwargs)
    return ret


def eagain_write_errcode(write_func, poller_func, bytes data):
    """Helper function for writing in non-blocking mode.

    Any additional arguments and keyword arguments provided are used as arguments to the session function `write_func`.
    `write_func` should return an integer tuple `(rc, bytes_written)` for return code and bytes written respectively.

    :param write_func: The session function to call to read data from.
    :param poller_func: A python function to handle socket polling that takes no arguments.
    :param data: The data to write.
    :type data: bytes
    """
    cdef size_t data_len = len(data)
    cdef size_t total_written = 0
    cdef int rc
    cdef size_t bytes_written
    while total_written < data_len:
        rc, bytes_written = write_func(data[total_written:])
        total_written += bytes_written
        if rc == error_codes._LIBSSH2_ERROR_EAGAIN:
            poller_func()
