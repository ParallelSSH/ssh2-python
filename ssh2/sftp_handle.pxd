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

from sftp cimport SFTP

cimport c_sftp


cdef object PySFTPHandle(c_sftp.LIBSSH2_SFTP_HANDLE *handle, SFTP sftp)


cdef class SFTPHandle:
    cdef c_sftp.LIBSSH2_SFTP_HANDLE *_handle
    cdef SFTP _sftp
    cdef bint closed


cdef class SFTPAttributes:
    cdef c_sftp.LIBSSH2_SFTP_ATTRIBUTES *_attrs


cdef class SFTPStatVFS:
    cdef c_sftp.LIBSSH2_SFTP_STATVFS *_ptr
    cdef object _sftp_ref
