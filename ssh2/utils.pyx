# This file is part of ssh2-python.
# Copyright (C) 2017-2020 Panos Kittenis
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

from select import select

from cpython.version cimport PY_MAJOR_VERSION

from .session cimport Session
from . import exceptions
from . cimport c_ssh2
from . cimport error_codes


ENCODING='utf-8'


cdef bytes to_bytes(_str):
    if isinstance(_str, bytes):
        return _str
    elif isinstance(_str, unicode):
        return _str.encode(ENCODING)
    return _str


cdef object to_str(char *c_str):
    _len = len(c_str)
    if PY_MAJOR_VERSION < 3:
        return c_str[:_len]
    return c_str[:_len].decode(ENCODING)


cdef object to_str_len(char *c_str, int length):
    if PY_MAJOR_VERSION < 3:
        return c_str[:length]
    return c_str[:length].decode(ENCODING)


def find_eol(bytes buf, Py_ssize_t pos):
    """Find end-of-line in buffer from position and return end position of
    line and where next find_eol should start from.

    Eg - find_eol(b'line\nline2', 0) would return (5, 6), next call should be
    find_eol(b'line\nline2', 6) for next line where 6 was added to previous
    position.

    :param buf: Data buffer to parse for line.
    :type buf: bytes
    :param pos: Starting position to parse from
    :type pos: int

    :rtype: (int, int)"""
    cdef Py_ssize_t buf_len = len(buf)
    if buf_len == 0:
        return -1, pos
    cdef bytes cur_buf = buf[pos:buf_len]
    cdef char* c_buf = cur_buf
    cdef int index
    cdef int new_pos
    with nogil:
        new_pos = 0
        index = c_find_eol(c_buf, &new_pos)
    return index, new_pos


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


def wait_socket(_socket not None, Session session, timeout=1):
    """Helper function for testing non-blocking mode.

    This function blocks the calling thread for <timeout> seconds -
    to be used only for testing purposes.
    """
    cdef int directions = session.block_directions()
    if directions == 0:
        return 0
    readfds = [_socket] \
        if (directions & c_ssh2.LIBSSH2_SESSION_BLOCK_INBOUND) else ()
    writefds = [_socket] \
        if (directions & c_ssh2.LIBSSH2_SESSION_BLOCK_OUTBOUND) else ()
    return select(readfds, writefds, (), timeout)


def _get_exc_from_errcode(int errcode):
    if errcode == 0:
        return None
    elif errcode == error_codes._LIBSSH2_ERROR_EAGAIN:
        return None
    elif errcode == error_codes._LIBSSH2_ERROR_SOCKET_NONE:
        return exceptions.SSH2Error
    elif errcode == error_codes._LIBSSH2_ERROR_BANNER_RECV:
        return exceptions.BannerRecvError
    elif errcode == error_codes._LIBSSH2_ERROR_BANNER_SEND:
        return exceptions.BannerSendError
    elif errcode == error_codes._LIBSSH2_ERROR_INVALID_MAC:
        return exceptions.InvalidMACError
    elif errcode == error_codes._LIBSSH2_ERROR_KEX_FAILURE:
        return exceptions.KexFailureError
    elif errcode == error_codes._LIBSSH2_ERROR_ALLOC:
        return exceptions.AllocError
    elif errcode == error_codes._LIBSSH2_ERROR_SOCKET_SEND:
        return exceptions.SocketSendError
    elif errcode == error_codes._LIBSSH2_ERROR_KEY_EXCHANGE_FAILURE:
        return exceptions.KeyExchangeError
    elif errcode == error_codes._LIBSSH2_ERROR_TIMEOUT:
        return exceptions.Timeout
    elif errcode == error_codes._LIBSSH2_ERROR_HOSTKEY_INIT:
        return exceptions.HostkeyInitError
    elif errcode == error_codes._LIBSSH2_ERROR_HOSTKEY_SIGN:
        return exceptions.HostkeySignError
    elif errcode == error_codes._LIBSSH2_ERROR_DECRYPT:
        return exceptions.DecryptError
    elif errcode == error_codes._LIBSSH2_ERROR_SOCKET_DISCONNECT:
        return exceptions.SocketDisconnectError
    elif errcode == error_codes._LIBSSH2_ERROR_PROTO:
        return exceptions.ProtocolError
    elif errcode == error_codes._LIBSSH2_ERROR_PASSWORD_EXPIRED:
        return exceptions.PasswordExpiredError
    elif errcode == error_codes._LIBSSH2_ERROR_FILE:
        return exceptions.FileError
    elif errcode == error_codes._LIBSSH2_ERROR_METHOD_NONE:
        return exceptions.MethodNoneError
    elif errcode == error_codes._LIBSSH2_ERROR_AUTHENTICATION_FAILED:
        return exceptions.AuthenticationError
    elif errcode == error_codes._LIBSSH2_ERROR_PUBLICKEY_UNVERIFIED:
        return exceptions.PublickeyUnverifiedError
    elif errcode == error_codes._LIBSSH2_ERROR_CHANNEL_OUTOFORDER:
        return exceptions.ChannelOutOfOrderError
    elif errcode == error_codes._LIBSSH2_ERROR_CHANNEL_FAILURE:
        return exceptions.ChannelFailure
    elif errcode == error_codes._LIBSSH2_ERROR_CHANNEL_REQUEST_DENIED:
        return exceptions.ChannelRequestDenied
    elif errcode == error_codes._LIBSSH2_ERROR_CHANNEL_UNKNOWN:
        return exceptions.ChannelUnknownError
    elif errcode == error_codes._LIBSSH2_ERROR_CHANNEL_WINDOW_EXCEEDED:
        return exceptions.ChannelWindowExceeded
    elif errcode == error_codes._LIBSSH2_ERROR_CHANNEL_PACKET_EXCEEDED:
        return exceptions.ChannelPacketExceeded
    elif errcode == error_codes._LIBSSH2_ERROR_CHANNEL_CLOSED:
        return exceptions.ChannelClosedError
    elif errcode == error_codes._LIBSSH2_ERROR_CHANNEL_EOF_SENT:
        return exceptions.ChannelEOFSentError
    elif errcode == error_codes._LIBSSH2_ERROR_SCP_PROTOCOL:
        return exceptions.SCPProtocolError
    elif errcode == error_codes._LIBSSH2_ERROR_ZLIB:
        return exceptions.ZlibError
    elif errcode == error_codes._LIBSSH2_ERROR_SOCKET_TIMEOUT:
        return exceptions.SocketTimeout
    elif errcode == error_codes._LIBSSH2_ERROR_SFTP_PROTOCOL:
        return exceptions.SFTPProtocolError
    elif errcode == error_codes._LIBSSH2_ERROR_REQUEST_DENIED:
        return exceptions.RequestDeniedError
    elif errcode == error_codes._LIBSSH2_ERROR_METHOD_NOT_SUPPORTED:
        return exceptions.MethodNotSupported
    elif errcode == error_codes._LIBSSH2_ERROR_INVAL:
        return exceptions.InvalidRequestError
    elif errcode == error_codes._LIBSSH2_ERROR_INVALID_POLL_TYPE:
        return exceptions.InvalidPollTypeError
    elif errcode == error_codes._LIBSSH2_ERROR_PUBLICKEY_PROTOCOL:
        return exceptions.PublicKeyProtocolError
    elif errcode == error_codes._LIBSSH2_ERROR_BUFFER_TOO_SMALL:
        return exceptions.BufferTooSmallError
    elif errcode == error_codes._LIBSSH2_ERROR_BAD_USE:
        return exceptions.BadUseError
    elif errcode == error_codes._LIBSSH2_ERROR_COMPRESS:
        return exceptions.CompressError
    elif errcode == error_codes._LIBSSH2_ERROR_OUT_OF_BOUNDARY:
        return exceptions.OutOfBoundaryError
    elif errcode == error_codes._LIBSSH2_ERROR_AGENT_PROTOCOL:
        return exceptions.AgentProtocolError
    elif errcode == error_codes._LIBSSH2_ERROR_SOCKET_RECV:
        return exceptions.SocketRecvError
    elif errcode == error_codes._LIBSSH2_ERROR_ENCRYPT:
        return exceptions.EncryptError
    elif errcode == error_codes._LIBSSH2_ERROR_BAD_SOCKET:
        return exceptions.BadSocketError
    elif errcode == error_codes._LIBSSH2_ERROR_KNOWN_HOSTS:
        return exceptions.KnownHostError
    elif errcode == error_codes._LIBSSH2_ERROR_CHANNEL_WINDOW_FULL:
        return exceptions.ChannelWindowFullError
    elif errcode == error_codes._LIBSSH2_ERROR_KEYFILE_AUTH_FAILED:
        return exceptions.KeyfileAuthFailedError
    else:
        # Switch default
        if errcode < 0:
            return exceptions.UnknownError
        return None

cpdef int handle_error_codes(int errcode) except -1:
    """This function is now deprecated - use handle_error_codes_msg to
    include error message in any exceptions raised.
    
    Will be removed in future versions.
    
    Raise appropriate exception for given error code.

    Returns 0 on no error and ``LIBSSH2_ERROR_EAGAIN`` on ``EAGAIN``.

    :raises: Appropriate exception from :py:mod:`ssh2.exceptions`.

    :param errcode: Error code as returned by
      :py:func:`ssh2.session.Session.last_errno`
    """
    exc_or_errcode = _get_exc_from_errcode(errcode)
    if exc_or_errcode is None:
        return errcode
    raise exc_or_errcode(errcode)


cpdef int handle_error_codes_msg(Session session) except -1:
    """Raise appropriate exception for given error code with 
    (error code, last error message) as the exception arguments.

    Returns 0 on no error and ``LIBSSH2_ERROR_EAGAIN`` on ``EAGAIN``.

    :raises: Appropriate exception from :py:mod:`ssh2.exceptions`.

    :param session: The :py:class:`ssh2.session.Session` session.
    """
    # Cython generates a C switch from this code - only use equality checks
    cdef int errcode = session.last_errno()
    cdef str errmsg = session.last_error()
    exc_or_errcode = _get_exc_from_errcode(errcode)
    if exc_or_errcode is None:
        return errcode
    raise exc_or_errcode(errcode, errmsg)
