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
from libc.time cimport time_t

from agent cimport PyAgent, auth_identity, clear_agent
from channel cimport PyChannel
from exceptions cimport SessionHandshakeError, SessionStartupError, \
    AgentConnectionError, AgentListIdentitiesError, AgentGetIdentityError, \
    AuthenticationError
from listener cimport PyListener
from sftp cimport PySFTP
from publickey cimport PyPublicKeySystem
from utils cimport to_bytes, to_str
from statinfo cimport StatInfo
IF EMBEDDED_LIB:
    from fileinfo cimport FileInfo

cimport c_ssh2
cimport c_sftp
cimport c_pkey


LIBSSH2_SESSION_BLOCK_INBOUND = c_ssh2.LIBSSH2_SESSION_BLOCK_INBOUND
LIBSSH2_SESSION_BLOCK_OUTBOUND = c_ssh2.LIBSSH2_SESSION_BLOCK_OUTBOUND


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
            if rc != 0 and rc != c_ssh2.LIBSSH2_ERROR_EAGAIN:
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
            if rc != 0 and rc != c_ssh2.LIBSSH2_ERROR_EAGAIN:
                with gil:
                    raise SessionStartupError(
                        "SSH session startup failed with error code %s",
                        rc)
        return rc

    def set_blocking(self, bint blocking):
        """Set session blocking mode on/off.

        :param blocking: ``False`` for non-blocking, ``True`` for blocking.
          Session default is blocking unless set otherwise.
        :type blocking: bool"""
        with nogil:
            c_ssh2.libssh2_session_set_blocking(
                self._session, blocking)

    def get_blocking(self):
        """Get session blocking mode enabled True/False.

        :rtype: bool"""
        cdef int rc
        with nogil:
            rc = c_ssh2.libssh2_session_get_blocking(self._session)
        return bool(rc)

    def set_timeout(self, long timeout):
        """Set the timeout in milliseconds for how long a blocking the libssh2
        function calls may wait until they consider the situation an error and
        return :py:class:`ssh2.error_codes.LIBSSH2_ERROR_TIMEOUT`.

        By default or if you set the timeout to zero, libssh2 has no timeout
        for blocking functions.
        :param timeout: Milliseconds to wait before timeout."""
        with nogil:
            c_ssh2.libssh2_session_set_timeout(self._session, timeout)

    def get_timeout(self):
        """Get current session timeout setting"""
        cdef long timeout
        with nogil:
            timeout = c_ssh2.libssh2_session_get_timeout(self._session)
        return timeout

    def userauth_authenticated(self):
        """True/False for is user authenticated or not.

        :rtype: bool"""
        cdef bint rc
        with nogil:
            rc = c_ssh2.libssh2_userauth_authenticated(self._session)
        return bool(rc)

    def userauth_list(self, username not None):
        """Retrieve available authentication method list.

        :rtype: list"""
        cdef char *_username = to_bytes(username)
        cdef size_t username_len = len(_username)
        cdef char *_auth
        cdef str auth
        with nogil:
            _auth = c_ssh2.libssh2_userauth_list(
                self._session, _username, username_len)
        if _auth is NULL:
            return
        auth = to_str(_auth)
        return auth.split(',')

    def userauth_publickey_fromfile(self, username not None,
                                    publickey not None,
                                    privatekey not None,
                                    passphrase not None):
        """Authenticate with public key from file.

        :rtype: int"""
        cdef int rc
        cdef char *_username = to_bytes(username)
        cdef char *_publickey = to_bytes(publickey)
        cdef char *_privatekey = to_bytes(privatekey)
        cdef char *_passphrase = to_bytes(passphrase)
        with nogil:
            rc = c_ssh2.libssh2_userauth_publickey_fromfile(
                self._session, _username, _publickey, _privatekey, _passphrase)
            if rc != 0 and rc != c_ssh2.LIBSSH2_ERROR_EAGAIN:
                with gil:
                    raise AuthenticationError(
                        "Error authenticating user %s with private key %s and"
                        "public key %s",
                        username, privatekey, publickey)
        return rc

    def userauth_publickey(self, username not None,
                           bytes pubkeydata not None):
        """Perform public key authentication with provided public key data

        :param username: User name to authenticate as
        :type username: str
        :param pubkeydata: Public key data
        :type pubkeydata: bytes

        :rtype: int"""
        cdef int rc
        cdef char *_username = to_bytes(username)
        cdef unsigned char *_pubkeydata = pubkeydata
        cdef size_t pubkeydata_len = len(pubkeydata)
        with nogil:
            rc = c_ssh2.libssh2_userauth_publickey(
                self._session, _username, _pubkeydata,
                pubkeydata_len, NULL, NULL)
            if rc != 0 and rc != c_ssh2.LIBSSH2_ERROR_EAGAIN:
                with gil:
                    raise AuthenticationError(
                        "Error authenticating user %s with public key data",
                        username)
        return rc

    def userauth_hostbased_fromfile(self,
                                    username not None,
                                    publickey not None,
                                    privatekey not None,
                                    passphrase not None,
                                    hostname not None):
        cdef int rc
        cdef char *_username = to_bytes(username)
        cdef char *_publickey = to_bytes(publickey)
        cdef char *_privatekey = to_bytes(privatekey)
        cdef char *_passphrase = to_bytes(passphrase)
        cdef char *_hostname = to_bytes(hostname)
        with nogil:
            rc = c_ssh2.libssh2_userauth_hostbased_fromfile(
                self._session, _username, _publickey,
                _privatekey, _passphrase, _hostname)
            if rc != 0 and rc != c_ssh2.LIBSSH2_ERROR_EAGAIN:
                with gil:
                    raise AuthenticationError(
                        "Error authenticating user %s with private key %s and"
                        "public key %s for host %s",
                        username, privatekey, publickey, hostname)
        return rc

    IF EMBEDDED_LIB:
        def userauth_publickey_frommemory(self,
                                          const char *username,
                                          const char *publickeyfiledata,
                                          const char *privatekeyfiledata,
                                          const char *passphrase):
            cdef int rc
            cdef size_t username_len, pubkeydata_len, privatekeydata_len
            username_len, pubkeydata_len, privatekeydata_len = \
                len(username), len(publickeyfiledata), len(privatekeyfiledata)
            with nogil:
                rc = c_ssh2.libssh2_userauth_publickey_frommemory(
                    self._session, username, username_len, publickeyfiledata,
                    pubkeydata_len, privatekeyfiledata,
                    privatekeydata_len, passphrase)
            return rc

    def userauth_password(self, username not None, password not None):
        """Perform password authentication

        :param username: User name to authenticate.
        :type username: str
        :param password: Password
        :type password: str"""
        cdef int rc
        cdef const char *_username = to_bytes(username)
        cdef const char *_password = to_bytes(password)
        with nogil:
            rc = c_ssh2.libssh2_userauth_password(
                self._session, _username, _password)
            if rc != 0 and rc != c_ssh2.LIBSSH2_ERROR_EAGAIN:
                with gil:
                    raise AuthenticationError(
                        "Error authenticating user %s with password",
                        username)
        return rc

    def agent_init(self):
        """Initialise SSH agent.

        :rtype: :py:class:`ssh2.agent.Agent`
        """
        cdef c_ssh2.LIBSSH2_AGENT *agent = self._agent_init()
        if agent is NULL:
            return
        return PyAgent(agent, self)

    cdef c_ssh2.LIBSSH2_AGENT * _agent_init(self):
        cdef c_ssh2.LIBSSH2_AGENT *agent
        with nogil:
            agent = c_ssh2.libssh2_agent_init(self._session)
            if agent is NULL:
                with gil:
                    raise MemoryError
            return agent

    cdef c_ssh2.LIBSSH2_AGENT * init_connect_agent(self) nogil except NULL:
        agent = c_ssh2.libssh2_agent_init(self._session)
        if agent is NULL:
            with gil:
                raise MemoryError
        if c_ssh2.libssh2_agent_connect(agent) != 0:
            c_ssh2.libssh2_agent_free(agent)
            with gil:
                raise AgentConnectionError("Unable to connect to agent")
        return agent

    def agent_auth(self, username not None):
        """Convenience function for performing user authentication via SSH Agent.

        Initialises, connects to, gets list of identities from and attempts
        authentication with each identity from SSH agent.

        Note that agent connections cannot be used in non-blocking mode -
        clients should call `set_blocking(0)` *after* calling this function.

        On completion, or any errors, agent is disconnected and resources freed.

        All steps are performed in C space which makes this function perform
        better than calling the individual Agent class functions from
        Python.

        :raises: :py:class:`MemoryError` on error initialising agent
        :raises: :py:class:`ssh2.exceptions.AgentConnectionError` on error
          connecting to agent
        :raises: :py:class:`ssh2.exceptions.AgentListIdentitiesError` on error
          getting identities from agent
        :raises: :py:class:`ssh2.exceptions.AgentAuthenticationFailure` on no
          successful authentication with all available identities.
        :raises: :py:class:`ssh2.exceptions.AgentGetIdentityError` on error
          getting known identity from agent

        :rtype: None"""
        cdef char *_username = to_bytes(username)
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
                auth_identity(_username, agent, &identity, prev)
                if c_ssh2.libssh2_agent_userauth(
                        agent, _username, identity) == 0:
                    break
                prev = identity
            clear_agent(agent)

    def open_session(self):
        """Open new channel session.

        :rtype: :py:class:`ssh2.channel.Channel`
        """
        cdef c_ssh2.LIBSSH2_CHANNEL *channel
        with nogil:
            channel = c_ssh2.libssh2_channel_open_session(
                self._session)
            if channel is NULL:
                with gil:
                    return None
        return PyChannel(channel, self)

    def direct_tcpip_ex(self, host not None, int port,
                        shost not None, int sport):
        cdef c_ssh2.LIBSSH2_CHANNEL *channel
        cdef char *_host = to_bytes(host)
        cdef char *_shost = to_bytes(shost)
        with nogil:
            channel = c_ssh2.libssh2_channel_direct_tcpip_ex(
                self._session, _host, port, _shost, sport)
            if channel is NULL:
                with gil:
                    return
        return PyChannel(channel, self)

    def direct_tcpip(self, host not None, int port):
        cdef c_ssh2.LIBSSH2_CHANNEL *channel
        cdef char *_host = to_bytes(host)
        with nogil:
            channel = c_ssh2.libssh2_channel_direct_tcpip(
                self._session, _host, port)
            if channel is NULL:
                with gil:
                    return
        return PyChannel(channel, self)

    def block_directions(self):
        """Get blocked directions for the current session.

        From libssh2 documentation:

        Can be a combination of:

        ``ssh2.session.LIBSSH2_SESSION_BLOCK_INBOUND``: Inbound direction
        blocked.

        ``ssh2.session.LIBSSH2_SESSION_BLOCK_OUTBOUND``: Outbound direction
        blocked.

        Application should wait for data to be available for socket prior to
        calling a libssh2 function again. If ``LIBSSH2_SESSION_BLOCK_INBOUND``
        is set select should contain the session socket in readfds set.

        Correspondingly in case of ``LIBSSH2_SESSION_BLOCK_OUTBOUND`` writefds
        set should contain the socket.

        :rtype: int"""
        cdef int rc
        with nogil:
            rc = c_ssh2.libssh2_session_block_directions(
                self._session)
        return rc

    def forward_listen(self, int port):
        """Create forward listener on port.

        :param port: Port to listen on.
        :type port: int

        :rtype: :py:class:`ssh2.listener.Listener` or None"""
        cdef c_ssh2.LIBSSH2_LISTENER *listener
        with nogil:
            listener = c_ssh2.libssh2_channel_forward_listen(
                self._session, port)
        if listener is NULL:
            return
        return PyListener(listener, self)

    def forward_listen_ex(self, host not None, int port,
                          int bound_port, int queue_maxsize):
        cdef c_ssh2.LIBSSH2_LISTENER *listener
        cdef char *_host = to_bytes(host)
        with nogil:
            listener = c_ssh2.libssh2_channel_forward_listen_ex(
                self._session, _host, port, &bound_port, queue_maxsize)
        if listener is NULL:
            return
        return PyListener(listener, self)

    def sftp_init(self):
        """Initialise SFTP channel.

        :rtype: :py:class:`ssh2.sftp.SFTP`
        """
        cdef c_sftp.LIBSSH2_SFTP *_sftp
        with nogil:
            _sftp = c_sftp.libssh2_sftp_init(self._session)
        if _sftp is NULL:
            return
        return PySFTP(_sftp, self)

    def last_error(self):
        """Retrieve last error message from libssh2, if any.
        Returns empty string on no error message.

        :rtype: str
        """
        cdef char **_error_msg = NULL
        cdef bytes msg
        cdef int errmsg_len = 0
        cdef int rc
        with nogil:
            rc = c_ssh2.libssh2_session_last_error(
                self._session, _error_msg, &errmsg_len, 0)
        if errmsg_len > 0 and _error_msg is not NULL:
            for line in _error_msg[:errmsg_len]:
                msg += line
        else:
            msg = b''
        return msg

    def scp_recv(self, path not None):
        """Receive file via SCP.

        Deprecated in favour or recv2 (requires libssh2 >= 1.7).

        :param path: File path to receive.
        :type path: str

        :rtype: tuple(:py:class:`ssh2.channel.Channel`,
          :py:class:`ssh2.statinfo.StatInfo`) or None"""
        cdef char *_path = to_bytes(path)
        cdef StatInfo statinfo = StatInfo()
        cdef c_ssh2.LIBSSH2_CHANNEL *channel
        with nogil:
            channel = c_ssh2.libssh2_scp_recv(
                self._session, _path, statinfo._stat)
        if channel is not NULL:
            return PyChannel(channel, self), statinfo

    IF EMBEDDED_LIB:
        def scp_recv2(self, path not None):
            """Receive file via SCP.

            Available only on libssh2 >= 1.7.

            :param path: File path to receive.
            :type path: str

            :rtype: tuple(:py:class:`ssh2.channel.Channel`,
            :py:class:`ssh2.fileinfo.FileInfo`) or None"""
            cdef FileInfo fileinfo = FileInfo()
            cdef char *_path = to_bytes(path)
            cdef c_ssh2.LIBSSH2_CHANNEL *channel
            with nogil:
                channel = c_ssh2.libssh2_scp_recv2(
                    self._session, _path, fileinfo._stat)
            if channel is not NULL:
                return PyChannel(channel, self), fileinfo

    def scp_send(self, path not None, int mode, size_t size):
        """Deprecated in favour of scp_send64. Send file via SCP.

        :param path: Local file path to send.
        :type path: str
        :param mode: File mode.
        :type mode: int
        :param size: size of file
        :type size: int

        :rtype: :py:class:`ssh2.channel.Channel`"""
        cdef char *_path = to_bytes(path)
        cdef c_ssh2.LIBSSH2_CHANNEL *channel
        with nogil:
            channel = c_ssh2.libssh2_scp_send(
                self._session, _path, mode, size)
        if channel is not NULL:
            return PyChannel(channel, self)

    def scp_send64(self, path not None, int mode, c_ssh2.libssh2_uint64_t size,
                   time_t mtime, time_t atime):
        """Send file via SCP.

        :param path: Local file path to send.
        :type path: str
        :param mode: File mode.
        :type mode: int
        :param size: size of file
        :type size: int

        :rtype: :py:class:`ssh2.channel.Channel`"""
        cdef char *_path = to_bytes(path)
        cdef c_ssh2.LIBSSH2_CHANNEL *channel
        with nogil:
            channel = c_ssh2.libssh2_scp_send64(
                self._session, _path, mode, size, mtime, atime)
        if channel is not NULL:
            return PyChannel(channel, self)

    def publickey_init(self):
        """Initialise public key subsystem for managing remote server
        public keys"""
        cdef c_pkey.LIBSSH2_PUBLICKEY *_pkey
        with nogil:
            _pkey= c_pkey.libssh2_publickey_init(self._session)
        if _pkey is not NULL:
            return PyPublicKeySystem(_pkey, self)
