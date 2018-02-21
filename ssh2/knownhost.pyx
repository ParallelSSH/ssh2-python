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

from base64 import b64decode
from libc.stdlib cimport malloc, free
from session cimport Session
from utils cimport to_bytes
from .exceptions import KnownHostAddError, KnownHostCheckMisMatchError, \
    KnownHostCheckFailure, KnownHostCheckNotFoundError, KnownHostError, \
    KnownHostDeleteError, KnownHostReadLineError, KnownHostReadFileError, \
    KnownHostWriteLineError, KnownHostWriteFileError, KnownHostGetError, \
    KnownHostCheckError
from error_codes cimport _LIBSSH2_ERROR_BUFFER_TOO_SMALL

cimport c_ssh2


# Host format type masks
LIBSSH2_KNOWNHOST_TYPE_MASK = c_ssh2.LIBSSH2_KNOWNHOST_TYPE_MASK
LIBSSH2_KNOWNHOST_TYPE_PLAIN = c_ssh2.LIBSSH2_KNOWNHOST_TYPE_PLAIN
LIBSSH2_KNOWNHOST_TYPE_SHA1 = c_ssh2.LIBSSH2_KNOWNHOST_TYPE_SHA1
LIBSSH2_KNOWNHOST_TYPE_CUSTOM = c_ssh2.LIBSSH2_KNOWNHOST_TYPE_CUSTOM

# Key format type masks
LIBSSH2_KNOWNHOST_KEYENC_MASK = c_ssh2.LIBSSH2_KNOWNHOST_KEYENC_MASK
LIBSSH2_KNOWNHOST_KEYENC_RAW = c_ssh2.LIBSSH2_KNOWNHOST_KEYENC_RAW
LIBSSH2_KNOWNHOST_KEYENC_BASE64 = c_ssh2.LIBSSH2_KNOWNHOST_KEYENC_BASE64

# Key type masks
LIBSSH2_KNOWNHOST_KEY_MASK = c_ssh2.LIBSSH2_KNOWNHOST_KEY_MASK
LIBSSH2_KNOWNHOST_KEY_SHIFT = c_ssh2.LIBSSH2_KNOWNHOST_KEY_SHIFT
LIBSSH2_KNOWNHOST_KEY_RSA1 = c_ssh2.LIBSSH2_KNOWNHOST_KEY_RSA1
LIBSSH2_KNOWNHOST_KEY_SSHRSA = c_ssh2.LIBSSH2_KNOWNHOST_KEY_SSHRSA
LIBSSH2_KNOWNHOST_KEY_SSHDSS = c_ssh2.LIBSSH2_KNOWNHOST_KEY_SSHDSS
IF EMBEDDED_LIB:
    LIBSSH2_KNOWNHOST_KEY_UNKNOWN = c_ssh2.LIBSSH2_KNOWNHOST_KEY_UNKNOWN


cdef KnownHost PyKnownHost(Session session, c_ssh2.LIBSSH2_KNOWNHOSTS *_ptr):
    cdef KnownHost known_host = KnownHost.__new__(KnownHost, session)
    known_host._ptr = _ptr
    return known_host


cdef KnownHostEntry PyKnownHostEntry(c_ssh2.libssh2_knownhost *_entry):
    cdef KnownHostEntry entry = KnownHostEntry.__new__(KnownHostEntry)
    entry._store = _entry
    return entry


cdef KnownHostEntry PyNewKnownHostEntry():
    cdef KnownHostEntry entry = KnownHostEntry.__new__(KnownHostEntry)
    cdef c_ssh2.libssh2_knownhost *_entry
    with nogil:
        _entry = <c_ssh2.libssh2_knownhost *>malloc(
            sizeof(c_ssh2.libssh2_knownhost))
        if _entry is NULL:
            with gil:
                raise MemoryError
        _entry.magic = 0
        _entry.node = NULL
        _entry.name = NULL
        _entry.key = NULL
        _entry.typemask = -1
        entry._store = _entry
    return entry


cdef class KnownHostEntry:
    """Class representing a single known host entry."""

    def __repr__(self):
        return "Known host entry for host: %s" % (self.name)

    def __str__(self):
        return self.__repr__()

    def _dealloc__(self):
        with nogil:
            free(self._store)

    @property
    def magic(self):
        """Entry magic number."""
        return self._store.magic

    @property
    def name(self):
        """Name of host."""
        return self._store.name if self._store.name is not NULL \
            else None

    @property
    def key(self):
        """Key byte string.

        Key is stored base64 encoded according to ``libssh2`` documentation
        and is returned by this property as a base64 decoded byte string.

        Note that in some cases, like keys added by
        :py:func:`ssh2.knownhost.KnownHost.readline`, the stored key is not
        base64 encoded, contrary to documentation, and ``KnownHostEntry.key``
        will need to be re-encoded as base64 to get actual key."""
        return b64decode(self._store.key) \
            if self._store.key is not NULL else None

    @property
    def typemask(self):
        """Type mask of host entry."""
        return self._store.typemask


cdef class KnownHost:
    """Manage known host entries."""

    def __cinit__(self, Session session):
        self._ptr = NULL
        self._session = session

    def __dealloc__(self):
        if self._ptr is not NULL:
            c_ssh2.libssh2_knownhost_free(self._ptr)
            self._ptr = NULL

    def add(self, bytes host, bytes salt, bytes key, int typemask):
        """Deprecated - use ``self.addc``"""
        raise NotImplementedError

    def addc(self, bytes host not None, bytes key not None,
             int typemask, bytes salt=None, bytes comment=None):
        """Adds a host and its key to known hosts collection.

        Note - ``libssh2`` expects correct use of hashed hosts when
        ``LIBSSH2_KNOWNHOST_TYPE_SHA1`` is part of typemask. Incorrect use of
        hashed host typemask without appropriate hashed host and salt values
        will result in host entries being added to the collection without a
        host name.

        :param host: Host to add key for.
        :type host: bytes
        :param key: Key to add.
        :type key: bytes
        :param typemask: Bitmask of one of each from
          ``ssh2.knownhost.LIBSSH2_KNOWNHOST_TYPE_*``,
          ``ssh2.knownhost.LIBSSH2_KNOWNHOST_KEYENC_*`` and
          ``ssh2.knownhost.LIBSSH2_KNOWNHOST_KEY_*`` for example for plain text
          host, raw key encoding and SSH RSA key ``type`` would be
          ``LIBSSH2_KNOWNHOST_TYPE_PLAIN | LIBSSH2_KNOWNHOST_KEYENC_RAW |
          LIBSSH2_KNOWNHOST_KEY_SSHRSA``.
        :param salt: Salt used for host hashing if host is hashed.
          Defaults to ``None``.
        :type salt: bytes
        :param comment: Comment to add for host. Defaults to ``None``.
        :type comment: bytes

        :raises: :py:class:`ssh2.exceptions.KnownHostAddError` on errors adding
          known host entry."""
        cdef size_t keylen = len(key)
        cdef size_t comment_len
        cdef char *_host = host
        cdef char *_salt
        if salt is not None:
            _salt = salt
        else:
            _salt = ""
        cdef char *_key = key
        cdef char *_comment
        if comment is not None:
            _comment = comment
        else:
            _comment = NULL
        cdef int rc
        cdef KnownHostEntry entry = PyNewKnownHostEntry()
        comment_len = len(comment) if comment is not None else 0
        with nogil:
            rc = c_ssh2.libssh2_knownhost_addc(
                self._ptr, _host, _salt, _key, keylen, _comment, comment_len,
                typemask, &entry._store)
        if rc != 0:
            raise KnownHostAddError(
                "Error adding known host entry for host %s - error code %s",
                host, rc)
        return entry

    def check(self, bytes host, bytes key, int typemask):
        """Deprecated - use ``self.checkp``"""
        raise NotImplementedError

    def checkp(self, bytes host not None, int port, bytes key not None,
               int typemask):
        """Check a host and its key against the known hosts collection and
        return known host entry, if any.

        Note that server key provided to this function must be base64 encoded
        only if checking against a ``self.addc`` added known public key.
        When using ``self.readfile`` and a known_hosts file, encoding is not
        needed.

        :py:class:`ssh2.exceptions.KnownHostCheckError` is base class for all
        host check error exceptions and can be used to catch all host check
        errors.

        :param host: Host to check.
        :type host: bytes
        :param key: Key of host to check.
        :type key: bytes
        :param typemask: Bitmask of one of each from
          ``ssh2.knownhost.LIBSSH2_KNOWNHOST_TYPE_*``,
          ``ssh2.knownhost.LIBSSH2_KNOWNHOST_KEYENC_*`` and
          ``ssh2.knownhost.LIBSSH2_KNOWNHOST_KEY_*`` for example for plain text
          host, raw key encoding and SSH RSA key ``type`` would be
          ``LIBSSH2_KNOWNHOST_TYPE_PLAIN | LIBSSH2_KNOWNHOST_KEYENC_RAW |
          LIBSSH2_KNOWNHOST_KEY_SSHRSA``.

        :raises: :py:class:`ssh2.exceptions.KnownHostCheckMisMatchError` on
          provided key mis-match error with found key from known hosts.
        :raises: :py:class:`ssh2.exceptions.KnownHostCheckNotFoundError` on
          host not found in known hosts.
        :raises: :py:class:`ssh2.exceptions.KnownHostCheckFailure` on failure
          checking known host entry.
        :raises: :py:class:`ssh2.exceptions.KnownHostCheckError` on unknown
          errors checking known host.

        :rtype: :py:class:`ssh2.knownhost.KnownHostEntry`"""
        cdef char *_host = host
        cdef char *_key = key
        cdef size_t keylen = len(key)
        cdef KnownHostEntry entry = PyNewKnownHostEntry()
        cdef int rc
        with nogil:
            rc = c_ssh2.libssh2_knownhost_checkp(
                self._ptr, _host, port, _key, keylen, typemask, &entry._store)
        if rc != c_ssh2.LIBSSH2_KNOWNHOST_CHECK_MATCH:
            if rc == c_ssh2.LIBSSH2_KNOWNHOST_CHECK_FAILURE:
                raise KnownHostCheckFailure(
                    "Could not check known host entry for host %s "
                    "- error code %s", host, rc)
            elif rc == c_ssh2.LIBSSH2_KNOWNHOST_CHECK_NOTFOUND:
                raise KnownHostCheckNotFoundError(
                    "Host %s not found in known hosts collection", host)
            elif rc == c_ssh2.LIBSSH2_KNOWNHOST_CHECK_MISMATCH:
                raise KnownHostCheckMisMatchError(
                    "Known host key for host %s does not match provided key - "
                    "error code %s", host, rc)
            raise KnownHostCheckError(
                "Unknown error occurred checking known host %s", host)
        return entry

    def delete(self, KnownHostEntry entry not None):
        """Delete given known host entry from collection of known hosts.

        :param entry: Known host entry to delete.
        :type entry: :py:class:`ssh2.knownhost.KnownHostEntry`

        :raises: :py:class:`ssh2.exceptions.KnownHostDeleteError` on errors
          deleting host entry."""
        cdef int rc
        with nogil:
            rc = c_ssh2.libssh2_knownhost_del(self._ptr, entry._store)
        if rc != 0:
            raise KnownHostDeleteError(
                "Error deleting known host entry - error code %s", rc)

    def readline(self, bytes line not None,
                 int f_type=c_ssh2.LIBSSH2_KNOWNHOST_FILE_OPENSSH):
        """Read line from known hosts file and add to known hosts
        collection. Only OpenSSH known hosts file format is currently supported.

        Note - When using readline, the key values returned by ``self.get`` will
        need to be base64 encoded as libssh2's readline does not encode them
        when adding, unlike ``self.readfile`` and ``self.addc``.

        :param line: Byte string representing line to read.
        :type line: bytes

        :raises: :py:class:`ssh2.exceptions.KnownHostReadLineError` on errors
          reading line."""
        cdef int rc
        cdef char *_line = line
        cdef size_t line_len = len(line)
        with nogil:
            rc = c_ssh2.libssh2_knownhost_readline(
                self._ptr, _line, line_len, f_type)
        if rc != 0:
            raise KnownHostReadLineError(
                "Error deleting line from known hosts - error code %s", rc)

    def readfile(self, filename not None,
                 int f_type=c_ssh2.LIBSSH2_KNOWNHOST_FILE_OPENSSH):
        """Read known hosts file and add hosts to known hosts collection.
        Only OpenSSH known hosts file format is currently supported.

        Returns number of successfully read host entries.

        :param filename: File name to read.
        :type filename: str

        :raises: :py:class:`ssh2.exceptions.KnownHostReadFileError` on errors
          reading file.

        :rtype: int"""
        cdef bytes b_filename = to_bytes(filename)
        cdef char *_filename = b_filename
        cdef int rc
        with nogil:
            rc = c_ssh2.libssh2_knownhost_readfile(
                self._ptr, _filename, f_type)
        if rc < 0:
            raise KnownHostReadFileError(
                "Error reading known hosts file %s - error code %s",
                filename, rc)
        return rc

    def writeline(self, KnownHostEntry entry,
                  int f_type=c_ssh2.LIBSSH2_KNOWNHOST_FILE_OPENSSH,
                  size_t buf_len=1024):
        """Convert a single known host entry to a single line of output
        for writing. Only OpenSSH known hosts file format is currently
        supported.

        :param entry: Known host entry to write line for.
        :type entry: :py:class:`ssh2.knownhost.KnownHostEntry`

        :raises: :py:class:`ssh2.exceptions.KnownHostWriteLineError` on errors
          writing line.

        :rtype: bytes"""
        cdef bytes output = b""
        cdef size_t outlen = 0
        cdef char *buf
        cdef int rc
        with nogil:
            buf = <char *>malloc(sizeof(char)*buf_len)
            if buf is NULL:
                with gil:
                    raise MemoryError
            rc = c_ssh2.libssh2_knownhost_writeline(
                self._ptr, entry._store, buf, buf_len, &outlen, f_type)
        try:
            if rc == _LIBSSH2_ERROR_BUFFER_TOO_SMALL:
                return self.writeline(entry, buf_len=buf_len*2)
            elif rc != 0:
                raise KnownHostWriteLineError(
                    "Error writing line for known host entry - error code %s",
                    rc)
            if outlen > 0:
                output = buf[:outlen]
        finally:
            free(buf)
        return output

    def writefile(self, filename not None,
                  int f_type=c_ssh2.LIBSSH2_KNOWNHOST_FILE_OPENSSH):
        """Write all known host entries to file. Only OpenSSH known hosts file
        format is currently supported.

        :param filename: File name to write known hosts to.
        :type filename: str

        :raises: :py:class:`ssh2.exceptions.KnownHostWriteFileError` on errors
          writing to file."""
        cdef bytes b_filename = to_bytes(filename)
        cdef char *_filename = b_filename
        cdef int rc
        with nogil:
            rc = c_ssh2.libssh2_knownhost_writefile(
                self._ptr, _filename, f_type)
        if rc != 0:
            raise KnownHostWriteFileError(
                "Error writing known hosts to file %s", filename)

    def get(self, KnownHostEntry prev=None):
        """Retrieve all host entries in known hosts collection.

        :param prev: (Optional) Existing known host entry to start retrieval
          from. All hosts are retrieved when prev is ``None`` which is the
          default.

        :raises: :py:class:`ssh2.exceptions.KnownHostGetError` on errors
          retrieving known host collection.

        :rtype: list(:py:class:`ssh2.knownhost.KnownHostEntry`)"""
        cdef c_ssh2.libssh2_knownhost *_store = NULL
        cdef c_ssh2.libssh2_knownhost *_prev = NULL
        cdef int rc
        cdef list entries = []
        if prev is not None:
            _prev = prev._store
        with nogil:
            rc = c_ssh2.libssh2_knownhost_get(
                self._ptr, &_store, _prev)
        while rc == 0:
            entries.append(PyKnownHostEntry(_store))
            _prev = _store
            with nogil:
                rc = c_ssh2.libssh2_knownhost_get(
                    self._ptr, &_store, _prev)
        if rc < 0:
            raise KnownHostGetError(
                "Error retrieving known hosts - error code %s", rc)
        return entries
