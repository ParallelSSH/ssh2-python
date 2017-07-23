# This file is part of ssh2.
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

from cpython cimport PyObject_AsFileDescriptor

cimport ssh2
cimport error_codes

LIBSSH2_ERROR_NONE = error_codes._LIBSSH2_ERROR_NONE
LIBSSH2_ERROR_NONE = error_codes._LIBSSH2_ERROR_NONE
LIBSSH2CHANNEL_EAGAIN = error_codes._LIBSSH2CHANNEL_EAGAIN
LIBSSH2_ERROR_EAGAIN = error_codes._LIBSSH2_ERROR_EAGAIN
LIBSSH2_ERROR_AUTHENTICATION_FAILED = error_codes._LIBSSH2_ERROR_AUTHENTICATION_FAILED
LIBSSH2_ERROR_SOCKET_RECV = error_codes._LIBSSH2_ERROR_SOCKET_RECV


cdef class AgentError(Exception):
    pass


cdef class AuthenticationFailure(Exception):
    pass


cdef class AgentConnectError(AgentError):
    pass


cdef class AgentAuthenticationFailure(AuthenticationFailure):
    pass


cdef class AgentListIdentitiesError(AgentError):
    pass


cdef class AgentGetIdentityError(AgentError):
    pass


cdef class SessionStartupError(Exception):
    pass


cdef class Channel:
    cdef ssh2.LIBSSH2_CHANNEL *_channel

    def __cinit__(self):
        self._channel = NULL

    def __dealloc__(self):
        pass


cdef class Session:
    cdef ssh2.LIBSSH2_SESSION *_session

    """LibSSH2 Session class providing session functions"""

    # TODO: Handle errors, check for EAGAIN, raise exceptions

    def __cinit__(self):
        self._session = ssh2.libssh2_session_init()
        if self._session is NULL:
            raise MemoryError

    def __dealloc__(self):
        if self._session is not NULL:
            if ssh2.libssh2_session_free(self._session) == 0:
                self._session = NULL

    def startup(self, sock):
        cdef int _sock = PyObject_AsFileDescriptor(sock)
        cdef int rc
        with nogil:
            rc = ssh2.libssh2_session_startup(self._session, _sock)
            if rc != 0 and rc != _LIBSSH2_ERROR_EAGAIN:
                with gil:
                    raise SessionStartupError(
                        "SSH session startup failed with error code %s",
                        rc)
        return rc

    def userauth_password(self, const char *username, const char *password):
        cdef int rc
        with nogil:
            rc = ssh2.libssh2_userauth_password(self._session, username, password)
        return rc

    cdef ssh2.LIBSSH2_AGENT * connect_agent(self):
        with nogil:
            agent = ssh2.libssh2_agent_init(self._session)
            if agent is NULL:
                with gil:
                    raise MemoryError
            if ssh2.libssh2_agent_connect(agent) != 0:
                ssh2.libssh2_agent_free(agent)
                with gil:
                    raise AgentConnectError("Unable to connect to agent")
        return agent

    def userauth_agent(self, const char *username):
        cdef int rc
        cdef ssh2.LIBSSH2_AGENT *agent = NULL
        cdef ssh2.libssh2_agent_publickey *identity = NULL
        cdef ssh2.libssh2_agent_publickey *prev = NULL
        cdef int auth_rc
        # TODO - Handle errors
        agent = self.connect_agent()
        with nogil:
            if libssh2_agent_list_identities(agent) != 0:
                with gil:
                    raise AgentListIdentitiesError(
                        "Failure requesting identities from agent")
            while 1:
                rc = ssh2.libssh2_agent_get_identity(
                    agent, &identity, prev)
                if rc == 1:
                    with gil:
                        raise AgentAuthenticationFailure(
                            "No identities match")
                elif rc < 0:
                    with gil:
                        raise AgentGetIdentityError(
                            "Failure getting identity from agent")
                auth_rc = ssh2.libssh2_agent_userauth(
                    agent, username, identity)
                if auth_rc == 0:
                    break
                prev = identity
        ssh2.libssh2_agent_free(agent)
        # return auth_rc
