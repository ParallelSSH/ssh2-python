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


class AgentError(Exception):
    pass


class AuthenticationError(Exception):
    pass


class AgentConnectionError(AgentError):
    pass


class AgentAuthenticationError(AuthenticationError):
    pass


class AgentListIdentitiesError(AgentError):
    pass


class AgentGetIdentityError(AgentError):
    pass


class SessionStartupError(Exception):
    pass


class SessionHandshakeError(Exception):
    pass


class SessionHostKeyError(Exception):
    """Raised on errors getting server host key"""


class ChannelError(Exception):
    pass


class SFTPHandleError(Exception):
    pass


class SFTPBufferTooSmall(Exception):
    pass


class SFTPIOError(Exception):
    pass


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
