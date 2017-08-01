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
from utils cimport to_bytes

# File Transfer Flags
LIBSSH2_FXF_READ = c_sftp.LIBSSH2_FXF_READ
LIBSSH2_FXF_WRITE = c_sftp.LIBSSH2_FXF_WRITE
LIBSSH2_FXF_APPEND = c_sftp.LIBSSH2_FXF_APPEND
LIBSSH2_FXF_CREAT = c_sftp.LIBSSH2_FXF_CREAT
LIBSSH2_FXF_TRUNC = c_sftp.LIBSSH2_FXF_TRUNC
LIBSSH2_FXF_EXCL = c_sftp.LIBSSH2_FXF_EXCL

# File mode masks
# Read, write, execute/search by owner
LIBSSH2_SFTP_S_IRWXU = c_sftp.LIBSSH2_SFTP_S_IRWXU
LIBSSH2_SFTP_S_IRUSR = c_sftp.LIBSSH2_SFTP_S_IRUSR
LIBSSH2_SFTP_S_IWUSR = c_sftp.LIBSSH2_SFTP_S_IWUSR
LIBSSH2_SFTP_S_IXUSR = c_sftp.LIBSSH2_SFTP_S_IXUSR
# Read, write, execute/search by group
LIBSSH2_SFTP_S_IRWXG = c_sftp.LIBSSH2_SFTP_S_IRWXG
LIBSSH2_SFTP_S_IRGRP = c_sftp.LIBSSH2_SFTP_S_IRGRP
LIBSSH2_SFTP_S_IWGRP = c_sftp.LIBSSH2_SFTP_S_IWGRP
LIBSSH2_SFTP_S_IXGRP = c_sftp.LIBSSH2_SFTP_S_IXGRP
# Read, write, execute/search by others
LIBSSH2_SFTP_S_IRWXO = c_sftp.LIBSSH2_SFTP_S_IRWXO
LIBSSH2_SFTP_S_IROTH = c_sftp.LIBSSH2_SFTP_S_IROTH
LIBSSH2_SFTP_S_IWOTH = c_sftp.LIBSSH2_SFTP_S_IWOTH
LIBSSH2_SFTP_S_IXOTH = c_sftp.LIBSSH2_SFTP_S_IXOTH


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

    def open(self, filename not None,
             unsigned long flags,
             long mode):
        """Open file handle for file name.

        :param filename: Name of file to open.
        :type filename: str
        :param flags: One or more LIBSSH2_FXF_* flags. Can be ``0`` for
          reading. Eg for reading flags is ``LIBSSH2_FXF_READ``, for writing
          ``LIBSSH2_FXF_WRITE``, for both
          ``LIBSSH2_FXF_READ`` | ``LIBSSH2_FXF_WRITE``.
        :type flags: int
        :param mode: File permissions mode. ``0`` for reading. For writing
          one or more LIBSSH2_SFTP_S_* flags. Eg, for 664 permission mask
          (read/write owner/group, read other), mode is ``LIBSSH2_SFTP_S_IRUSR |
          LIBSSH2_SFTP_S_IWUSR | LIBSSH2_SFTP_S_IRGRP | LIBSSH2_SFTP_IROTH``
        :type mode: int"""
        cdef c_sftp.LIBSSH2_SFTP_HANDLE *_handle
        cdef SFTPHandle handle
        cdef char *_filename = to_bytes(filename)
        with nogil:
            _handle = c_sftp.libssh2_sftp_open(
                self._sftp, _filename, flags, mode)
        if _handle is NULL:
            return
        handle = PySFTPHandle(_handle, self)
        return handle

    def opendir(self, path not None):
        """Open handle to directory path.

        :param path: Path of directory
        :type path: str

        :rtype: :py:class:`ssh2.sftp.SFTPHandle` or `None`"""
        cdef c_sftp.LIBSSH2_SFTP_HANDLE *_handle
        cdef char *_path = to_bytes(path)
        with nogil:
            _handle = c_sftp.libssh2_sftp_opendir(self._sftp, _path)
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

    def rename(self, source_filename not None, dest_filename not None):
        """Rename file.

        :param source_filename: Old name of file.
        :type source_filename: str
        :param dest_filename: New name of file.
        :type dest_filename: str"""
        cdef int rc
        cdef char *_source_filename = to_bytes(source_filename)
        cdef char *_dest_filename = to_bytes(dest_filename)
        with nogil:
            rc = c_sftp.libssh2_sftp_rename(
                self._sftp, _source_filename, _dest_filename)
        return rc

    def unlink(self, filename not None):
        """Delete/unlink file.

        :param filename: Name of file to delete/unlink.
        :type filename: str"""
        cdef int rc
        cdef char *_filename = to_bytes(filename)
        with nogil:
            rc = c_sftp.libssh2_sftp_unlink(self._sftp, _filename)
        return rc

    def fstatvfs(self):
        raise NotImplementedError

    def statvfs(self):
        raise NotImplementedError

    def mkdir(self, path not None, long mode):
        """Make directory.

        :param path: Path of directory to create.
        :type path: str
        :param mode: Permissions mode of new directory.
        :type mode: int

        :rtype: int"""
        cdef int rc
        cdef char *_path = path
        with nogil:
            rc = c_sftp.libssh2_sftp_mkdir(self._sftp, _path, mode)
        return rc

    def rmdir(self, path not None):
        """Remove directory.

        :param path: Directory path to remove.
        :type path: str

        :rtype: int"""
        cdef int rc
        cdef char *_path = to_bytes(path)
        with nogil:
            rc = c_sftp.libssh2_sftp_rmdir(self._sftp, _path)
        return rc

    def stat(self, path not None, SFTPAttributes attrs):
        """Stat file.

        :param path: Path of file to stat.
        :type path: str

        :rtype: :py:class:`ssh2.sftp.SFTPAttributes`"""
        cdef int rc
        cdef char *_path = to_bytes(path)
        with nogil:
            rc = c_sftp.libssh2_sftp_stat(
                self._sftp, _path, attrs._attrs)
        return rc

    def lstat(self, path not None, SFTPAttributes attrs):
        cdef int rc
        cdef char *_path = to_bytes(path)
        with nogil:
            rc = c_sftp.libssh2_sftp_lstat(
                self._sftp, _path, attrs._attrs)
        return rc

    def setstat(self, path not None, SFTPAttributes attrs):
        cdef int rc
        cdef char *_path = to_bytes(path)
        with nogil:
            rc = c_sftp.libssh2_sftp_setstat(
                self._sftp, _path, attrs._attrs)
        return rc

    def symlink(self, path not None, char *target):
        cdef int rc
        cdef char *_path = to_bytes(path)
        with nogil:
            rc = c_sftp.libssh2_sftp_symlink(self._sftp, _path, target)
        return rc

    def realpath(self, path not None, target not None,
                 unsigned int maxlen):
        cdef int rc
        cdef char *_path = to_bytes(path)
        cdef char *_target = to_bytes(target)
        with nogil:
            rc = c_sftp.libssh2_sftp_realpath(
                self._sftp, _path, _target, maxlen)
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
            if cbuf is NULL:
                with gil:
                    raise MemoryError
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
