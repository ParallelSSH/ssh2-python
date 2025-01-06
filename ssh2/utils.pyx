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
    # Cython generates a C switch from this code - only use equality checks
    if errcode == 0:
        return 0
    elif errcode == error_codes._LIBSSH2_ERROR_EAGAIN:
        return errcode
    elif errcode == error_codes._LIBSSH2_ERROR_SOCKET_NONE:
        raise exceptions.SSH2Error(errcode)
    elif errcode == error_codes._LIBSSH2_ERROR_BANNER_RECV:
        raise exceptions.BannerRecvError(errcode)
    elif errcode == error_codes._LIBSSH2_ERROR_BANNER_SEND:
        raise exceptions.BannerSendError(errcode)
    elif errcode == error_codes._LIBSSH2_ERROR_INVALID_MAC:
        raise exceptions.InvalidMACError(errcode)
    elif errcode == error_codes._LIBSSH2_ERROR_KEX_FAILURE:
        raise exceptions.KexFailureError(errcode)
    elif errcode == error_codes._LIBSSH2_ERROR_ALLOC:
        raise exceptions.AllocError(errcode)
    elif errcode == error_codes._LIBSSH2_ERROR_SOCKET_SEND:
        raise exceptions.SocketSendError(errcode)
    elif errcode == error_codes._LIBSSH2_ERROR_KEY_EXCHANGE_FAILURE:
        raise exceptions.KeyExchangeError(errcode)
    elif errcode == error_codes._LIBSSH2_ERROR_TIMEOUT:
        raise exceptions.Timeout(errcode)
    elif errcode == error_codes._LIBSSH2_ERROR_HOSTKEY_INIT:
        raise exceptions.HostkeyInitError(errcode)
    elif errcode == error_codes._LIBSSH2_ERROR_HOSTKEY_SIGN:
        raise exceptions.HostkeySignError(errcode)
    elif errcode == error_codes._LIBSSH2_ERROR_DECRYPT:
        raise exceptions.DecryptError(errcode)
    elif errcode == error_codes._LIBSSH2_ERROR_SOCKET_DISCONNECT:
        raise exceptions.SocketDisconnectError(errcode)
    elif errcode == error_codes._LIBSSH2_ERROR_PROTO:
        raise exceptions.ProtocolError(errcode)
    elif errcode == error_codes._LIBSSH2_ERROR_PASSWORD_EXPIRED:
        raise exceptions.PasswordExpiredError(errcode)
    elif errcode == error_codes._LIBSSH2_ERROR_FILE:
        raise exceptions.FileError(errcode)
    elif errcode == error_codes._LIBSSH2_ERROR_METHOD_NONE:
        raise exceptions.MethodNoneError(errcode)
    elif errcode == error_codes._LIBSSH2_ERROR_AUTHENTICATION_FAILED:
        raise exceptions.AuthenticationError(errcode)
    elif errcode == error_codes._LIBSSH2_ERROR_PUBLICKEY_UNVERIFIED:
        raise exceptions.PublickeyUnverifiedError(errcode)
    elif errcode == error_codes._LIBSSH2_ERROR_CHANNEL_OUTOFORDER:
        raise exceptions.ChannelOutOfOrderError(errcode)
    elif errcode == error_codes._LIBSSH2_ERROR_CHANNEL_FAILURE:
        raise exceptions.ChannelFailure(errcode)
    elif errcode == error_codes._LIBSSH2_ERROR_CHANNEL_REQUEST_DENIED:
        raise exceptions.ChannelRequestDenied(errcode)
    elif errcode == error_codes._LIBSSH2_ERROR_CHANNEL_UNKNOWN:
        raise exceptions.ChannelUnknownError(errcode)
    elif errcode == error_codes._LIBSSH2_ERROR_CHANNEL_WINDOW_EXCEEDED:
        raise exceptions.ChannelWindowExceeded(errcode)
    elif errcode == error_codes._LIBSSH2_ERROR_CHANNEL_PACKET_EXCEEDED:
        raise exceptions.ChannelPacketExceeded(errcode)
    elif errcode == error_codes._LIBSSH2_ERROR_CHANNEL_CLOSED:
        raise exceptions.ChannelClosedError(errcode)
    elif errcode == error_codes._LIBSSH2_ERROR_CHANNEL_EOF_SENT:
        raise exceptions.ChannelEOFSentError(errcode)
    elif errcode == error_codes._LIBSSH2_ERROR_SCP_PROTOCOL:
        raise exceptions.SCPProtocolError(errcode)
    elif errcode == error_codes._LIBSSH2_ERROR_ZLIB:
        raise exceptions.ZlibError(errcode)
    elif errcode == error_codes._LIBSSH2_ERROR_SOCKET_TIMEOUT:
        raise exceptions.SocketTimeout(errcode)
    elif errcode == error_codes._LIBSSH2_ERROR_SFTP_PROTOCOL:
        raise exceptions.SFTPProtocolError(errcode)
    elif errcode == error_codes._LIBSSH2_ERROR_REQUEST_DENIED:
        raise exceptions.RequestDeniedError(errcode)
    elif errcode == error_codes._LIBSSH2_ERROR_METHOD_NOT_SUPPORTED:
        raise exceptions.MethodNotSupported(errcode)
    elif errcode == error_codes._LIBSSH2_ERROR_INVAL:
        raise exceptions.InvalidRequestError(errcode)
    elif errcode == error_codes._LIBSSH2_ERROR_INVALID_POLL_TYPE:
        raise exceptions.InvalidPollTypeError(errcode)
    elif errcode == error_codes._LIBSSH2_ERROR_PUBLICKEY_PROTOCOL:
        raise exceptions.PublicKeyProtocolError(errcode)
    elif errcode == error_codes._LIBSSH2_ERROR_BUFFER_TOO_SMALL:
        raise exceptions.BufferTooSmallError(errcode)
    elif errcode == error_codes._LIBSSH2_ERROR_BAD_USE:
        raise exceptions.BadUseError(errcode)
    elif errcode == error_codes._LIBSSH2_ERROR_COMPRESS:
        raise exceptions.CompressError(errcode)
    elif errcode == error_codes._LIBSSH2_ERROR_OUT_OF_BOUNDARY:
        raise exceptions.OutOfBoundaryError(errcode)
    elif errcode == error_codes._LIBSSH2_ERROR_AGENT_PROTOCOL:
        raise exceptions.AgentProtocolError(errcode)
    elif errcode == error_codes._LIBSSH2_ERROR_SOCKET_RECV:
        raise exceptions.SocketRecvError(errcode)
    elif errcode == error_codes._LIBSSH2_ERROR_ENCRYPT:
        raise exceptions.EncryptError(errcode)
    elif errcode == error_codes._LIBSSH2_ERROR_BAD_SOCKET:
        raise exceptions.BadSocketError(errcode)
    elif errcode == error_codes._LIBSSH2_ERROR_KNOWN_HOSTS:
        raise exceptions.KnownHostError(errcode)
    elif errcode == error_codes._LIBSSH2_ERROR_CHANNEL_WINDOW_FULL:
        raise exceptions.ChannelWindowFullError(errcode)
    elif errcode == error_codes._LIBSSH2_ERROR_KEYFILE_AUTH_FAILED:
        raise exceptions.KeyfileAuthFailedError(errcode)
    else:
        # Switch default
        if errcode < 0:
            raise exceptions.UnknownError("Error code %s not known", errcode)
        return errcode


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
    if errcode == 0:
        return 0
    elif errcode == error_codes._LIBSSH2_ERROR_EAGAIN:
        return errcode
    elif errcode == error_codes._LIBSSH2_ERROR_SOCKET_NONE:
        raise exceptions.SSH2Error(errcode, errmsg)
    elif errcode == error_codes._LIBSSH2_ERROR_BANNER_RECV:
        raise exceptions.BannerRecvError(errcode, errmsg)
    elif errcode == error_codes._LIBSSH2_ERROR_BANNER_SEND:
        raise exceptions.BannerSendError(errcode, errmsg)
    elif errcode == error_codes._LIBSSH2_ERROR_INVALID_MAC:
        raise exceptions.InvalidMACError(errcode, errmsg)
    elif errcode == error_codes._LIBSSH2_ERROR_KEX_FAILURE:
        raise exceptions.KexFailureError(errcode, errmsg)
    elif errcode == error_codes._LIBSSH2_ERROR_ALLOC:
        raise exceptions.AllocError(errcode, errmsg)
    elif errcode == error_codes._LIBSSH2_ERROR_SOCKET_SEND:
        raise exceptions.SocketSendError(errcode, errmsg)
    elif errcode == error_codes._LIBSSH2_ERROR_KEY_EXCHANGE_FAILURE:
        raise exceptions.KeyExchangeError(errcode, errmsg)
    elif errcode == error_codes._LIBSSH2_ERROR_TIMEOUT:
        raise exceptions.Timeout(errcode, errmsg)
    elif errcode == error_codes._LIBSSH2_ERROR_HOSTKEY_INIT:
        raise exceptions.HostkeyInitError(errcode, errmsg)
    elif errcode == error_codes._LIBSSH2_ERROR_HOSTKEY_SIGN:
        raise exceptions.HostkeySignError(errcode, errmsg)
    elif errcode == error_codes._LIBSSH2_ERROR_DECRYPT:
        raise exceptions.DecryptError(errcode, errmsg)
    elif errcode == error_codes._LIBSSH2_ERROR_SOCKET_DISCONNECT:
        raise exceptions.SocketDisconnectError(errcode, errmsg)
    elif errcode == error_codes._LIBSSH2_ERROR_PROTO:
        raise exceptions.ProtocolError(errcode, errmsg)
    elif errcode == error_codes._LIBSSH2_ERROR_PASSWORD_EXPIRED:
        raise exceptions.PasswordExpiredError(errcode, errmsg)
    elif errcode == error_codes._LIBSSH2_ERROR_FILE:
        raise exceptions.FileError(errcode, errmsg)
    elif errcode == error_codes._LIBSSH2_ERROR_METHOD_NONE:
        raise exceptions.MethodNoneError(errcode, errmsg)
    elif errcode == error_codes._LIBSSH2_ERROR_AUTHENTICATION_FAILED:
        raise exceptions.AuthenticationError(errcode, errmsg)
    elif errcode == error_codes._LIBSSH2_ERROR_PUBLICKEY_UNVERIFIED:
        raise exceptions.PublickeyUnverifiedError(errcode, errmsg)
    elif errcode == error_codes._LIBSSH2_ERROR_CHANNEL_OUTOFORDER:
        raise exceptions.ChannelOutOfOrderError(errcode, errmsg)
    elif errcode == error_codes._LIBSSH2_ERROR_CHANNEL_FAILURE:
        raise exceptions.ChannelFailure(errcode, errmsg)
    elif errcode == error_codes._LIBSSH2_ERROR_CHANNEL_REQUEST_DENIED:
        raise exceptions.ChannelRequestDenied(errcode, errmsg)
    elif errcode == error_codes._LIBSSH2_ERROR_CHANNEL_UNKNOWN:
        raise exceptions.ChannelUnknownError(errcode, errmsg)
    elif errcode == error_codes._LIBSSH2_ERROR_CHANNEL_WINDOW_EXCEEDED:
        raise exceptions.ChannelWindowExceeded(errcode, errmsg)
    elif errcode == error_codes._LIBSSH2_ERROR_CHANNEL_PACKET_EXCEEDED:
        raise exceptions.ChannelPacketExceeded(errcode, errmsg)
    elif errcode == error_codes._LIBSSH2_ERROR_CHANNEL_CLOSED:
        raise exceptions.ChannelClosedError(errcode, errmsg)
    elif errcode == error_codes._LIBSSH2_ERROR_CHANNEL_EOF_SENT:
        raise exceptions.ChannelEOFSentError(errcode, errmsg)
    elif errcode == error_codes._LIBSSH2_ERROR_SCP_PROTOCOL:
        raise exceptions.SCPProtocolError(errcode, errmsg)
    elif errcode == error_codes._LIBSSH2_ERROR_ZLIB:
        raise exceptions.ZlibError(errcode, errmsg)
    elif errcode == error_codes._LIBSSH2_ERROR_SOCKET_TIMEOUT:
        raise exceptions.SocketTimeout(errcode, errmsg)
    elif errcode == error_codes._LIBSSH2_ERROR_SFTP_PROTOCOL:
        raise exceptions.SFTPProtocolError(errcode, errmsg)
    elif errcode == error_codes._LIBSSH2_ERROR_REQUEST_DENIED:
        raise exceptions.RequestDeniedError(errcode, errmsg)
    elif errcode == error_codes._LIBSSH2_ERROR_METHOD_NOT_SUPPORTED:
        raise exceptions.MethodNotSupported(errcode, errmsg)
    elif errcode == error_codes._LIBSSH2_ERROR_INVAL:
        raise exceptions.InvalidRequestError(errcode, errmsg)
    elif errcode == error_codes._LIBSSH2_ERROR_INVALID_POLL_TYPE:
        raise exceptions.InvalidPollTypeError(errcode, errmsg)
    elif errcode == error_codes._LIBSSH2_ERROR_PUBLICKEY_PROTOCOL:
        raise exceptions.PublicKeyProtocolError(errcode, errmsg)
    elif errcode == error_codes._LIBSSH2_ERROR_BUFFER_TOO_SMALL:
        raise exceptions.BufferTooSmallError(errcode, errmsg)
    elif errcode == error_codes._LIBSSH2_ERROR_BAD_USE:
        raise exceptions.BadUseError(errcode, errmsg)
    elif errcode == error_codes._LIBSSH2_ERROR_COMPRESS:
        raise exceptions.CompressError(errcode, errmsg)
    elif errcode == error_codes._LIBSSH2_ERROR_OUT_OF_BOUNDARY:
        raise exceptions.OutOfBoundaryError(errcode, errmsg)
    elif errcode == error_codes._LIBSSH2_ERROR_AGENT_PROTOCOL:
        raise exceptions.AgentProtocolError(errcode, errmsg)
    elif errcode == error_codes._LIBSSH2_ERROR_SOCKET_RECV:
        raise exceptions.SocketRecvError(errcode, errmsg)
    elif errcode == error_codes._LIBSSH2_ERROR_ENCRYPT:
        raise exceptions.EncryptError(errcode, errmsg)
    elif errcode == error_codes._LIBSSH2_ERROR_BAD_SOCKET:
        raise exceptions.BadSocketError(errcode, errmsg)
    elif errcode == error_codes._LIBSSH2_ERROR_KNOWN_HOSTS:
        raise exceptions.KnownHostError(errcode, errmsg)
    elif errcode == error_codes._LIBSSH2_ERROR_CHANNEL_WINDOW_FULL:
        raise exceptions.ChannelWindowFullError(errcode, errmsg)
    elif errcode == error_codes._LIBSSH2_ERROR_KEYFILE_AUTH_FAILED:
        raise exceptions.KeyfileAuthFailedError(errcode, errmsg)
    else:
        # Switch default
        if errcode < 0:
            raise exceptions.UnknownError("Error '%s - %s' not known", errcode, errmsg)
        return errcode
