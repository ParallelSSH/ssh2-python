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

"""SFTP handle, attributes and stat VFS classes."""

from libc.stdlib cimport malloc, free

from utils cimport handle_error_codes

cimport c_ssh2
cimport c_sftp


cdef object PySFTPHandle(c_sftp.LIBSSH2_SFTP_HANDLE *handle, SFTP sftp):
    cdef SFTPHandle _handle = SFTPHandle.__new__(SFTPHandle, sftp)
    _handle._handle = handle
    return _handle


cdef class SFTPAttributes:

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
    def filesize(self, c_ssh2.libssh2_uint64_t filesize):
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
        cdef int rc
        cdef bytes data
        rc, data = self.read()
        if rc != c_ssh2.LIBSSH2_ERROR_EAGAIN and rc <= 0:
            raise StopIteration
        return rc, data

    def __enter__(self):
        return self

    def __exit__(self, *args):
        self.close()

    def close(self):
        """Close handle. Called automatically when object is deleted
        and/or garbage collected.

        :rtype: int"""
        cdef int rc
        if self.closed == 0:
            with nogil:
                rc = c_sftp.libssh2_sftp_close_handle(self._handle)
            self.closed = 1
        else:
            return
        return rc

    def read(self, size_t buffer_maxlen=c_ssh2.LIBSSH2_CHANNEL_WINDOW_DEFAULT):
        """Read buffer from file handle.

        :param buffer_maxlen: Max length of buffer to return.
        :type buffer_maxlen: int

        :rtype: bytes"""
        cdef ssize_t rc
        cdef bytes buf = b''
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
        finally:
            free(cbuf)
        return rc, buf

    def readdir_ex(self,
                   size_t longentry_maxlen=1024,
                   size_t buffer_maxlen=1024):
        """Get directory listing from file handle, if any.

        File handle *must* be opened with :py:func:`ssh2.sftp.SFTP.readdir()`

        This function is a generator and should be iterated on.

        :param buffer_maxlen: Max length of returned buffer.
        :param longentry_maxlen: Max length of file list entry.

        :rtype: bytes
        """
        rc, buf, entry, attrs = self._readdir_ex(
            longentry_maxlen=longentry_maxlen,
            buffer_maxlen=buffer_maxlen)
        while rc == c_ssh2.LIBSSH2_ERROR_EAGAIN or rc > 0:
            yield rc, buf, entry, attrs
            rc, buf, entryb, attrs = self._readdir_ex(
                longentry_maxlen=longentry_maxlen,
                buffer_maxlen=buffer_maxlen)

    def _readdir_ex(self,
                    size_t longentry_maxlen=1024,
                    size_t buffer_maxlen=1024):
        cdef bytes buf = b''
        cdef bytes b_longentry = b''
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
                b_longentry = longentry
        finally:
            free(cbuf)
            free(longentry)
        return rc, buf, b_longentry, attrs

    def readdir(self, size_t buffer_maxlen=1024):
        """Get directory listing from file handle, if any.

        This function is a generator and should be iterated on.

        File handle *must* be opened with :py:func:`ssh2.sftp.SFTP.readdir()`

        :param buffer_maxlen: Max length of returned file entry.

        :rtype: iter(bytes)"""
        rc, buf, attrs = self._readdir(buffer_maxlen)
        while rc == c_ssh2.LIBSSH2_ERROR_EAGAIN or rc > 0:
            yield rc, buf, attrs
            rc, buf, attrs = self._readdir(buffer_maxlen)

    def _readdir(self,
                 size_t buffer_maxlen=1024):
        cdef bytes buf = b''
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
        finally:
            free(cbuf)
        return rc, buf, attrs

    def write(self, bytes buf):
        """Write buffer to file handle.

        Returns tuple of (``error code``, ``bytes written``).

        In blocking mode ``bytes_written`` will always equal ``len(buf)`` if no
        errors have occurred which would raise exception.

        In non-blocking mode ``error_code`` can be LIBSSH2_ERROR_EAGAIN and
        ``bytes_written`` *can be less than* ``len(buf)``.

        Clients should resume from that point on next call to ``write``, ie
        ``buf[bytes_written_in_last_call:]``.

        :param buf: Buffer to write.
        :type buf: bytes

        :rtype: tuple(int, int)"""
        cdef size_t _size = len(buf)
        cdef size_t tot_size = _size
        cdef size_t bytes_written = 0
        cdef char *cbuf = buf
        cdef ssize_t rc = 0
        with nogil:
            while _size > 0:
                rc = c_sftp.libssh2_sftp_write(self._handle, cbuf, _size)
                if rc < 0 and rc != c_ssh2.LIBSSH2_ERROR_EAGAIN:
                    # Error we cannot resume from, exception will be raised
                    with gil:
                        return handle_error_codes(rc)
                elif rc == c_ssh2.LIBSSH2_ERROR_EAGAIN:
                    break
                cbuf += rc
                _size -= rc
            bytes_written = tot_size - _size
        return rc, bytes_written

    IF EMBEDDED_LIB:
        def fsync(self):
            """Sync file handle data.

            Available from libssh2 >= ``1.4.4``

            :rtype: int"""
            cdef int rc
            with nogil:
                rc = c_sftp.libssh2_sftp_fsync(self._handle)
            return handle_error_codes(rc)

    def seek(self, size_t offset):
        """Deprecated, use seek64.

        Seek file to given offset.

        :param offset: Offset to seek to.
        :type offset: int

        :rtype: None"""
        with nogil:
            c_sftp.libssh2_sftp_seek(self._handle, offset)

    def seek64(self, c_ssh2.libssh2_uint64_t offset):
        """Seek file to given 64-bit offset.

        :param offset: Offset to seek to.
        :type offset: int

        :rtype: None"""
        with nogil:
            c_sftp.libssh2_sftp_seek64(self._handle, offset)

    def rewind(self):
        """Rewind file handle to beginning of file.

        :rtype: None"""
        with nogil:
            c_sftp.libssh2_sftp_rewind(self._handle)

    def tell(self):
        """Deprecated, use tell64.

        Get current file handle offset.

        :rtype: int"""
        cdef size_t rc
        with nogil:
            rc = c_sftp.libssh2_sftp_tell(self._handle)
        return handle_error_codes(rc)

    def tell64(self):
        """Get current file handle 64-bit offset.

        :rtype: int"""
        cdef c_ssh2.libssh2_uint64_t rc
        with nogil:
            rc = c_sftp.libssh2_sftp_tell(self._handle)
        return handle_error_codes(rc)

    def fstat_ex(self, SFTPAttributes attrs, int setstat):
        """Get or set file attributes. Clients would typically use one of the
        fstat or fsetstat functions instead"""
        cdef int rc
        with nogil:
            rc = c_sftp.libssh2_sftp_fstat_ex(
                self._handle, attrs._attrs, setstat)
        return handle_error_codes(rc)

    def fstat(self):
        """Get file stat attributes from handle.

        :rtype: tuple(int, :py:class:`ssh2.sftp.SFTPAttributes`)"""
        cdef int rc
        cdef SFTPAttributes attrs = SFTPAttributes()
        with nogil:
            rc = c_sftp.libssh2_sftp_fstat(self._handle, attrs._attrs)
        if rc != 0:
            return handle_error_codes(rc)
        return attrs

    def fsetstat(self, SFTPAttributes attrs):
        """Set file handle attributes.

        :param attrs: Attributes to set.
        :type attrs: :py:class:`ssh2.sftp.SFTPAttributes`"""
        cdef int rc
        with nogil:
            rc = c_sftp.libssh2_sftp_fsetstat(self._handle, attrs._attrs)
        return handle_error_codes(rc)

    def fstatvfs(self):
        """Get file system statistics for handle

        :rtype: `ssh2.sftp.SFTPStatVFS`"""
        cdef SFTPStatVFS vfs = SFTPStatVFS(self)
        cdef int rc
        with nogil:
            rc = c_sftp.libssh2_sftp_fstatvfs(self._handle, vfs._ptr)
        if rc != 0:
            return handle_error_codes(rc)
        return vfs


cdef class SFTPStatVFS:
    """File system statistics"""

    def __cinit__(self, _sftp_ref):
        self._sftp_ref = _sftp_ref
        with nogil:
            self._ptr = <c_sftp.LIBSSH2_SFTP_STATVFS *>malloc(
                sizeof(c_sftp.LIBSSH2_SFTP_STATVFS))
            if self._ptr is NULL:
                with gil:
                    raise MemoryError
            self._ptr.f_bsize = 0
            self._ptr.f_frsize = 0
            self._ptr.f_blocks = 0
            self._ptr.f_bfree = 0
            self._ptr.f_bavail = 0
            self._ptr.f_files = 0
            self._ptr.f_ffree = 0
            self._ptr.f_favail = 0
            self._ptr.f_fsid = 0
            self._ptr.f_flag = 0
            self._ptr.f_namemax = 0

    def __dealloc__(self):
        with nogil:
            if self._ptr is not NULL:
                free(self._ptr)

    @property
    def f_bsize(self):
        """File system block size"""
        return self._ptr.f_bsize

    @property
    def f_frsize(self):
        """Fragment size"""
        return self._ptr.f_frsize

    @property
    def f_blocks(self):
        """Size of fs in f_frsize units"""
        return self._ptr.f_blocks

    @property
    def f_bfree(self):
        """Free blocks"""
        return self._ptr.f_bfree

    @property
    def f_bavail(self):
        """Free blocks for non-root"""
        return self._ptr.f_bavail

    @property
    def f_files(self):
        """Inodes"""
        return self._ptr.f_files

    @property
    def f_ffree(self):
        """Free inodes"""
        return self._ptr.f_ffree

    @property
    def f_favail(self):
        """Free inodes for non-root"""
        return self._ptr.f_favail

    @property
    def f_fsid(self):
        """File system ID"""
        return self._ptr.f_fsid

    @property
    def f_flag(self):
        """File system mount flags.

        This property is a bit mask with defined bits
        ``LIBSSH2_SFTP_ST_RDONLY`` and ``LIBSSH2_SFTP_ST_NOSUID``"""
        return self._ptr.f_flag

    @property
    def f_namemax(self):
        """Maximum filename length"""
        return self._ptr.f_namemax
