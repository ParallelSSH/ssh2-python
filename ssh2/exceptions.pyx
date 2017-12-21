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


class ChannelError(Exception):
    pass


class SFTPHandleError(Exception):
    pass


class SFTPBufferTooSmall(Exception):
    pass


class SFTPIOError(Exception):
    pass
