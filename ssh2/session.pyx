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
from libc.time cimport time_t

from agent cimport PyAgent, agent_auth, agent_init, init_connect_agent
from channel cimport PyChannel
from exceptions import SessionHostKeyError, KnownHostError, \
    PublicKeyInitError, ChannelError
from listener cimport PyListener
from sftp cimport PySFTP
from publickey cimport PyPublicKeySystem
from utils cimport to_bytes, to_str, handle_error_codes
from statinfo cimport StatInfo
from knownhost cimport PyKnownHost
IF EMBEDDED_LIB:
    from fileinfo cimport FileInfo


cimport c_ssh2
cimport c_sftp
cimport c_pkey


LIBSSH2_SESSION_BLOCK_INBOUND = c_ssh2.LIBSSH2_SESSION_BLOCK_INBOUND
LIBSSH2_SESSION_BLOCK_OUTBOUND = c_ssh2.LIBSSH2_SESSION_BLOCK_OUTBOUND
LIBSSH2_HOSTKEY_HASH_MD5 = c_ssh2.LIBSSH2_HOSTKEY_HASH_MD5
LIBSSH2_HOSTKEY_HASH_SHA1 = c_ssh2.LIBSSH2_HOSTKEY_HASH_SHA1
LIBSSH2_HOSTKEY_TYPE_UNKNOWN = c_ssh2.LIBSSH2_HOSTKEY_TYPE_UNKNOWN
LIBSSH2_HOSTKEY_TYPE_RSA = c_ssh2.LIBSSH2_HOSTKEY_TYPE_RSA
LIBSSH2_HOSTKEY_TYPE_DSS = c_ssh2.LIBSSH2_HOSTKEY_TYPE_DSS


cdef class Session:

    """LibSSH2 Session class providing session functions"""

    def __cinit__(self):
        self._session = c_ssh2.libssh2_session_init()
        if self._session is NULL:
            raise MemoryError
        self._sock = 0
        self.sock = None

    def __dealloc__(self):
        if self._session is not NULL:
            c_ssh2.libssh2_session_free(self._session)
        self._session = NULL

    def disconnect(self):
        cdef int rc
        with nogil:
            rc = c_ssh2.libssh2_session_disconnect(self._session, b"end")
        return handle_error_codes(rc)

    def handshake(self, sock not None):
        """Perform SSH handshake.

        Must be called after Session initialisation."""
        cdef int _sock = PyObject_AsFileDescriptor(sock)
        cdef int rc
        with nogil:
            rc = c_ssh2.libssh2_session_handshake(self._session, _sock)
            self._sock = _sock
        self.sock = sock
        return handle_error_codes(rc)

    def startup(self, sock):
        """Deprecated - use self.handshake"""
        cdef int _sock = PyObject_AsFileDescriptor(sock)
        cdef int rc
        rc = c_ssh2.libssh2_session_startup(self._session, _sock)
        return handle_error_codes(rc)

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
        """Set the timeout in milliseconds for how long a blocking
        call may wait until the situation is considered an error and
        :py:class:`ssh2.error_codes.LIBSSH2_ERROR_TIMEOUT` is returned.

        By default or if timeout set is zero, blocking calls do not
        time out.
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
        """Retrieve available authentication methods list.

        :rtype: list"""
        cdef bytes b_username = to_bytes(username)
        cdef char *_username = b_username
        cdef size_t username_len = len(b_username)
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
                                    privatekey not None,
                                    passphrase='',
                                    publickey=None):
        """Authenticate with public key from file.

        :rtype: int"""
        cdef int rc
        cdef bytes b_username = to_bytes(username)
        cdef bytes b_publickey = to_bytes(publickey) \
            if publickey is not None else None
        cdef bytes b_privatekey = to_bytes(privatekey)
        cdef bytes b_passphrase = to_bytes(passphrase)
        cdef char *_username = b_username
        cdef char *_publickey = NULL
        cdef char *_privatekey = b_privatekey
        cdef char *_passphrase = b_passphrase
        if b_publickey is not None:
            _publickey = b_publickey
        with nogil:
            rc = c_ssh2.libssh2_userauth_publickey_fromfile(
                self._session, _username, _publickey, _privatekey, _passphrase)
        return handle_error_codes(rc)

    def userauth_publickey(self, username not None,
                           bytes pubkeydata not None):
        """Perform public key authentication with provided public key data

        :param username: User name to authenticate as
        :type username: str
        :param pubkeydata: Public key data
        :type pubkeydata: bytes

        :rtype: int"""
        cdef int rc
        cdef bytes b_username = to_bytes(username)
        cdef char *_username = b_username
        cdef unsigned char *_pubkeydata = pubkeydata
        cdef size_t pubkeydata_len = len(pubkeydata)
        with nogil:
            rc = c_ssh2.libssh2_userauth_publickey(
                self._session, _username, _pubkeydata,
                pubkeydata_len, NULL, NULL)
        return handle_error_codes(rc)

    def userauth_hostbased_fromfile(self,
                                    username not None,
                                    privatekey not None,
                                    hostname not None,
                                    publickey=None,
                                    passphrase=''):
        cdef int rc
        cdef bytes b_username = to_bytes(username)
        cdef bytes b_publickey = to_bytes(publickey) \
            if publickey is not None else None
        cdef bytes b_privatekey = to_bytes(privatekey)
        cdef bytes b_passphrase = to_bytes(passphrase)
        cdef bytes b_hostname = to_bytes(hostname)
        cdef char *_username = b_username
        cdef char *_publickey = NULL
        cdef char *_privatekey = b_privatekey
        cdef char *_passphrase = b_passphrase
        cdef char *_hostname = b_hostname
        if b_publickey is not None:
            _publickey = b_publickey
        with nogil:
            rc = c_ssh2.libssh2_userauth_hostbased_fromfile(
                self._session, _username, _publickey,
                _privatekey, _passphrase, _hostname)
        return handle_error_codes(rc)

    IF EMBEDDED_LIB:
        def userauth_publickey_frommemory(
                self, username, bytes privatekeyfiledata,
                passphrase='', bytes publickeyfiledata=None):
            cdef int rc
            cdef bytes b_username = to_bytes(username)
            cdef bytes b_passphrase = to_bytes(passphrase)
            cdef char *_username = b_username
            cdef char *_passphrase = b_passphrase
            cdef char *_publickeyfiledata = NULL
            cdef char *_privatekeyfiledata = privatekeyfiledata
            cdef size_t username_len, pubkeydata_len, privatekeydata_len
            username_len, pubkeydata_len, privatekeydata_len = \
                len(b_username), len(publickeyfiledata), \
                len(privatekeyfiledata)
            if publickeyfiledata is not None:
                _publickeyfiledata = publickeyfiledata
            with nogil:
                rc = c_ssh2.libssh2_userauth_publickey_frommemory(
                    self._session, _username, username_len, _publickeyfiledata,
                    pubkeydata_len, _privatekeyfiledata,
                    privatekeydata_len, _passphrase)
            return handle_error_codes(rc)

    def userauth_password(self, username not None, password not None):
        """Perform password authentication

        :param username: User name to authenticate.
        :type username: str
        :param password: Password
        :type password: str"""
        cdef int rc
        cdef bytes b_username = to_bytes(username)
        cdef bytes b_password = to_bytes(password)
        cdef const char *_username = b_username
        cdef const char *_password = b_password
        with nogil:
            rc = c_ssh2.libssh2_userauth_password(
                self._session, _username, _password)
        return handle_error_codes(rc)

    def agent_init(self):
        """Initialise SSH agent.

        :rtype: :py:class:`ssh2.agent.Agent`
        """
        cdef c_ssh2.LIBSSH2_AGENT *agent
        with nogil:
            agent = agent_init(self._session)
        return PyAgent(agent, self)

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
        :raises: :py:class:`ssh2.exceptions.AgentAuthenticationError` on no
          successful authentication with all available identities.
        :raises: :py:class:`ssh2.exceptions.AgentGetIdentityError` on error
          getting known identity from agent

        :rtype: None"""
        cdef bytes b_username = to_bytes(username)
        cdef char *_username = b_username
        cdef c_ssh2.LIBSSH2_AGENT *agent = NULL
        cdef c_ssh2.libssh2_agent_publickey *identity = NULL
        cdef c_ssh2.libssh2_agent_publickey *prev = NULL
        agent = init_connect_agent(self._session)
        with nogil:
            agent_auth(_username, agent)

    def open_session(self):
        """Open new channel session.

        :rtype: :py:class:`ssh2.channel.Channel`
        """
        cdef c_ssh2.LIBSSH2_CHANNEL *channel
        with nogil:
            channel = c_ssh2.libssh2_channel_open_session(
                self._session)
        if channel is NULL:
            return handle_error_codes(c_ssh2.libssh2_session_last_errno(
                self._session))
        return PyChannel(channel, self)

    def direct_tcpip_ex(self, host not None, int port,
                        shost not None, int sport):
        cdef c_ssh2.LIBSSH2_CHANNEL *channel
        cdef bytes b_host = to_bytes(host)
        cdef bytes b_shost = to_bytes(shost)
        cdef char *_host = b_host
        cdef char *_shost = b_shost
        with nogil:
            channel = c_ssh2.libssh2_channel_direct_tcpip_ex(
                self._session, _host, port, _shost, sport)
        if channel is NULL:
            return handle_error_codes(c_ssh2.libssh2_session_last_errno(
                self._session))
        return PyChannel(channel, self)

    def direct_tcpip(self, host not None, int port):
        """Open direct TCP/IP channel to host:port

        Channel will be listening on an available open port on client side
        as assigned by OS.
        """
        cdef c_ssh2.LIBSSH2_CHANNEL *channel
        cdef bytes b_host = to_bytes(host)
        cdef char *_host = b_host
        with nogil:
            channel = c_ssh2.libssh2_channel_direct_tcpip(
                self._session, _host, port)
        if channel is NULL:
            return handle_error_codes(c_ssh2.libssh2_session_last_errno(
                self._session))
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
            return handle_error_codes(c_ssh2.libssh2_session_last_errno(
                self._session))
        return PyListener(listener, self)

    def forward_listen_ex(self, host not None, int port,
                          int bound_port, int queue_maxsize):
        cdef c_ssh2.LIBSSH2_LISTENER *listener
        cdef bytes b_host = to_bytes(host)
        cdef char *_host = b_host
        with nogil:
            listener = c_ssh2.libssh2_channel_forward_listen_ex(
                self._session, _host, port, &bound_port, queue_maxsize)
        if listener is NULL:
            return handle_error_codes(c_ssh2.libssh2_session_last_errno(
                self._session))
        return PyListener(listener, self)

    def sftp_init(self):
        """Initialise SFTP channel.

        :rtype: :py:class:`ssh2.sftp.SFTP`
        """
        cdef c_sftp.LIBSSH2_SFTP *_sftp
        with nogil:
            _sftp = c_sftp.libssh2_sftp_init(self._session)
        if _sftp is NULL:
            return handle_error_codes(c_ssh2.libssh2_session_last_errno(
                self._session))
        return PySFTP(_sftp, self)

    def last_error(self, size_t msg_size=1024):
        """Retrieve last error message from libssh2, if any.
        Returns empty string on no error message.

        :rtype: str
        """
        cdef char *_error_msg
        cdef bytes msg = b''
        cdef int errmsg_len = 0
        with nogil:
            _error_msg = <char *>malloc(sizeof(char) * msg_size)
            c_ssh2.libssh2_session_last_error(
                self._session, &_error_msg, &errmsg_len, 1)
        try:
            if errmsg_len > 0:
                msg = _error_msg[:errmsg_len]
            return msg
        finally:
            free(_error_msg)

    def last_errno(self):
        """Retrieve last error number from libssh2, if any.
        Returns 0 on no last error.

        :rtype: int
        """
        cdef int rc
        with nogil:
            rc = c_ssh2.libssh2_session_last_errno(
                self._session)
        return rc

    IF EMBEDDED_LIB:
        def set_last_error(self, int errcode, errmsg not None):
            cdef bytes b_errmsg = to_bytes(errmsg)
            cdef char *_errmsg = b_errmsg
            cdef int rc
            with nogil:
                rc = c_ssh2.libssh2_session_set_last_error(
                    self._session, errcode, _errmsg)
            return rc

    def scp_recv(self, path not None):
        """Receive file via SCP.

        Deprecated in favour or recv2 (requires libssh2 >= 1.7).

        :param path: File path to receive.
        :type path: str

        :rtype: tuple(:py:class:`ssh2.channel.Channel`,
          :py:class:`ssh2.statinfo.StatInfo`) or None"""
        cdef bytes b_path = to_bytes(path)
        cdef char *_path = b_path
        cdef StatInfo statinfo = StatInfo()
        cdef c_ssh2.LIBSSH2_CHANNEL *channel
        with nogil:
            channel = c_ssh2.libssh2_scp_recv(
                self._session, _path, statinfo._stat)
        if channel is NULL:
            return handle_error_codes(c_ssh2.libssh2_session_last_errno(
                self._session))
        return PyChannel(channel, self), statinfo

    IF EMBEDDED_LIB:
        def scp_recv2(self, path not None):
            """Receive file via SCP.

            Available only on libssh2 >= 1.7.

            :param path: File path to receive.
            :type path: str

            :rtype: tuple(:py:class:`ssh2.channel.Channel`,
              :py:class:`ssh2.fileinfo.FileInfo`) or ``None``"""
            cdef FileInfo fileinfo = FileInfo()
            cdef bytes b_path = to_bytes(path)
            cdef char *_path = b_path
            cdef c_ssh2.LIBSSH2_CHANNEL *channel
            with nogil:
                channel = c_ssh2.libssh2_scp_recv2(
                    self._session, _path, fileinfo._stat)
            if channel is NULL:
                return handle_error_codes(c_ssh2.libssh2_session_last_errno(
                    self._session))
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
        cdef bytes b_path = to_bytes(path)
        cdef char *_path = b_path
        cdef c_ssh2.LIBSSH2_CHANNEL *channel
        with nogil:
            channel = c_ssh2.libssh2_scp_send(
                self._session, _path, mode, size)
        if channel is NULL:
            return handle_error_codes(c_ssh2.libssh2_session_last_errno(
                self._session))
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
        cdef bytes b_path = to_bytes(path)
        cdef char *_path = b_path
        cdef c_ssh2.LIBSSH2_CHANNEL *channel
        with nogil:
            channel = c_ssh2.libssh2_scp_send64(
                self._session, _path, mode, size, mtime, atime)
        if channel is NULL:
            return handle_error_codes(c_ssh2.libssh2_session_last_errno(
                self._session))
        return PyChannel(channel, self)

    def publickey_init(self):
        """Initialise public key subsystem for managing remote server
        public keys"""
        cdef c_pkey.LIBSSH2_PUBLICKEY *_pkey
        with nogil:
            _pkey = c_pkey.libssh2_publickey_init(self._session)
        if _pkey is NULL:
            raise PublicKeyInitError
        return PyPublicKeySystem(_pkey, self)

    def hostkey_hash(self, int hash_type):
        """Get computed digest of the remote system's host key.

        :param hash_type: One of ``ssh2.session.LIBSSH2_HOSTKEY_HASH_MD5`` or
          ``ssh2.session.LIBSSH2_HOSTKEY_HASH_SHA1``
        :type hash_type: int

        :rtype: bytes"""
        cdef const char *_hash
        cdef bytes b_hash
        with nogil:
            _hash = c_ssh2.libssh2_hostkey_hash(self._session, hash_type)
        if _hash is NULL:
            return
        b_hash = _hash
        return b_hash

    def hostkey(self):
        """Get server host key for this session.

        Returns key, key_type tuple where key_type is one of
        :py:class:`ssh2.session.LIBSSH2_HOSTKEY_TYPE_RSA`,
        :py:class:`ssh2.session.LIBSSH2_HOSTKEY_TYPE_DSS`, or
        :py:class:`ssh2.session.LIBSSH2_HOSTKEY_TYPE_UNKNOWN`

        :rtype: tuple(bytes, int)"""
        cdef bytes key = b""
        cdef const char *_key
        cdef size_t key_len = 0
        cdef int key_type = 0
        with nogil:
            _key = c_ssh2.libssh2_session_hostkey(
                self._session, &key_len, &key_type)
        if _key is NULL:
            raise SessionHostKeyError(
                "Error retrieving server host key for session")
        key = _key[:key_len]
        return key, key_type

    def knownhost_init(self):
        """Initialise a collection of known hosts for this session.

        :rtype: :py:class:`ssh2.knownhost.KnownHost`"""
        cdef c_ssh2.LIBSSH2_KNOWNHOSTS *known_hosts
        with nogil:
            known_hosts = c_ssh2.libssh2_knownhost_init(
                self._session)
        if known_hosts is NULL:
            raise KnownHostError
        return PyKnownHost(self, known_hosts)

    def keepalive_config(self, bint want_reply, unsigned interval):
        """
        Configure keep alive settings.

        :param want_reply: True/False for reply wanted from server on keep
          alive messages being sent or not.
        :type want_reply: bool
        :param interval: Required keep alive interval. Set to ``0`` to disable
          keepalives.
        :type interval: int"""
        with nogil:
            c_ssh2.libssh2_keepalive_config(self._session, want_reply, interval)

    def keepalive_send(self):
        """Send keepalive.

        Returns seconds remaining before next keep alive should be sent.

        :rtype: int"""
        cdef int seconds = 0
        cdef int c_seconds = 0
        cdef int rc
        with nogil:
            rc = c_ssh2.libssh2_keepalive_send(self._session, &c_seconds)
        handle_error_codes(rc)
        return c_seconds
