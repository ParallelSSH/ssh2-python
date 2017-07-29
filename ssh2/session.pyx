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

from cpython cimport PyObject_AsFileDescriptor
from libc.stdlib cimport malloc, free

cimport c_ssh2
cimport c_sftp
# cimport error_codes
from agent cimport PyAgent, auth_identity, clear_agent
from channel cimport PyChannel
from exceptions cimport SessionHandshakeError, SessionStartupError, \
    AgentConnectError, AgentListIdentitiesError, AgentGetIdentityError
from listener cimport PyListener
from sftp cimport PySFTP


cdef class Session:

    """LibSSH2 Session class providing session functions"""

    def __cinit__(self):
        with nogil:
            self._session = c_ssh2.libssh2_session_init()
            if self._session is NULL:
                with gil:
                    raise MemoryError

    def __dealloc__(self):
        with nogil:
            c_ssh2.libssh2_session_disconnect(
                self._session, "end")
            c_ssh2.libssh2_session_free(self._session)

    def disconnect(self):
        with nogil:
            c_ssh2.libssh2_session_disconnect(self._session, "end")

    def handshake(self, sock not None):
        cdef int _sock = PyObject_AsFileDescriptor(sock)
        cdef int rc
        with nogil:
            rc = c_ssh2.libssh2_session_handshake(self._session, _sock)
            if rc != 0 and rc != c_ssh2._LIBSSH2_ERROR_EAGAIN:
                with gil:
                    raise SessionHandshakeError(
                        "SSH session handshake failed with error code %s",
                        rc)
        return rc

    def startup(self, sock):
        """Deprecated - use self.handshake"""
        cdef int _sock = PyObject_AsFileDescriptor(sock)
        cdef int rc
        with nogil:
            rc = c_ssh2.libssh2_session_startup(self._session, _sock)
            if rc != 0 and rc != c_ssh2._LIBSSH2_ERROR_EAGAIN:
                with gil:
                    raise SessionStartupError(
                        "SSH session startup failed with error code %s",
                        rc)
        return rc

    def setblocking(self, bint blocking):
        with nogil:
            c_ssh2.libssh2_session_set_blocking(
                self._session, blocking)

    def userauth_authenticated(self):
        cdef bint rc
        with nogil:
            rc = c_ssh2.libssh2_userauth_authenticated(self._session)
        return bool(rc)

    def userauth_list(self, bytes username):
        cdef char *_username = username
        cdef size_t username_len = len(username)
        cdef char *_auth
        cdef bytes auth
        with nogil:
            _auth = c_ssh2.libssh2_userauth_list(
                self._session, _username, username_len)
        if _auth is NULL:
            return
        auth = _auth
        return auth.split(',')

    def userauth_publickey_fromfile(self, const char *username,
                                    const char *publickey,
                                    const char *privatekey,
                                    const char *passphrase):
        cdef int rc
        with nogil:
            rc = c_ssh2.libssh2_userauth_publickey_fromfile(
                self._session, username, publickey, privatekey, passphrase)
        return rc

    def userauth_publickey(self, const char *username,
                           const unsigned char *pubkeydata,
                           size_t pubkeydata_len):
        cdef int rc
        with nogil:
            rc = c_ssh2.libssh2_userauth_publickey(
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
            rc = c_ssh2.libssh2_userauth_hostbased_fromfile(
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
    #         rc = c_ssh2.libssh2_userauth_publickey_frommemory(
    #             self._session, username, username_len, publickeyfiledata,
    #             pubkeydata_len, privatekeyfiledata,
    #             privatekeydata_len, passphrase)
    #     return rc

    def userauth_password(self, const char *username, const char *password):
        cdef int rc
        with nogil:
            rc = c_ssh2.libssh2_userauth_password(
                self._session, username, password)
        return rc

    def agent_init(self):
        cdef c_ssh2.LIBSSH2_AGENT *agent = self._agent_init()
        if agent is NULL:
            return
        return PyAgent(agent)

    cdef c_ssh2.LIBSSH2_AGENT * _agent_init(self):
        cdef c_ssh2.LIBSSH2_AGENT *agent
        with nogil:
            agent = c_ssh2.libssh2_agent_init(self._session)
            if agent is NULL:
                with gil:
                    raise MemoryError
            return agent

    cdef c_ssh2.LIBSSH2_AGENT * init_connect_agent(self) nogil:
        agent = c_ssh2.libssh2_agent_init(self._session)
        if agent is NULL:
            with gil:
                raise MemoryError
        if c_ssh2.libssh2_agent_connect(agent) != 0:
            c_ssh2.libssh2_agent_free(agent)
            with gil:
                raise AgentConnectError("Unable to connect to agent")
        return agent

    def agent_auth(self, const char *username):
        """Convenience function for performing user authentication via SSH Agent.

        Initialises, connects to, gets list of identities from and attempts
        authentication with each identity from SSH agent.

        Note that agent connections cannot be used in non-blocking mode -
        clients should call `setblocking(0)` _after_ calling this function.

        On completion, or any errors, agent is disconnected and resources freed.

        All steps are performed in C space which makes this function perform
        better than calling the individual Agent class functions from
        Python.

        :raises: MemoryError on error initialising agent
        :raises: AgentConnectError on error connecting to agent
        :raises: AgentListIdentitiesError on error getting identities from agent
        :raises: AgentAuthenticationFailure on no successful authentication with
        all available identities
        :raises: AgentGetIdentityError on error getting known identity from agent

        :rtype: None
        """
        cdef c_ssh2.LIBSSH2_AGENT *agent = NULL
        cdef c_ssh2.libssh2_agent_publickey *identity = NULL
        cdef c_ssh2.libssh2_agent_publickey *prev = NULL
        with nogil:
            agent = self.init_connect_agent()
            if c_ssh2.libssh2_agent_list_identities(agent) != 0:
                clear_agent(agent)
                with gil:
                    raise AgentListIdentitiesError(
                        "Failure requesting identities from agent")
            while 1:
                auth_identity(username, agent, &identity, prev)
                if c_ssh2.libssh2_agent_userauth(
                        agent, username, identity) == 0:
                    break
                prev = identity
            clear_agent(agent)

    def open_session(self):
        cdef c_ssh2.LIBSSH2_CHANNEL *channel
        with nogil:
            channel = c_ssh2.libssh2_channel_open_session(
                self._session)
            if channel is NULL:
                with gil:
                    return None
        return PyChannel(channel, self)

    def direct_tcpip_ex(self, const char *host, int port,
                        const char *shost, int sport):
        cdef c_ssh2.LIBSSH2_CHANNEL *channel
        with nogil:
            channel = c_ssh2.libssh2_channel_direct_tcpip_ex(
                self._session, host, port, shost, sport)
            if channel is NULL:
                with gil:
                    return
        return PyChannel(channel, self)

    def direct_tcpip(self, const char *host, int port):
        cdef c_ssh2.LIBSSH2_CHANNEL *channel
        with nogil:
            channel = c_ssh2.libssh2_channel_direct_tcpip(
                self._session, host, port)
            if channel is NULL:
                with gil:
                    return
        return PyChannel(channel, self)

    def blockdirections(self):
        cdef int rc
        with nogil:
            rc = c_ssh2.libssh2_session_block_directions(
                self._session)
        return rc

    def forward_listen(self, int port):
        cdef c_ssh2.LIBSSH2_LISTENER *listener
        with nogil:
            listener = c_ssh2.libssh2_channel_forward_listen(
                self._session, port)
        if listener is NULL:
            return
        return PyListener(listener, self)

    def forward_listen_ex(self, const char *host, int port,
                          int bound_port, int queue_maxsize):
        cdef c_ssh2.LIBSSH2_LISTENER *listener
        with nogil:
            listener = c_ssh2.libssh2_channel_forward_listen_ex(
                self._session, host, port, &bound_port, queue_maxsize)
        if listener is NULL:
            return
        return PyListener(listener, self)

    def sftp_init(self):
        cdef c_sftp.LIBSSH2_SFTP *_sftp
        with nogil:
            _sftp = c_sftp.libssh2_sftp_init(self._session)
        if _sftp is NULL:
            return
        return PySFTP(_sftp, self)

    def last_error(self):
        cdef char **_error_msg = NULL
        cdef bytes msg
        cdef int errmsg_len = 0
        cdef int rc
        with nogil:
            rc = c_ssh2.libssh2_session_last_error(
                self._session, _error_msg, &errmsg_len, 0)
        if errmsg_len > 0 and _error_msg is not NULL:
            for line in _error_msg[errmsg_len]:
                msg += line
        else:
            msg = b''
        return msg

    # cdef c_ssh2.LIBSSH2_CHANNEL * scp_recv2(
    #     self, const char *path, libssh2_struct_stat *stat):
    #     cdef c_ssh2.LIBSSH2_CHANNEL *_channel
    #     with nogil:
    #         _channel = c_ssh2.libssh2_scp_recv2(
    #             self._session, path, stat)
    #     return _channel
