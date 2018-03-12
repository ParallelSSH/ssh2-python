# This file is part of ssh2-python.
# Copyright (C) 2017-2018 Panos Kittenis

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

from select import select

from cpython.version cimport PY_MAJOR_VERSION

from session cimport Session
import exceptions
cimport c_ssh2
cimport error_codes


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
    """Raise appropriate exception for given error code.

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
        raise exceptions.SSH2Error
    elif errcode == error_codes._LIBSSH2_ERROR_BANNER_RECV:
        raise exceptions.BannerRecvError
    elif errcode == error_codes._LIBSSH2_ERROR_BANNER_SEND:
        raise exceptions.BannerSendError
    elif errcode == error_codes._LIBSSH2_ERROR_KEY_EXCHANGE_FAILURE:
        raise exceptions.KeyExchangeError
    elif errcode == error_codes._LIBSSH2_ERROR_TIMEOUT:
        raise exceptions.Timeout
    elif errcode == error_codes._LIBSSH2_ERROR_HOSTKEY_INIT:
        raise exceptions.HostkeyInitError
    elif errcode == error_codes._LIBSSH2_ERROR_HOSTKEY_SIGN:
        raise exceptions.HostkeySignError
    elif errcode == error_codes._LIBSSH2_ERROR_DECRYPT:
        raise exceptions.DecryptError
    elif errcode == error_codes._LIBSSH2_ERROR_SOCKET_DISCONNECT:
        raise exceptions.SocketDisconnectError
    elif errcode == error_codes._LIBSSH2_ERROR_PROTO:
        raise exceptions.ProtocolError
    elif errcode == error_codes._LIBSSH2_ERROR_PASSWORD_EXPIRED:
        raise exceptions.PasswordExpiredError
    elif errcode == error_codes._LIBSSH2_ERROR_FILE:
        raise exceptions.FileError
    elif errcode == error_codes._LIBSSH2_ERROR_METHOD_NONE:
        raise exceptions.MethodNoneError
    elif errcode == error_codes._LIBSSH2_ERROR_AUTHENTICATION_FAILED:
        raise exceptions.AuthenticationError
    elif errcode == error_codes._LIBSSH2_ERROR_PUBLICKEY_UNVERIFIED:
        raise exceptions.PublickeyUnverifiedError
    elif errcode == error_codes._LIBSSH2_ERROR_CHANNEL_OUTOFORDER:
        raise exceptions.ChannelOutOfOrderError
    elif errcode == error_codes._LIBSSH2_ERROR_CHANNEL_FAILURE:
        raise exceptions.ChannelFailure
    elif errcode == error_codes._LIBSSH2_ERROR_CHANNEL_REQUEST_DENIED:
        raise exceptions.ChannelRequestDenied
    elif errcode == error_codes._LIBSSH2_ERROR_CHANNEL_UNKNOWN:
        raise exceptions.ChannelUnknownError
    elif errcode == error_codes._LIBSSH2_ERROR_CHANNEL_WINDOW_EXCEEDED:
        raise exceptions.ChannelWindowExceeded
    elif errcode == error_codes._LIBSSH2_ERROR_CHANNEL_PACKET_EXCEEDED:
        raise exceptions.ChannelPacketExceeded
    elif errcode == error_codes._LIBSSH2_ERROR_CHANNEL_CLOSED:
        raise exceptions.ChannelClosedError
    elif errcode == error_codes._LIBSSH2_ERROR_CHANNEL_EOF_SENT:
        raise exceptions.ChannelEOFSentError
    elif errcode == error_codes._LIBSSH2_ERROR_SCP_PROTOCOL:
        raise exceptions.SCPProtocolError
    elif errcode == error_codes._LIBSSH2_ERROR_ZLIB:
        raise exceptions.ZlibError
    elif errcode == error_codes._LIBSSH2_ERROR_SOCKET_TIMEOUT:
        raise exceptions.SocketTimeout
    elif errcode == error_codes._LIBSSH2_ERROR_SFTP_PROTOCOL:
        raise exceptions.SFTPProtocolError
    elif errcode == error_codes._LIBSSH2_ERROR_REQUEST_DENIED:
        raise exceptions.RequestDeniedError
    elif errcode == error_codes._LIBSSH2_ERROR_METHOD_NOT_SUPPORTED:
        raise exceptions.MethodNotSupported
    elif errcode == error_codes._LIBSSH2_ERROR_INVAL:
        raise exceptions.InvalidRequestError
    elif errcode == error_codes._LIBSSH2_ERROR_INVALID_POLL_TYPE:
        raise exceptions.InvalidPollTypeError
    elif errcode == error_codes._LIBSSH2_ERROR_PUBLICKEY_PROTOCOL:
        raise exceptions.PublicKeyProtocolError
    elif errcode == error_codes._LIBSSH2_ERROR_BUFFER_TOO_SMALL:
        raise exceptions.BufferTooSmallError
    elif errcode == error_codes._LIBSSH2_ERROR_BAD_USE:
        raise exceptions.BadUseError
    elif errcode == error_codes._LIBSSH2_ERROR_COMPRESS:
        raise exceptions.CompressError
    elif errcode == error_codes._LIBSSH2_ERROR_OUT_OF_BOUNDARY:
        raise exceptions.OutOfBoundaryError
    elif errcode == error_codes._LIBSSH2_ERROR_AGENT_PROTOCOL:
        raise exceptions.AgentProtocolError
    elif errcode == error_codes._LIBSSH2_ERROR_SOCKET_RECV:
        raise exceptions.SocketRecvError
    elif errcode == error_codes._LIBSSH2_ERROR_SOCKET_SEND:
        raise exceptions.SocketSendError
    elif errcode == error_codes._LIBSSH2_ERROR_ENCRYPT:
        raise exceptions.EncryptError
    elif errcode == error_codes._LIBSSH2_ERROR_BAD_SOCKET:
        raise exceptions.BadSocketError
    elif errcode == error_codes._LIBSSH2_ERROR_KNOWN_HOSTS:
        raise exceptions.KnownHostError
    else:
        # Switch default
        if errcode < 0:
            raise exceptions.UnknownError("Error code %s not known", errcode)
        return errcode
