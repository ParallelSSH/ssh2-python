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


class SSH2Error(Exception):
    """Base class for all ssh2-python errors"""


class AgentError(SSH2Error):
    """Base class for all SSH Agent errors"""


class AuthenticationError(SSH2Error):
    """Base class for all authentication errors"""


class AgentConnectionError(AgentError):
    """Raised on SSH Agent connection errors"""


class AgentAuthenticationError(AuthenticationError):
    """Raised on SSH Agent authentication errors"""


class AgentListIdentitiesError(AgentError):
    """Raised on SSH Agent list identities errors"""


class AgentGetIdentityError(AgentError):
    """Raised on SSH Agent get identity errors"""


class AgentProtocolError(SSH2Error):
    """Raised on SSH agent protocol errors"""


class SessionError(SSH2Error):
    """Base class for all session errors"""


class SessionStartupError(SessionError):
    """Raised on session startup errors"""


class SessionHandshakeError(SessionError):
    """Raised on session handshake errors"""


class SessionHostKeyError(SessionError):
    """Raised on errors getting server host key"""


class BannerRecvError(SessionError):
    """Raised on errors receiving banner"""


class BannerSendError(SessionError):
    """Raised on errors sending banner"""


class KeyExchangeError(SessionError):
    """Raised on errors exchanging keys"""


class Timeout(SessionError):
    """Raised on timeouts"""


class HostkeyInitError(SessionError):
    """Raised on errors initialiasing host key"""


class HostkeySignError(SessionError):
    """Raised on errors signing host key"""


class DecryptError(SessionError):
    """Raised on decryption errors"""


class SocketDisconnectError(SSH2Error):
    """Raised on socket disconnection errors"""


class ProtocolError(SSH2Error):
    """Raised on protocol errors"""


class PasswordExpiredError(AuthenticationError):
    """Raised on password expired errors"""


class FileError(SSH2Error):
    """Raised on file errors"""


class MethodNoneError(SSH2Error):
    """Raised on invalid method errors"""


class PublicKeyError(SSH2Error):
    """Base class for all public key protocol errors"""


class PublicKeyInitError(PublicKeyError):
    """Raised on errors initialising public key system"""


class PublickeyUnverifiedError(AuthenticationError):
    """Raised on public key verification errors"""


class ChannelError(SSH2Error):
    """Base class for all channel errors"""


class ChannelOutOfOrderError(ChannelError):
    """Raised on channel commands out of order errors"""


class ChannelFailure(ChannelError):
    """Raised on channel failures"""


class ChannelRequestDenied(ChannelError):
    """Raised on channel request denied errors"""


class ChannelUnknownError(ChannelError):
    """Raised on unknown channel errors"""


class ChannelWindowExceeded(ChannelError):
    """Raised on channel window exceeded errors"""


class ChannelPacketExceeded(ChannelError):
    """Raised on channel max packet length exceeded errors"""


class ChannelClosedError(ChannelError):
    """Raised on channel closed errors"""


class ChannelEOFSentError(ChannelError):
    """Raised on channel EOF errors"""


class SCPProtocolError(SessionError):
    """Raised on SCP protocol errors"""


class ZlibError(SessionError):
    """Raised on zlib errors"""


class SocketTimeout(SessionError):
    """Raised on socket timeouts"""


class RequestDeniedError(SessionError):
    """Raised on request denied errors"""


class MethodNotSupported(SessionError):
    """Raised on authentication method not supported errors"""


class InvalidRequestError(SSH2Error):
    """Raised on invalid request errors"""


class InvalidPollTypeError(SSH2Error):
    """Raised on invalid poll type errors"""


class PublicKeyProtocolError(SSH2Error):
    """Raised on public key protocol errors"""


class BufferTooSmallError(SSH2Error):
    """Raised on buffer too small errors"""


class BadUseError(SSH2Error):
    """Raised on API bad use errors"""


class CompressError(SessionError):
    """Raised on compression errors"""


class OutOfBoundaryError(SSH2Error):
    """Raised on out of boundary errors"""


class SocketRecvError(SSH2Error):
    """Raised on socket receive errors"""


class SocketSendError(SSH2Error):
    """Raised on socket send errors"""


class EncryptError(SessionError):
    """Raised on encryption errors"""


class BadSocketError(SSH2Error):
    """Raised on use of bad socket errors"""


class SFTPError(SSH2Error):
    """Base class for SFTP errors"""


class SFTPProtocolError(SFTPError):
    """Raised on SFTP protocol errors"""


class SFTPHandleError(SFTPError):
    """Raised on SFTP handle errors"""


class KnownHostError(SSH2Error):
    """Base class for KnownHost errors"""


class KnownHostAddError(KnownHostError):
    """Raised on errors adding known host entries"""


class KnownHostCheckError(KnownHostError):
    """Raised on any known host check errors"""


class KnownHostCheckFailure(KnownHostCheckError):
    """Raised on something preventing known host check to be made"""


class KnownHostCheckNotFoundError(KnownHostCheckError):
    """Raised on no match for known host check"""


class KnownHostCheckMisMatchError(KnownHostCheckError):
    """Raised on keys do not match for known host"""


class KnownHostDeleteError(KnownHostError):
    """Raised on errors deleting known host entry"""


class KnownHostReadLineError(KnownHostError):
    """Raised on errors reading line from known hosts file"""


class KnownHostReadFileError(KnownHostError):
    """Raised on errors reading from known hosts file"""


class KnownHostWriteLineError(KnownHostError):
    """Raised on errors writing line to known hosts file"""


class KnownHostWriteFileError(KnownHostError):
    """Raised on errors writing to known hosts file"""


class KnownHostGetError(KnownHostError):
    """Raised on errors retrieving known host entries"""


class UnknownError(SSH2Error):
    """Raised on non-specific or unknown errors"""
