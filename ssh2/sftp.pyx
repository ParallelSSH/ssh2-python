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

# cython: embedsignature=True, boundscheck=False, optimize.use_switch=True, wraparound=False

from contextlib import contextmanager
from libc.stdint cimport uint64_t
from libc.stdlib cimport malloc, free

cimport c_ssh2
cimport c_sftp
from error_codes cimport _LIBSSH2_ERROR_EAGAIN, _LIBSSH2_ERROR_BUFFER_TOO_SMALL
from channel cimport Channel, PyChannel
from utils cimport to_bytes, to_str
from exceptions cimport SFTPHandleError, SFTPBufferTooSmall


# File types
# TODO

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
          LIBSSH2_SFTP_S_IWUSR | LIBSSH2_SFTP_S_IRGRP | LIBSSH2_SFTP_S_IROTH``
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

    @contextmanager
    def opendir(self, path not None):
        """Open handle to directory path.

        :param path: Path of directory
        :type path: str

        :rtype: :py:class:`ssh2.sftp.SFTPHandle` or `None`"""
        cdef c_sftp.LIBSSH2_SFTP_HANDLE *_handle
        cdef char *_path = to_bytes(path)
        cdef SFTPHandle handle
        with nogil:
            _handle = c_sftp.libssh2_sftp_opendir(self._sftp, _path)
        if _handle is NULL:
            return
        yield PySFTPHandle(_handle, self)

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

    def stat(self, path not None):
        """Stat file.

        :param path: Path of file to stat.
        :type path: str

        :rtype: :py:class:`ssh2.sftp.SFTPAttributes` or LIBSSH2_ERROR_EAGAIN"""
        cdef int rc
        cdef char *_path = to_bytes(path)
        cdef SFTPAttributes attrs = SFTPAttributes()
        with nogil:
            rc = c_sftp.libssh2_sftp_stat(
                self._sftp, _path, attrs._attrs)
            if rc != c_ssh2._LIBSSH2_ERROR_EAGAIN and rc != 0:
                with gil:
                    raise SFTPHandleError(
                        "Error with stat on file %s - code %s",
                        path, rc)
        if rc == c_ssh2._LIBSSH2_ERROR_EAGAIN:
            return rc
        return attrs

    def lstat(self, path not None):
        cdef int rc
        cdef char *_path = to_bytes(path)
        cdef SFTPAttributes attrs = SFTPAttributes()
        with nogil:
            rc = c_sftp.libssh2_sftp_lstat(
                self._sftp, _path, attrs._attrs)
            if rc != 0 and rc != c_ssh2._LIBSSH2_ERROR_EAGAIN:
                with gil:
                    raise SFTPHandleError(
                        "Error with stat on file %s - code %s",
                        path, rc)
        if rc == c_ssh2._LIBSSH2_ERROR_EAGAIN:
            return rc
        return attrs

    def setstat(self, path not None, SFTPAttributes attrs):
        cdef int rc
        cdef char *_path = to_bytes(path)
        with nogil:
            rc = c_sftp.libssh2_sftp_setstat(
                self._sftp, _path, attrs._attrs)
        return rc

    def symlink(self, path not None, target not None):
        cdef int rc
        cdef char *_path = to_bytes(path)
        cdef char *_target = to_bytes(target)
        with nogil:
            rc = c_sftp.libssh2_sftp_symlink(self._sftp, _path, _target)
        return rc

    def realpath(self, path not None, size_t max_len=256):
        """Get real path for path.

        :param: Path name to get real path for.
        :type param: str
        :param max_len: Max size of returned real path.
        :type max_len: int

        :raises: :py:class:`ssh2.exceptions.SFTPHandleError` on errors getting
          real path.
        :raises: :py:class:`ssh2.exceptions.SFTPBufferTooSmall` on max_len less
          than real path length."""
        cdef char *_target = <char *>malloc(sizeof(char)*max_len)
        if _target == NULL:
            raise MemoryError
        cdef int rc
        cdef char *_path = to_bytes(path)
        cdef bytes realpath
        try:
            with nogil:
                rc = c_sftp.libssh2_sftp_realpath(
                    self._sftp, _path, _target, max_len)
                if rc == _LIBSSH2_ERROR_BUFFER_TOO_SMALL:
                    with gil:
                        raise SFTPBufferTooSmall(
                            "Buffer too small to fit realpath for %s "
                            "- max size %s. Error code %s",
                            path, max_len, rc)
                elif rc != c_ssh2._LIBSSH2_ERROR_EAGAIN and rc < 0:
                    with gil:
                        raise SFTPHandleError(
                            "Error getting real path for %s - error code %s",
                            path, rc)
                elif rc == c_ssh2._LIBSSH2_ERROR_EAGAIN:
                    with gil:
                        return rc
            realpath = _target[:rc]
            return to_str(realpath)
        finally:
            free(_target)

    def last_error(self):
        cdef unsigned long rc
        with nogil:
            rc = c_sftp.libssh2_sftp_last_error(self._sftp)
        return rc


cdef class SFTPAttributes:
    cdef c_sftp.LIBSSH2_SFTP_ATTRIBUTES *_attrs

    def __cinit__(self):
        with nogil:
            self._attrs = <c_sftp.LIBSSH2_SFTP_ATTRIBUTES *>malloc(
                sizeof(c_sftp.LIBSSH2_SFTP_ATTRIBUTES))
            if self._attrs is NULL:
                with gil:
                    raise MemoryError
            self._attrs.flags = 0
            self._attrs.filesize = 0
            self._attrs.uid = 0
            self._attrs.gid = 0
            self._attrs.permissions = 0
            self._attrs.atime = 0
            self._attrs.mtime = 0

    def __dealloc__(self):
        with nogil:
            free(self._attrs)

    @property
    def flags(self):
        return self._attrs.flags

    @flags.setter
    def flags(self, unsigned long flags):
        self._attrs.flags = flags

    @property
    def filesize(self):
        return self._attrs.filesize

    @filesize.setter
    def filesize(self, uint64_t filesize):
        self._attrs.filesize = filesize

    @property
    def uid(self):
        return self._attrs.uid

    @uid.setter
    def uid(self, unsigned long uid):
        self._attrs.uid = uid

    @property
    def gid(self):
        return self._attrs.gid

    @gid.setter
    def gid(self, unsigned long gid):
        self._attrs.gid = gid

    @property
    def permissions(self):
        return self._attrs.permissions

    @permissions.setter
    def permissions(self, unsigned long permissions):
        self._attrs.permissions = permissions

    @property
    def atime(self):
        return self._attrs.atime

    @atime.setter
    def atime(self, unsigned long atime):
        self._attrs.atime = atime

    @property
    def mtime(self):
        return self._attrs.mtime

    @mtime.setter
    def mtime(self, unsigned long mtime):
        self._attrs.mtime = mtime


cdef class SFTPHandle:
    cdef c_sftp.LIBSSH2_SFTP_HANDLE *_handle
    cdef SFTP _sftp
    cdef bint closed

    def __cinit__(self, sftp):
        self._handle = NULL
        self._sftp = sftp
        self.closed = 0

    def __dealloc__(self):
        if self.closed == 0:
            with nogil:
                c_sftp.libssh2_sftp_close_handle(self._handle)
            self.closed = 1

    def __iter__(self):
        return self

    def __next__(self):
        cdef bytes data = self.read()
        if len(data) == 0:
            raise StopIteration
        return data

    def __enter__(self):
        return self

    def __exit__(self, *args):
        self.close()

    def close(self):
        cdef int rc
        if self.closed == 0:
            with nogil:
                rc = c_sftp.libssh2_sftp_close_handle(self._handle)
            self.closed = 1
        else:
            return
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

    def readdir_ex(self,
                   size_t longentry_maxlen=1024,
                   size_t buffer_maxlen=1024):
        """Get directory listing from file handle, if any.

        File handle *must* be opened with :py:func:`ssh2.sftp.SFTP.readdir()`

        This function is a generator and should be iterated on.

        :param buffer_maxlen: Max length of returned buffer.
        :param longentry_maxlen: Max length of filename in listing.

        :rtype: bytes"""
        buf, entry, attrs = self._readdir_ex(
            longentry_maxlen=longentry_maxlen,
            buffer_maxlen=buffer_maxlen)
        while len(buf) > 0:
            yield buf, entry, attrs
            buf, entry, attrs = self._readdir_ex(
                longentry_maxlen=longentry_maxlen,
                buffer_maxlen=buffer_maxlen)

    def _readdir_ex(self,
                    size_t longentry_maxlen=1024,
                    size_t buffer_maxlen=1024):
        cdef bytes buf
        cdef bytes filename
        cdef char *cbuf
        cdef char *longentry
        cdef SFTPAttributes attrs = SFTPAttributes()
        with nogil:
            cbuf = <char *>malloc(sizeof(char)*buffer_maxlen)
            longentry = <char *>malloc(sizeof(char)*longentry_maxlen)
            if cbuf is NULL or longentry is NULL:
                with gil:
                    raise MemoryError
            rc = c_sftp.libssh2_sftp_readdir_ex(
                self._handle, cbuf, buffer_maxlen, longentry,
                longentry_maxlen, attrs._attrs)
        try:
            if rc > 0:
                buf = cbuf[:rc]
            else:
                buf = b''
        finally:
            free(cbuf)
            free(longentry)
        return buf, longentry, attrs

    def readdir(self, size_t buffer_maxlen=1024):
        """Get directory listing from file handle, if any.

        This function is a generator and should be iterated on.

        File handle *must* be opened with :py:func:`ssh2.sftp.SFTP.readdir()`

        :param buffer_maxlen: Max length of returned file entry.

        :rtype: iter(bytes)"""
        buf, attrs = self._readdir(buffer_maxlen)
        while len(buf) > 0:
            yield buf, attrs
            buf, attrs = self._readdir(buffer_maxlen)

    def _readdir(self,
                size_t buffer_maxlen=1024):
        cdef bytes buf
        cdef char *cbuf
        cdef SFTPAttributes attrs = SFTPAttributes()
        with nogil:
            cbuf = <char *>malloc(sizeof(char)*buffer_maxlen)
            if cbuf is NULL:
                with gil:
                    raise MemoryError
            rc = c_sftp.libssh2_sftp_readdir(
                self._handle, cbuf, buffer_maxlen, attrs._attrs)
        try:
            if rc > 0:
                buf = cbuf[:rc]
            else:
                buf = b''
        finally:
            free(cbuf)
        return buf, attrs

    def write(self, bytes buf):
        cdef size_t _size = len(buf)
        cdef char *cbuf = buf
        cdef ssize_t rc
        with nogil:
            rc = c_sftp.libssh2_sftp_write(self._handle, cbuf, _size)
        return rc

    IF EMBEDDED_LIB:
        def fsync(self):
            """Sync file handle data.

            Available from libssh2 >= ``1.4.4``

            :rtype: int"""
            cdef int rc
            with nogil:
                rc = c_sftp.libssh2_sftp_fsync(self._handle)
            return rc

    def seek(self, size_t offset):
        with nogil:
            c_sftp.libssh2_sftp_seek(self._handle, offset)

    def seek64(self, uint64_t offset):
        with nogil:
            c_sftp.libssh2_sftp_seek64(self._handle, offset)

    def rewind(self):
        with nogil:
            c_sftp.libssh2_sftp_rewind(self._handle)

    def tell(self):
        cdef size_t rc
        with nogil:
            rc = c_sftp.libssh2_sftp_tell(self._handle)
        return rc

    def tell64(self):
        cdef uint64_t rc
        with nogil:
            rc = c_sftp.libssh2_sftp_tell(self._handle)
        return rc

    def fstat_ex(self, SFTPAttributes attrs, int setstat):
        cdef int rc
        with nogil:
            rc = c_sftp.libssh2_sftp_fstat_ex(
                self._handle, attrs._attrs, setstat)
        return rc

    def fstat(self):
        """Get file stat attributes from handle.

        :rtype: tuple(int, :py:class:`ssh2.sftp.SFTPAttributes`)"""
        cdef int rc
        cdef SFTPAttributes attrs = SFTPAttributes()
        with nogil:
            rc = c_sftp.libssh2_sftp_fstat(self._handle, attrs._attrs)
        if rc != 0:
            return rc
        return attrs

    def fsetstat(self, SFTPAttributes attrs):
        """Set file handle attributes.

        :param attrs: Attributes to set.
        :type attrs: :py:class:`ssh2.sftp.SFTPAttributes`"""
        cdef int rc
        with nogil:
            rc = c_sftp.libssh2_sftp_fsetstat(self._handle, attrs._attrs)
        return rc
