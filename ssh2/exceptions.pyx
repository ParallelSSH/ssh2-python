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


class AgentError(Exception):
    """Base class for all SSH Agent errors"""


class AuthenticationError(Exception):
    """Base class for all authentication errors"""


class AgentConnectionError(AgentError):
    """Raised on SSH Agent connection errors"""


class AgentAuthenticationError(AuthenticationError):
    """Raised on SSH Agent authentication errors"""


class AgentListIdentitiesError(AgentError):
    """Raised on SSH Agent list identities errors"""


class AgentGetIdentityError(AgentError):
    """Raised on SSH Agent get identity errors"""


class AgentProtocolError(Exception):
    """Raised on SSH agent protocol errors"""


class SessionError(Exception):
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


class SocketDisconnectError(Exception):
    """Raised on socket disconnection errors"""


class ProtocolError(Exception):
    """Raised on protocol errors"""


class PasswordExpiredError(AuthenticationError):
    """Raised on password expired errors"""


class FileError(Exception):
    """Raised on file errors"""


class MethodNoneError(Exception):
    """Raised on invalid method errors"""


class PublicKeyError(Exception):
    """Base class for all public key protocol errors"""


class PublicKeyInitError(PublicKeyError):
    """Raised on errors initialising public key system"""


class PublickeyUnrecognizedError(SessionError):
    """Raised on unrecognised public key errors"""


class PublickeyUnverifiedError(SessionError):
    """Raised on public key verification errors"""


class ChannelError(Exception):
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


class SCPError(Exception):
    """Raised on SCP errors. Base class for all SCP exceptions."""


class SCPProtocolError(SCPError):
    """Raised on SCP protocol errors"""


class ZlibError(SessionError):
    """Raised on zlib errors"""


class SocketTimeout(SessionError):
    """Raised on socket timeouts"""


class RequestDeniedError(SessionError):
    """Raised on request denied errors"""


class MethodNotSupported(SessionError):
    """Raised on authentication method not supported errors"""


class InvalidError(Exception):
    """Raised on invalid request errors"""


class InvalidPollTypeError(Exception):
    """Raised on invalid poll type errors"""


class PublicKeyProtocolError(Exception):
    """Raised on public key protocol errors"""


class BufferTooSmallError(Exception):
    """Raised on buffer too small errors"""


class BadUseError(Exception):
    """Raised on API bad use errors"""


class CompressError(SessionError):
    """Raised on compression errors"""


class OutOfBoundaryError(Exception):
    """Raised on out of boundary errors"""


class SocketRecvError(Exception):
    """Raised on socket receive errors"""


class EncryptError(SessionError):
    """Raised on encryption errors"""


class BadSocketError(Exception):
    """Raised on use of bad socket errors"""


class SFTPError(Exception):
    """Base class for SFTP errors"""


class SFTPProtocolError(SFTPError):
    """Raised on SFTP protocol errors"""


class SFTPHandleError(SFTPError):
    """Raised on SFTP handle errors"""


class SFTPBufferTooSmall(SFTPError):
    """Raised on SFTP buffer too small errors"""


class SFTPIOError(SFTPError):
    """Raised on SFTP I/O errors"""


class KnownHostError(Exception):
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
