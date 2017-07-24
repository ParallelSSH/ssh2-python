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
from cpython.string cimport PyString_FromStringAndSize

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


cdef class ChannelException(Exception):
    pass


cdef object PyChannel(LIBSSH2_CHANNEL *channel):
    cdef Channel _channel = Channel()
    _channel._channel = channel
    return _channel


cdef class Channel:
    cdef ssh2.LIBSSH2_CHANNEL *_channel

    def __cinit__(self):
        self._channel = NULL

    def __dealloc__(self):
        if self._channel is not NULL:
            pass
            # ssh2.libssh2_channel_close(self._channel)
            # ssh2.libssh2_channel_free(self._channel)

    def pty(self, term="vt100"):
        cdef const char *_term = term
        cdef int rc
        with nogil:
            rc = ssh2.libssh2_channel_request_pty(
                self._channel, _term)
            if rc != 0 and rc != _LIBSSH2_ERROR_EAGAIN:
                with gil:
                    raise ChannelException(
                        "Error requesting PTY with error code %s",
                        rc)
        return rc

    def execute(self, const char *command):
        cdef int rc
        with nogil:
            rc = ssh2.libssh2_channel_exec(
                self._channel, command)
            if rc != 0 and rc != _LIBSSH2_ERROR_EAGAIN:
                with gil:
                    raise ChannelException(
                        "Error executing command %s - error code %s",
                        command, rc)
        return rc

    def subsystem(self, const char *subsystem):
        cdef int rc
        with nogil:
            rc = ssh2.libssh2_channel_subsystem(
                self._channel, subsystem)
            if rc != 0 and rc != _LIBSSH2_ERROR_EAGAIN:
                with gil:
                    raise ChannelException(
                        "Error requesting subsystem %s - error code %s",
                        subsystem, rc)
        return rc

    def read_ex(self, int size=1024, int stream_id=0):
        cdef int rc
        cdef object buffer = PyString_FromStringAndSize(NULL, size)
        cdef char *cbuf = buffer
        with nogil:
            rc = ssh2.libssh2_channel_read_ex(
                self._channel, stream_id, cbuf, size)
        return rc, buffer

    def send_eof(self):
        cdef int rc
        with nogil:
            rc = ssh2.libssh2_channel_send_eof(self._channel)
        return rc

    def wait_eof(self):
        cdef int rc
        with nogil:
            rc = ssh2.libssh2_channel_wait_eof(self._channel)
        return rc

    def close(self):
        cdef int rc
        with nogil:
            rc = ssh2.libssh2_channel_close(self._channel)
        return rc

    def wait_closed(self):
        cdef int rc
        with nogil:
            rc = ssh2.libssh2_channel_wait_closed(self._channel)
        return rc

    def get_exit_status(self):
        cdef int rc
        with nogil:
            rc = ssh2.libssh2_channel_get_exit_status(self._channel)
        return rc

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
            ssh2.libssh2_session_disconnect(
                self._session, "end")
            ssh2.libssh2_session_free(self._session)

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

    def setblocking(self, bint blocking):
        with nogil:
            ssh2.libssh2_session_set_blocking(
                self._session, blocking)

    def userauth_publickey_fromfile(self, const char *username,
                                    const char *publickey,
                                    const char *privatekey,
                                    const char *passphrase):
        cdef int rc
        with nogil:
            rc = ssh2.libssh2_userauth_publickey_fromfile(
                self._session, username, publickey, privatekey, passphrase)
        return rc

    def userauth_publickey(self, const char *username,
                           const unsigned char *pubkeydata,
                           size_t pubkeydata_len):
        cdef int rc
        with nogil:
            rc = ssh2.libssh2_userauth_publickey(
                self._session, username, pubkeydata,
                pubkeydata_len, NULL, NULL)
        return rc

    def userauth_hostbased_fromfile(self,
                                    const char *username,
                                    const char *publickey,
                                    const char *privatekey,
                                    const char *passphrase,
                                    const char *hostname):
        cdef int rc
        with nogil:
            rc = ssh2.libssh2_userauth_hostbased_fromfile(
                self._session, username, publickey,
                privatekey, passphrase, hostname)
        return rc

    # def userauth_publickey_frommemory(self,
    #                                   const char *username,
    #                                   const char *publickeyfiledata,
    #                                   const char *privatekeyfiledata,
    #                                   const char *passphrase):
    #     cdef int rc
    #     cdef size_t username_len, pubkeydata_len, privatekeydata_len
    #     username_len, pubkeydata_len, privatekeydata_len = \
    #         len(username), len(publickeyfiledata), len(privatekeyfiledata)
    #     with nogil:
    #         rc = ssh2.libssh2_userauth_publickey_frommemory(
    #             self._session, username, username_len, publickeyfiledata,
    #             pubkeydata_len, privatekeyfiledata,
    #             privatekeydata_len, passphrase)
    #     return rc

    def userauth_password(self, const char *username, const char *password):
        cdef int rc
        with nogil:
            rc = ssh2.libssh2_userauth_password(
                self._session, username, password)
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

    cdef void _clear_agent(self, ssh2.LIBSSH2_AGENT *agent) nogil:
        ssh2.libssh2_agent_disconnect(agent)
        ssh2.libssh2_agent_free(agent)

    def userauth_agent(self, const char *username):
        cdef int rc
        cdef ssh2.LIBSSH2_AGENT *agent = NULL
        cdef ssh2.libssh2_agent_publickey *identity = NULL
        cdef ssh2.libssh2_agent_publickey *prev = NULL
        cdef int auth_rc
        agent = self.connect_agent()
        with nogil:
            if libssh2_agent_list_identities(agent) != 0:
                self._clear_agent(agent)
                with gil:
                    raise AgentListIdentitiesError(
                        "Failure requesting identities from agent")
            while 1:
                rc = ssh2.libssh2_agent_get_identity(
                    agent, &identity, prev)
                if rc == 1:
                    self._clear_agent(agent)
                    with gil:
                        raise AgentAuthenticationFailure(
                            "No identities match for user %s",
                            username)
                elif rc < 0:
                    self._clear_agent(agent)
                    with gil:
                        raise AgentGetIdentityError(
                            "Failure getting identity for user %s from agent",
                            username)
                if ssh2.libssh2_agent_userauth(
                        agent, username, identity) == 0:
                    # with gil:
                    #     print("Authenticated %s", username)
                    break
                prev = identity
        self._clear_agent(agent)

    def open_session(self):
        cdef LIBSSH2_CHANNEL *channel
        with nogil:
            channel = ssh2.libssh2_channel_open_session(
                self._session)
            if channel is NULL:
                with gil:
                    raise MemoryError
        return PyChannel(channel)

    def direct_tcpip(self, const char *host, int port):
        cdef LIBSSH2_CHANNEL *channel
        with nogil:
            channel = libssh2_channel_direct_tcpip(
                self._session, host, port)
            if channel is NULL:
                with gil:
                    raise MemoryError
        return PyChannel(channel)

    def forward_listen(self, int port):
        # ssh2.libssh2_channel_forward_listen(self._session, port)
        raise NotImplementedError
