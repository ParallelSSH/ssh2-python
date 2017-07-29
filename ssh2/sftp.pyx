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

from libc.stdlib cimport malloc, free

cimport c_ssh2
cimport c_sftp
from channel cimport Channel, PyChannel


cdef object PySFTPHandle(c_sftp.LIBSSH2_SFTP_HANDLE *handle, SFTP sftp):
    cdef SFTPHandle _handle = SFTPHandle(sftp)
    _handle._handle = handle
    return _handle


cdef object PySFTP(c_sftp.LIBSSH2_SFTP *sftp, Session session):
    cdef SFTP _sftp = SFTP(session)
    _sftp._sftp = sftp
    return _sftp


cdef class SFTP:

    def __cinit__(self, session):
        self._sftp = NULL
        self._session = session

    def __dealloc__(self):
        with nogil:
            c_sftp.libssh2_sftp_shutdown(self._sftp)

    def get_channel(self):
        cdef c_ssh2.LIBSSH2_CHANNEL *_channel
        with nogil:
            _channel = c_sftp.libssh2_sftp_get_channel(self._sftp)
        if _channel is NULL:
            return
        return PyChannel(_channel, self._session)

    def open_ex(self, const char *filename,
                unsigned int filename_len,
                unsigned long flags,
                long mode, int open_type):
        cdef c_sftp.LIBSSH2_SFTP_HANDLE *_handle
        cdef SFTPHandle handle
        with nogil:
            _handle = c_sftp.libssh2_sftp_open_ex(
                self._sftp, filename, filename_len, flags,
                mode, open_type)
        if _handle is NULL:
            return
        handle = PySFTPHandle(_handle, self)
        return handle

    def open(self, const char *filename,
             unsigned long flags,
             long mode):
        cdef c_sftp.LIBSSH2_SFTP_HANDLE *_handle
        cdef SFTPHandle handle
        with nogil:
            _handle = c_sftp.libssh2_sftp_open(
                self._sftp, filename, flags, mode)
        if _handle is NULL:
            return
        handle = PySFTPHandle(_handle, self)
        return handle

    def opendir(self, const char *path):
        cdef c_sftp.LIBSSH2_SFTP_HANDLE *_handle
        with nogil:
            _handle = c_sftp.libssh2_sftp_opendir(self._sftp, path)
        if _handle is NULL:
            return
        return PySFTPHandle(_handle, self)

    def rename_ex(self, const char *source_filename,
                  unsigned int source_filename_len,
                  const char *dest_filename,
                  unsigned int dest_filename_len,
                  long flags):
        cdef int rc
        with nogil:
            rc = c_sftp.libssh2_sftp_rename_ex(
                self._sftp, source_filename, source_filename_len,
                dest_filename, dest_filename_len, flags)
        return rc

    def rename(self, const char *source_filename, const char *dest_filename):
        cdef int rc
        with nogil:
            rc = c_sftp.libssh2_sftp_rename(
                self._sftp, source_filename, dest_filename)
        return rc

    def unlink(self, const char *filename):
        cdef int rc
        with nogil:
            rc = c_sftp.libssh2_sftp_unlink(self._sftp, filename)
        return rc

    def fstatvfs(self):
        raise NotImplementedError

    def statvfs(self):
        raise NotImplementedError

    def mkdir(self, const char *path, long mode):
        cdef int rc
        with nogil:
            rc = c_sftp.libssh2_sftp_mkdir(self._sftp, path, mode)
        return rc

    def rmdir(self, const char *path):
        cdef int rc
        with nogil:
            rc = c_sftp.libssh2_sftp_rmdir(self._sftp, path)
        return rc

    def stat(self, const char *path, SFTPAttributes attrs):
        cdef int rc
        with nogil:
            rc = c_sftp.libssh2_sftp_stat(
                self._sftp, path, attrs._attrs)
        return rc

    def lstat(self, const char *path, SFTPAttributes attrs):
        cdef int rc
        with nogil:
            rc = c_sftp.libssh2_sftp_lstat(
                self._sftp, path, attrs._attrs)
        return rc

    def setstat(self, const char *path, SFTPAttributes attrs):
        cdef int rc
        with nogil:
            rc = c_sftp.libssh2_sftp_setstat(
                self._sftp, path, attrs._attrs)
        return rc

    def symlink(self, const char *path, char *target):
        cdef int rc
        with nogil:
            rc = c_sftp.libssh2_sftp_symlink(self._sftp, path, target)
        return rc

    def realpath(self, const char *path, char *target,
                 unsigned int maxlen):
        cdef int rc
        with nogil:
            rc = c_sftp.libssh2_sftp_realpath(
                self._sftp, path, target, maxlen)
        return rc


cdef class SFTPAttributes:
    cdef c_sftp.LIBSSH2_SFTP_ATTRIBUTES *_attrs

    def __cinit__(self):
        self._attrs = NULL


cdef class SFTPHandle:
    cdef c_sftp.LIBSSH2_SFTP_HANDLE *_handle
    cdef SFTP _sftp

    def __cinit__(self, sftp):
        self._handle = NULL
        self._sftp = sftp

    def __dealloc__(self):
        with nogil:
            c_sftp.libssh2_sftp_close_handle(self._handle)

    def __iter__(self):
        return self

    def __next__(self):
        cdef bytes data = self.read()
        if len(data) == 0:
            raise StopIteration
        return data

    def close(self):
        cdef int rc
        with nogil:
            rc = c_sftp.libssh2_sftp_close_handle(self._handle)
        return rc

    def read(self, size_t buffer_maxlen=c_ssh2._LIBSSH2_CHANNEL_WINDOW_DEFAULT):
        cdef ssize_t rc
        cdef bytes buf
        cdef char *cbuf
        with nogil:
            cbuf = <char *>malloc(sizeof(char)*buffer_maxlen)
            rc = c_sftp.libssh2_sftp_read(
                self._handle, cbuf, buffer_maxlen)
        try:
            if rc > 0:
                buf = cbuf[:rc]
            else:
                buf = b''
        finally:
            free(cbuf)
        return buf

    def readdir_ex(self, char *buffer, size_t buffer_maxlen,
                   char *longentry,
                   size_t longentry_maxlen,
                   SFTPAttributes attrs):
        raise NotImplementedError

    def readdir(self, char *buffer, size_t buffer_maxlen,
                SFTPAttributes attrs):
        raise NotImplementedError

    def write(self, const char *buf, size_t count):
        raise NotImplementedError

    def fsync(self):
        raise NotImplementedError

    def seek(self, size_t offset):
        raise NotImplementedError

    def seek64(self, size_t offset):
        raise NotImplementedError

    def rewind(self):
        raise NotImplementedError

    def tell(self):
        raise NotImplementedError

    def tell64(self):
        raise NotImplementedError

    def fstat_ex(self, SFTPAttributes attrs, int setstat):
        raise NotImplementedError

    def fstat(self, SFTPAttributes attrs):
        raise NotImplementedError

    def fsetstat(self, SFTPAttributes attrs):
        raise NotImplementedError


