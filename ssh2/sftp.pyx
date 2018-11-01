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


"""
SFTP channel class and related SFTP flags.

File types
------------
:var LIBSSH2_SFTP_S_IFMT: Type of file mask
:var LIBSSH2_SFTP_S_IFIFO: Named pipe (fifo)
:var LIBSSH2_SFTP_S_IFCHR: Character special (character device)
:var LIBSSH2_SFTP_S_IFDIR: Directory
:var LIBSSH2_SFTP_S_IFBLK: Block special (block device)
:var LIBSSH2_SFTP_S_IFREG: Regular file
:var LIBSSH2_SFTP_S_IFLNK: Symbolic link
:var LIBSSH2_SFTP_S_IFSOCK: Socket

File transfer flags
--------------------
:var LIBSSH2_FXF_READ: File read flag
:var LIBSSH2_FXF_WRITE: File write flag
:var LIBSSH2_FXF_APPEND: File append flag
:var LIBSSH2_FXF_CREAT: File create flag
:var LIBSSH2_FXF_TRUNC: File truncate flag
:var LIBSSH2_FXF_EXCL: Exclusive file flag

File mode masks
-----------------

Owner masks
_____________

:var LIBSSH2_SFTP_S_IRWXU: Read/write/execute
:var LIBSSH2_SFTP_S_IRUSR: Read
:var LIBSSH2_SFTP_S_IWUSR: Write
:var LIBSSH2_SFTP_S_IXUSR: Execute

Group masks
____________

:var LIBSSH2_SFTP_S_IRWXG: Read/write/execute
:var LIBSSH2_SFTP_S_IRGRP: Read
:var LIBSSH2_SFTP_S_IWUSR: Write
:var LIBSSH2_SFTP_S_IXUSR: Execute

Other masks
____________

:var LIBSSH2_SFTP_S_IRWXO: Read/write/execute
:var LIBSSH2_SFTP_S_IROTH: Read
:var LIBSSH2_SFTP_S_IWOTH: Write
:var LIBSSH2_SFTP_S_IXOTH: Execute

Generic mode masks
___________________

:var LIBSSH2_SFTP_ST_RDONLY: Read only
:var LIBSSH2_SFTP_ST_NOSUID: No suid
"""

from libc.stdlib cimport malloc, free

from session cimport Session
from channel cimport Channel, PyChannel
from utils cimport to_bytes, to_str_len, handle_error_codes
from sftp_handle cimport SFTPHandle, PySFTPHandle, SFTPAttributes, SFTPStatVFS

cimport c_ssh2
cimport c_sftp


# File types

# Type of file mask
LIBSSH2_SFTP_S_IFMT = c_sftp.LIBSSH2_SFTP_S_IFMT
# named pipe (fifo)
LIBSSH2_SFTP_S_IFIFO = c_sftp.LIBSSH2_SFTP_S_IFIFO
# character special
LIBSSH2_SFTP_S_IFCHR = c_sftp.LIBSSH2_SFTP_S_IFCHR
# directory
LIBSSH2_SFTP_S_IFDIR = c_sftp.LIBSSH2_SFTP_S_IFDIR
# block special (block device)
LIBSSH2_SFTP_S_IFBLK = c_sftp.LIBSSH2_SFTP_S_IFBLK
# regular
LIBSSH2_SFTP_S_IFREG = c_sftp.LIBSSH2_SFTP_S_IFREG
# symbolic link
LIBSSH2_SFTP_S_IFLNK = c_sftp.LIBSSH2_SFTP_S_IFLNK
# socket
LIBSSH2_SFTP_S_IFSOCK = c_sftp.LIBSSH2_SFTP_S_IFSOCK


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

# Read only
LIBSSH2_SFTP_ST_RDONLY = c_sftp.LIBSSH2_SFTP_ST_RDONLY
# No suid
LIBSSH2_SFTP_ST_NOSUID = c_sftp.LIBSSH2_SFTP_ST_NOSUID


cdef object PySFTP(c_sftp.LIBSSH2_SFTP *sftp, Session session):
    cdef SFTP _sftp = SFTP.__new__(SFTP, session)
    _sftp._sftp = sftp
    return _sftp


cdef class SFTP:
    """SFTP session.

    :param session: Session that initiated SFTP.
    :type session: :py:class:`ssh2.session.Session` pointer"""

    def __cinit__(self, session):
        self._sftp = NULL
        self._session = session

    def __dealloc__(self):
        with nogil:
            c_sftp.libssh2_sftp_shutdown(self._sftp)

    @property
    def session(self):
        """Originating session."""
        return self._session

    def get_channel(self):
        """Get new channel from the SFTP session"""
        cdef c_ssh2.LIBSSH2_CHANNEL *_channel
        with nogil:
            _channel = c_sftp.libssh2_sftp_get_channel(self._sftp)
        if _channel is NULL:
            return handle_error_codes(c_ssh2.libssh2_session_last_errno(
                self._session._session))
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
            return handle_error_codes(c_ssh2.libssh2_session_last_errno(
                self._session._session))
        handle = PySFTPHandle(_handle, self)
        return handle

    def open(self, filename not None,
             unsigned long flags,
             long mode):
        """Open file handle for file name.

        :param filename: Name of file to open.
        :type filename: str
        :param flags: One or more LIBSSH2_FXF_* flags.

          Eg for reading flags is ``LIBSSH2_FXF_READ``,

          for writing ``LIBSSH2_FXF_WRITE``,

          for both ``LIBSSH2_FXF_READ`` | ``LIBSSH2_FXF_WRITE``.
        :type flags: int
        :param mode: File permissions mode. ``LIBSSH2_SFTP_S_IRUSR`` for
          reading.

          For writing one or more ``LIBSSH2_SFTP_S_*`` flags.

          Eg, for 664 permission mask (read/write owner/group, read other),

          mode is

          ``LIBSSH2_SFTP_S_IRUSR | LIBSSH2_SFTP_S_IWUSR | \``
          ``LIBSSH2_SFTP_S_IRGRP | LIBSSH2_SFTP_S_IWGRP | \``
          ``LIBSSH2_SFTP_S_IROTH``
        :type mode: int

        :raises: :py:class:`ssh2.exceptions.SFTPHandleError` on errors opening
          file.
        """  # noqa: W605
        cdef c_sftp.LIBSSH2_SFTP_HANDLE *_handle
        cdef bytes b_filename = to_bytes(filename)
        cdef char *_filename = b_filename
        with nogil:
            _handle = c_sftp.libssh2_sftp_open(
                self._sftp, _filename, flags, mode)
        if _handle is NULL:
            return handle_error_codes(c_ssh2.libssh2_session_last_errno(
                self._session._session))
        return PySFTPHandle(_handle, self)

    def opendir(self, path not None):
        """Open handle to directory path.

        :param path: Path of directory
        :type path: str

        :rtype: :py:class:`ssh2.sftp.SFTPHandle` or `None`

        :raises: :py:class:`ssh2.exceptions.SFTPHandleError` on errors opening
          directory.
        """
        cdef c_sftp.LIBSSH2_SFTP_HANDLE *_handle
        cdef bytes b_path = to_bytes(path)
        cdef char *_path = b_path
        with nogil:
            _handle = c_sftp.libssh2_sftp_opendir(self._sftp, _path)
        if _handle is NULL:
            return handle_error_codes(c_ssh2.libssh2_session_last_errno(
                self._session._session))
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
        return handle_error_codes(rc)

    def rename(self, source_filename not None, dest_filename not None):
        """Rename file.

        :param source_filename: Old name of file.
        :type source_filename: str
        :param dest_filename: New name of file.
        :type dest_filename: str"""
        cdef int rc
        cdef bytes b_source_filename = to_bytes(source_filename)
        cdef bytes b_dest_filename = to_bytes(dest_filename)
        cdef char *_source_filename = b_source_filename
        cdef char *_dest_filename = b_dest_filename
        with nogil:
            rc = c_sftp.libssh2_sftp_rename(
                self._sftp, _source_filename, _dest_filename)
        return handle_error_codes(rc)

    def unlink(self, filename not None):
        """Delete/unlink file.

        :param filename: Name of file to delete/unlink.
        :type filename: str"""
        cdef int rc
        cdef bytes b_filename = to_bytes(filename)
        cdef char *_filename = b_filename
        with nogil:
            rc = c_sftp.libssh2_sftp_unlink(self._sftp, _filename)
        return handle_error_codes(rc)

    def statvfs(self, path):
        """Get file system statistics from path.

        :rtype: `ssh2.sftp.SFTPStatVFS` or int of error code"""
        cdef SFTPStatVFS vfs = SFTPStatVFS(self)
        cdef bytes b_path = to_bytes(path)
        cdef char *_path = b_path
        cdef size_t path_len = len(b_path)
        with nogil:
            rc = c_sftp.libssh2_sftp_statvfs(
                self._sftp, _path, path_len, vfs._ptr)
        return handle_error_codes(rc) if rc != 0 else vfs

    def mkdir(self, path not None, long mode):
        """Make directory.

        :param path: Path of directory to create.
        :type path: str
        :param mode: Permissions mode of new directory.
        :type mode: int

        :rtype: int

        :raises: Appropriate exception from :py:mod:`ssh2.exceptions` on errors.
        """
        cdef int rc
        cdef bytes b_path = to_bytes(path)
        cdef char *_path = b_path
        with nogil:
            rc = c_sftp.libssh2_sftp_mkdir(self._sftp, _path, mode)
        return handle_error_codes(rc)

    def rmdir(self, path not None):
        """Remove directory.

        :param path: Directory path to remove.
        :type path: str

        :rtype: int"""
        cdef int rc
        cdef bytes b_path = to_bytes(path)
        cdef char *_path = b_path
        with nogil:
            rc = c_sftp.libssh2_sftp_rmdir(self._sftp, _path)
        return handle_error_codes(rc)

    def stat(self, path not None):
        """Stat file.

        :param path: Path of file to stat.
        :type path: str

        :rtype: :py:class:`ssh2.sftp_handle.SFTPAttributes` or
          LIBSSH2_ERROR_EAGAIN"""
        cdef int rc
        cdef bytes b_path = to_bytes(path)
        cdef char *_path = b_path
        cdef SFTPAttributes attrs = SFTPAttributes()
        with nogil:
            rc = c_sftp.libssh2_sftp_stat(
                self._sftp, _path, attrs._attrs)
        return handle_error_codes(rc) if rc != 0 else attrs

    def lstat(self, path not None):
        """Link stat a file."""
        cdef int rc
        cdef bytes b_path = to_bytes(path)
        cdef char *_path = b_path
        cdef SFTPAttributes attrs = SFTPAttributes()
        with nogil:
            rc = c_sftp.libssh2_sftp_lstat(
                self._sftp, _path, attrs._attrs)
        return handle_error_codes(rc) if rc != 0 else attrs

    def setstat(self, path not None, SFTPAttributes attrs):
        """Set file attributes.

        :param path: File path.
        :type path: str
        :param attrs: File attributes to set.
        :type attrs: :py:class:`ssh2.sftp_handle.SFTPAttributes`

        :rtype: int"""
        cdef int rc
        cdef bytes b_path = to_bytes(path)
        cdef char *_path = b_path
        with nogil:
            rc = c_sftp.libssh2_sftp_setstat(
                self._sftp, _path, attrs._attrs)
        return handle_error_codes(rc)

    def symlink(self, path not None, target not None):
        """Create symlink.

        :param path: Source file path.
        :type path: str
        :param target: Target file path.
        :type target: str

        :rtype: int"""
        cdef int rc
        cdef bytes b_path = to_bytes(path)
        cdef char *_path = b_path
        cdef bytes b_target = to_bytes(target)
        cdef char *_target = b_target
        with nogil:
            rc = c_sftp.libssh2_sftp_symlink(self._sftp, _path, _target)
        return handle_error_codes(rc)

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
        if _target is NULL:
            raise MemoryError
        cdef int rc
        cdef bytes b_path = to_bytes(path)
        cdef char *_path = b_path
        try:
            with nogil:
                rc = c_sftp.libssh2_sftp_realpath(
                    self._sftp, _path, _target, max_len)
                if rc < 0:
                    with gil:
                        return handle_error_codes(rc)
            return to_str_len(_target, rc)
        finally:
            free(_target)

    def last_error(self):
        """Get last error code from SFTP channel.

        :rtype: int"""
        cdef unsigned long rc
        with nogil:
            rc = c_sftp.libssh2_sftp_last_error(self._sftp)
        return rc
