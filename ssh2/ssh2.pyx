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

from select import select

from cpython cimport PyObject_AsFileDescriptor
from libc.stdlib cimport malloc, free

cimport ssh2
cimport sftp
cimport error_codes


LIBSSH2_ERROR_NONE = error_codes._LIBSSH2_ERROR_NONE
LIBSSH2_ERROR_NONE = error_codes._LIBSSH2_ERROR_NONE
LIBSSH2CHANNEL_EAGAIN = error_codes._LIBSSH2CHANNEL_EAGAIN
LIBSSH2_ERROR_EAGAIN = error_codes._LIBSSH2_ERROR_EAGAIN
LIBSSH2_ERROR_AUTHENTICATION_FAILED = error_codes._LIBSSH2_ERROR_AUTHENTICATION_FAILED
LIBSSH2_ERROR_SOCKET_RECV = error_codes._LIBSSH2_ERROR_SOCKET_RECV
LIBSSH2_SESSION_BLOCK_INBOUND = ssh2._LIBSSH2_SESSION_BLOCK_INBOUND
LIBSSH2_SESSION_BLOCK_OUTBOUND = ssh2._LIBSSH2_SESSION_BLOCK_OUTBOUND


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


def wait_socket(_socket, Session session):
    cdef int directions = session.blockdirections()
    if directions == 0:
        return 0
    readfds = [_socket] \
              if (directions & _LIBSSH2_SESSION_BLOCK_INBOUND) else ()
    writefds = [_socket] \
               if (directions & _LIBSSH2_SESSION_BLOCK_OUTBOUND) else ()
    return select(readfds, writefds, ())


cdef object PyChannel(LIBSSH2_CHANNEL *channel):
    cdef Channel _channel = Channel()
    _channel._channel = channel
    return _channel


cdef object PyListener(LIBSSH2_LISTENER *listener):
    cdef Listener _listener = Listener()
    _listener._listener = listener
    return _listener


cdef object PySFTPHandle(sftp.LIBSSH2_SFTP_HANDLE *handle):
    cdef SFTPHandle _handle = SFTPHandle()
    _handle._handle = handle
    return _handle


cdef object PySFTP(sftp.LIBSSH2_SFTP *sftp):
    cdef SFTP _sftp = SFTP()
    _sftp._sftp = sftp
    return _sftp


cdef class Listener:
    cdef ssh2.LIBSSH2_LISTENER *_listener

    def __cinit__(self):
        self._listener = NULL

    def forward_accept(self):
        cdef LIBSSH2_CHANNEL *channel
        with nogil:
            channel = libssh2_channel_forward_accept(
                self._listener)
        if channel is NULL:
            return
        return PyChannel(channel)

    def forward_cancel(self):
        cdef int rc
        with nogil:
            rc = libssh2_channel_forward_cancel(
                self._listener)
        return rc


cdef class SFTP:
    cdef sftp.LIBSSH2_SFTP *_sftp

    def __cinit__(self):
        self._sftp = NULL

    def __dealloc__(self):
        sftp.libssh2_sftp_shutdown(self._sftp)

    def get_channel(self):
        cdef LIBSSH2_CHANNEL *_channel
        with nogil:
            _channel = sftp.libssh2_sftp_get_channel(self._sftp)
        if _channel is NULL:
            return
        return PyChannel(_channel)

    def open_ex(self, const char *filename,
                unsigned int filename_len,
                unsigned long flags,
                long mode, int open_type):
        cdef sftp.LIBSSH2_SFTP_HANDLE *_handle
        with nogil:
            _handle = sftp.libssh2_sftp_open_ex(
                self._sftp, filename, filename_len, flags,
                mode, open_type)
        if _handle is NULL:
            return
        return PySFTPHandle(_handle)

    def open(self, const char *filename,
             unsigned long flags,
             long mode):
        cdef sftp.LIBSSH2_SFTP_HANDLE *_handle
        with nogil:
            _handle = sftp.libssh2_sftp_open(
                self._sftp, filename, flags, mode)
        if _handle is NULL:
            return
        return PySFTPHandle(_handle)

    def opendir(self, const char *path):
        cdef sftp.LIBSSH2_SFTP_HANDLE *_handle
        with nogil:
            _handle = sftp.libssh2_sftp_opendir(self._sftp, path)
        if _handle is NULL:
            return
        return PySFTPHandle(_handle)

    def rename_ex(self, const char *source_filename,
                  unsigned int source_filename_len,
                  const char *dest_filename,
                  unsigned int dest_filename_len,
                  long flags):
        cdef int rc
        with nogil:
            rc = sftp.libssh2_sftp_rename_ex(
                self._sftp, source_filename, source_filename_len,
                dest_filename, dest_filename_len, flags)
        return rc

    def rename(self, const char *source_filename, const char *dest_filename):
        cdef int rc
        with nogil:
            rc = sftp.libssh2_sftp_rename(
                self._sftp, source_filename, dest_filename)
        return rc

    def unlink(self, const char *filename):
        cdef int rc
        with nogil:
            rc = sftp.libssh2_sftp_unlink(self._sftp, filename)
        return rc

    def fstatvfs(self):
        raise NotImplementedError

    def statvfs(self):
        raise NotImplementedError

    def mkdir(self, const char *path, long mode):
        cdef int rc
        with nogil:
            rc = sftp.libssh2_sftp_mkdir(self._sftp, path, mode)
        return rc

    def rmdir(self, const char *path):
        cdef int rc
        with nogil:
            rc = sftp.libssh2_sftp_rmdir(self._sftp, path)
        return rc

    def stat(self, const char *path, SFTPAttributes attrs):
        cdef int rc
        with nogil:
            rc = sftp.libssh2_sftp_stat(
                self._sftp, path, attrs._attrs)
        return rc

    def lstat(self, const char *path, SFTPAttributes attrs):
        cdef int rc
        with nogil:
            rc = sftp.libssh2_sftp_lstat(
                self._sftp, path, attrs._attrs)
        return rc

    def setstat(self, const char *path, SFTPAttributes attrs):
        cdef int rc
        with nogil:
            rc = sftp.libssh2_sftp_setstat(
                self._sftp, path, attrs._attrs)
        return rc

    def symlink(self, const char *path, char *target):
        cdef int rc
        with nogil:
            rc = sftp.libssh2_sftp_symlink(self._sftp, path, target)
        return rc

    def realpath(self, const char *path, char *target,
                 unsigned int maxlen):
        cdef int rc
        with nogil:
            rc = sftp.libssh2_sftp_realpath(
                self._sftp, path, target, maxlen)
        return rc


cdef class SFTPAttributes:
    cdef sftp.LIBSSH2_SFTP_ATTRIBUTES *_attrs

    def __cinit__(self):
        self._attrs = NULL


# cdef class SFTPFile:
#     cdef SFTPHandle _handle

#     def __cinit__(self, SFTPHandle _handle):
#         self._handle = _handle


cdef class SFTPHandle:
    cdef sftp.LIBSSH2_SFTP_HANDLE *_handle

    def __cinit__(self):
        self._handle = NULL

    def __dealloc__(self):
        if self._handle is not NULL:
            sftp.libssh2_sftp_close_handle(self._handle)

    def __iter__(self):
        return self

    def __next__(self):
        cdef bytes data
        data = self.read()
        if len(data) == 0:
            raise StopIteration
        return data

    def close(self):
        cdef int rc
        with nogil:
            rc = sftp.libssh2_sftp_close_handle(self._handle)
        return rc

    def read(self, size_t buffer_maxlen=1024):
        cdef ssize_t rc
        cdef bytes buf
        cdef char *cbuf
        with nogil:
            cbuf = <char *>malloc(sizeof(char)*buffer_maxlen)
            rc = sftp.libssh2_sftp_read(
                self._handle, cbuf, buffer_maxlen)
        try:
            if rc > 0:
                buf = cbuf[:rc]
            else:
                buf = b''
        finally:
            free(cbuf)
        return buf

    def readdir_ex(self, char *buffer, size_t buffer_maxlen,
                   char *longentry,
                   size_t longentry_maxlen,
                   SFTPAttributes attrs):
        raise NotImplementedError

    def readdir(self, char *buffer, size_t buffer_maxlen,
                SFTPAttributes attrs):
        raise NotImplementedError

    def write(self, const char *buf, size_t count):
        raise NotImplementedError

    def fsync(self):
        raise NotImplementedError

    def seek(self, size_t offset):
        raise NotImplementedError

    def seek64(self, size_t offset):
        raise NotImplementedError

    def rewind(self):
        raise NotImplementedError

    def tell(self):
        raise NotImplementedError

    def tell64(self):
        raise NotImplementedError

    def fstat_ex(self, SFTPAttributes attrs, int setstat):
        raise NotImplementedError

    def fstat(self, SFTPAttributes attrs):
        raise NotImplementedError

    def fsetstat(self, SFTPAttributes attrs):
        raise NotImplementedError

cdef class Channel:
    cdef ssh2.LIBSSH2_CHANNEL *_channel

    def __cinit__(self):
        self._channel = NULL

    def __dealloc__(self):
        with nogil:
            if self._channel is not NULL:
                ssh2.libssh2_channel_close(self._channel)

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
        """Request subsystem from channel

        :param subsystem: Name of subsystem
        :type subsystem: str"""
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

    def read(self, size_t size=1024):
        """Read the stdout stream.
        Returns return code and output buffer tuple.

        Return code is the size of the buffer when positive.
        Negative values are error codes.

        :rtype: (int, bytes)"""
        return self.read_ex(size=size, stream_id=0)

    def read_ex(self, size_t size=1024, int stream_id=0):
        """Read the stream with given id.
        Returns return code and output buffer tuple.

        Return code is the size of the buffer when positive.
        Negative values are error codes.

        :rtype: (int, bytes)"""
        cdef bytes buf
        cdef char *cbuf
        with nogil:
            cbuf = <char *>malloc(sizeof(char)*size)
            rc = ssh2.libssh2_channel_read_ex(
                self._channel, stream_id, cbuf, size)
        try:
            if rc > 0:
                buf = cbuf[:rc]
            else:
                buf = b''
        finally:
            free(cbuf)
        return rc, buf

    def read_stderr(self, size_t size=1024):
        """Read the stderr stream.
        Returns return code and output buffer tuple.

        Return code is the size of the buffer when positive.
        Negative values are error codes.

        :rtype: (int, bytes)"""
        return self.read_ex(size=size, stream_id=ssh2._SSH_EXTENDED_DATA_STDERR)

    def eof(self):
        """Get channel EOF status

        :rtype: bool"""
        cdef int rc
        with nogil:
            rc = ssh2.libssh2_channel_eof(self._channel)
        return bool(rc)

    def send_eof(self):
        """Tell the remote host that no further data will be sent on the
        specified channel. Processes typically interpret this as a closed stdin
        descriptor.

        Return 0 on success or negative on failure.
        It returns LIBSSH2_ERROR_EAGAIN when it would otherwise block

        :rtype: int
        """
        cdef int rc
        with nogil:
            rc = ssh2.libssh2_channel_send_eof(self._channel)
        return rc

    def wait_eof(self):
        """Wait for the remote end to acknowledge an EOF request

        Return 0 on success or negative on failure. It returns
        LIBSSH2_ERROR_EAGAIN when it would otherwise block

        :rtype: int
        """
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

    def setenv(self, const char *varname, const char *value):
        cdef int rc
        with nogil:
            rc = libssh2_channel_setenv(
                self._channel, varname, value)
        return rc

    def window_read_ex(self, unsigned long read_avail,
                       unsigned long window_size_initial):
        cdef unsigned long rc
        with nogil:
            rc = ssh2.libssh2_channel_window_read_ex(
                self._channel, &read_avail, &window_size_initial)
        return rc

    def window_read(self):
        cdef unsigned long rc
        with nogil:
            rc = ssh2.libssh2_channel_window_read(self._channel)
        return rc


cdef class Session:
    cdef ssh2.LIBSSH2_SESSION *_session

    """LibSSH2 Session class providing session functions"""

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
                    break
                prev = identity
        self._clear_agent(agent)

    def open_session(self):
        cdef LIBSSH2_CHANNEL *channel
        with nogil:
            channel = libssh2_channel_open_session(
                self._session)
        if channel is NULL:
            return None
        return PyChannel(channel)

    def direct_tcpip_ex(self, const char *host, int port,
                        const char *shost, int sport):
        cdef LIBSSH2_CHANNEL *channel
        with nogil:
            channel = libssh2_channel_direct_tcpip_ex(
                self._session, host, port, shost, sport)
        if channel is NULL:
            return
        return PyChannel(channel)

    def direct_tcpip(self, const char *host, int port):
        cdef LIBSSH2_CHANNEL *channel
        with nogil:
            channel = libssh2_channel_direct_tcpip(
                self._session, host, port)
        if channel is NULL:
            return
        return PyChannel(channel)

    def blockdirections(self):
        cdef int rc
        with nogil:
            rc = libssh2_session_block_directions(
                self._session)
        return rc

    def forward_listen(self, int port):
        cdef LIBSSH2_LISTENER *listener
        with nogil:
            listener = libssh2_channel_forward_listen(
                self._session, port)
        if listener is NULL:
            return
        return PyListener(listener)

    def forward_listen_ex(self, const char *host, int port,
                          int bound_port, int queue_maxsize):
        cdef LIBSSH2_LISTENER *listener
        with nogil:
            listener = libssh2_channel_forward_listen_ex(
                self._session, host, port, &bound_port, queue_maxsize)
        if listener is NULL:
            return
        return PyListener(listener)

    def sftp_init(self):
        cdef sftp.LIBSSH2_SFTP *_sftp
        with nogil:
            _sftp = sftp.libssh2_sftp_init(self._session)
        if _sftp is NULL:
            return
        return PySFTP(_sftp)

    def last_error(self):
        cdef char **_error_msg = NULL
        cdef bytes msg
        cdef int errmsg_len = 0
        cdef int rc
        with nogil:
            rc = ssh2.libssh2_session_last_error(
                self._session, _error_msg, &errmsg_len, 0)
        if errmsg_len > 0 and _error_msg is not NULL:
            for line in _error_msg[errmsg_len]:
                msg += line
        else:
            msg = b''
        return msg

    # def scp_recv64(self, const char *path, stat *sb):
    #     cdef ssh2.LIBSSH2_CHANNEL *_channel
    #     with nogil:
    #         _channel = ssh2.libssh2_scp_recv(
    #             self._session, path, sb)
    #     if _channel is NULL:
    #         return
    #     return PyChannel(_channel)
