import unittest
from ssh2.error_codes import LIBSSH2_ERROR_NONE, LIBSSH2_ERROR_SOCKET_NONE, \
    LIBSSH2_ERROR_BANNER_RECV, LIBSSH2_ERROR_BANNER_SEND, \
    LIBSSH2_ERROR_KEY_EXCHANGE_FAILURE, LIBSSH2_ERROR_TIMEOUT, \
    LIBSSH2_ERROR_HOSTKEY_INIT,  LIBSSH2_ERROR_HOSTKEY_SIGN, \
    LIBSSH2_ERROR_DECRYPT, LIBSSH2_ERROR_SOCKET_DISCONNECT, \
    LIBSSH2_ERROR_PROTO, LIBSSH2_ERROR_PASSWORD_EXPIRED, \
    LIBSSH2_ERROR_FILE, LIBSSH2_ERROR_METHOD_NONE, \
    LIBSSH2_ERROR_AUTHENTICATION_FAILED, LIBSSH2_ERROR_PUBLICKEY_UNRECOGNIZED, \
    LIBSSH2_ERROR_PUBLICKEY_UNVERIFIED, LIBSSH2_ERROR_CHANNEL_OUTOFORDER, \
    LIBSSH2_ERROR_CHANNEL_FAILURE, LIBSSH2_ERROR_CHANNEL_REQUEST_DENIED, \
    LIBSSH2_ERROR_CHANNEL_UNKNOWN, LIBSSH2_ERROR_CHANNEL_WINDOW_EXCEEDED, \
    LIBSSH2_ERROR_CHANNEL_PACKET_EXCEEDED, LIBSSH2_ERROR_CHANNEL_CLOSED, \
    LIBSSH2_ERROR_CHANNEL_EOF_SENT, LIBSSH2_ERROR_SCP_PROTOCOL, \
    LIBSSH2_ERROR_ZLIB, LIBSSH2_ERROR_SOCKET_TIMEOUT, \
    LIBSSH2_ERROR_SFTP_PROTOCOL, LIBSSH2_ERROR_REQUEST_DENIED, \
    LIBSSH2_ERROR_METHOD_NOT_SUPPORTED, LIBSSH2_ERROR_INVAL, \
    LIBSSH2_ERROR_INVALID_POLL_TYPE, LIBSSH2_ERROR_PUBLICKEY_PROTOCOL, \
    LIBSSH2_ERROR_EAGAIN, LIBSSH2CHANNEL_EAGAIN, \
    LIBSSH2_ERROR_BUFFER_TOO_SMALL, LIBSSH2_ERROR_BAD_USE, \
    LIBSSH2_ERROR_COMPRESS, LIBSSH2_ERROR_OUT_OF_BOUNDARY, \
    LIBSSH2_ERROR_AGENT_PROTOCOL, LIBSSH2_ERROR_SOCKET_RECV, \
    LIBSSH2_ERROR_SOCKET_SEND, LIBSSH2_ERROR_ENCRYPT, \
    LIBSSH2_ERROR_BAD_SOCKET, LIBSSH2_ERROR_KNOWN_HOSTS
from ssh2.exceptions import SSH2Error, AgentError, AuthenticationError, \
    AgentConnectionError, AgentAuthenticationError, AgentListIdentitiesError, \
    AgentGetIdentityError, AgentProtocolError, SessionError, \
    SessionStartupError, SessionHandshakeError, SessionHostKeyError, \
    BannerRecvError, BannerSendError, KeyExchangeError, Timeout, \
    HostkeyInitError, HostkeySignError, DecryptError, SocketDisconnectError, \
    ProtocolError, PasswordExpiredError, FileError, MethodNoneError, \
    PublicKeyError, PublicKeyInitError, PublickeyUnverifiedError, \
    ChannelError, ChannelOutOfOrderError, ChannelFailure, \
    ChannelRequestDenied, ChannelUnknownError, ChannelWindowExceeded, \
    ChannelPacketExceeded, ChannelClosedError, ChannelEOFSentError, \
    SCPProtocolError, ZlibError, SocketTimeout, \
    RequestDeniedError, MethodNotSupported, InvalidRequestError, \
    InvalidPollTypeError, PublicKeyProtocolError, BufferTooSmallError, \
    BadUseError, CompressError, OutOfBoundaryError, SocketRecvError, \
    SocketSendError, EncryptError, BadSocketError, SFTPError, SFTPProtocolError, \
    KnownHostError, UnknownError
from ssh2.utils import handle_error_codes


class ErrorCodeExceptionsTest(unittest.TestCase):

    def test_no_exceptions(self):
        self.assertEqual(handle_error_codes(0), 0)
        self.assertEqual(handle_error_codes(LIBSSH2_ERROR_EAGAIN), LIBSSH2_ERROR_EAGAIN)

    def test_general_errors(self):
        self.assertRaises(AuthenticationError, handle_error_codes, LIBSSH2_ERROR_PUBLICKEY_UNRECOGNIZED)
        self.assertRaises(SSH2Error, handle_error_codes, LIBSSH2_ERROR_SOCKET_NONE)
        self.assertRaises(BannerRecvError, handle_error_codes, LIBSSH2_ERROR_BANNER_RECV)
        self.assertRaises(BannerSendError, handle_error_codes, LIBSSH2_ERROR_BANNER_SEND)
        self.assertRaises(KeyExchangeError, handle_error_codes, LIBSSH2_ERROR_KEY_EXCHANGE_FAILURE)
        self.assertRaises(Timeout, handle_error_codes, LIBSSH2_ERROR_TIMEOUT)
        self.assertRaises(HostkeyInitError, handle_error_codes, LIBSSH2_ERROR_HOSTKEY_INIT)
        self.assertRaises(HostkeySignError, handle_error_codes, LIBSSH2_ERROR_HOSTKEY_SIGN)
        self.assertRaises(DecryptError, handle_error_codes, LIBSSH2_ERROR_DECRYPT)
        self.assertRaises(SocketDisconnectError, handle_error_codes, LIBSSH2_ERROR_SOCKET_DISCONNECT)
        self.assertRaises(ProtocolError, handle_error_codes, LIBSSH2_ERROR_PROTO)
        self.assertRaises(PasswordExpiredError, handle_error_codes, LIBSSH2_ERROR_PASSWORD_EXPIRED)
        self.assertRaises(FileError, handle_error_codes, LIBSSH2_ERROR_FILE)
        self.assertRaises(MethodNoneError, handle_error_codes, LIBSSH2_ERROR_METHOD_NONE)
        self.assertRaises(AuthenticationError, handle_error_codes, LIBSSH2_ERROR_AUTHENTICATION_FAILED)
        self.assertRaises(PublickeyUnverifiedError, handle_error_codes, LIBSSH2_ERROR_PUBLICKEY_UNVERIFIED)

    def test_channel_errors(self):
        self.assertRaises(ChannelOutOfOrderError, handle_error_codes, LIBSSH2_ERROR_CHANNEL_OUTOFORDER)
        self.assertRaises(ChannelFailure, handle_error_codes, LIBSSH2_ERROR_CHANNEL_FAILURE)
        self.assertRaises(ChannelRequestDenied, handle_error_codes, LIBSSH2_ERROR_CHANNEL_REQUEST_DENIED)
        self.assertRaises(ChannelUnknownError, handle_error_codes, LIBSSH2_ERROR_CHANNEL_UNKNOWN)
        self.assertRaises(ChannelWindowExceeded, handle_error_codes, LIBSSH2_ERROR_CHANNEL_WINDOW_EXCEEDED)
        self.assertRaises(ChannelPacketExceeded, handle_error_codes, LIBSSH2_ERROR_CHANNEL_PACKET_EXCEEDED)
        self.assertRaises(ChannelClosedError, handle_error_codes, LIBSSH2_ERROR_CHANNEL_CLOSED)
        self.assertRaises(ChannelEOFSentError, handle_error_codes, LIBSSH2_ERROR_CHANNEL_EOF_SENT)
        self.assertRaises(SCPProtocolError, handle_error_codes, LIBSSH2_ERROR_SCP_PROTOCOL)
        self.assertRaises(ZlibError, handle_error_codes, LIBSSH2_ERROR_ZLIB)
        self.assertRaises(SocketTimeout, handle_error_codes, LIBSSH2_ERROR_SOCKET_TIMEOUT)

    def test_request_errors(self):
        self.assertRaises(RequestDeniedError, handle_error_codes, LIBSSH2_ERROR_REQUEST_DENIED)
        self.assertRaises(MethodNotSupported, handle_error_codes, LIBSSH2_ERROR_METHOD_NOT_SUPPORTED)
        self.assertRaises(InvalidRequestError, handle_error_codes, LIBSSH2_ERROR_INVAL)
        self.assertRaises(InvalidPollTypeError, handle_error_codes, LIBSSH2_ERROR_INVALID_POLL_TYPE)
        self.assertRaises(PublicKeyProtocolError, handle_error_codes, LIBSSH2_ERROR_PUBLICKEY_PROTOCOL)
        self.assertRaises(BufferTooSmallError, handle_error_codes, LIBSSH2_ERROR_BUFFER_TOO_SMALL)
        self.assertRaises(BadUseError, handle_error_codes, LIBSSH2_ERROR_BAD_USE)

    def test_protocol_errors(self):
        self.assertRaises(SFTPProtocolError, handle_error_codes, LIBSSH2_ERROR_SFTP_PROTOCOL)
        self.assertRaises(CompressError, handle_error_codes, LIBSSH2_ERROR_COMPRESS)
        self.assertRaises(OutOfBoundaryError, handle_error_codes, LIBSSH2_ERROR_OUT_OF_BOUNDARY)
        self.assertRaises(AgentProtocolError, handle_error_codes, LIBSSH2_ERROR_AGENT_PROTOCOL)
        self.assertRaises(SocketRecvError, handle_error_codes, LIBSSH2_ERROR_SOCKET_RECV)
        self.assertRaises(SocketSendError, handle_error_codes, LIBSSH2_ERROR_SOCKET_SEND)
        self.assertRaises(EncryptError, handle_error_codes, LIBSSH2_ERROR_ENCRYPT)
        self.assertRaises(BadSocketError, handle_error_codes, LIBSSH2_ERROR_BAD_SOCKET)
        self.assertRaises(KnownHostError, handle_error_codes, LIBSSH2_ERROR_KNOWN_HOSTS)
        self.assertRaises(UnknownError, handle_error_codes, -9999)
