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

from libc.stdlib cimport malloc, free
from session cimport Session
from exceptions import ChannelError
from utils cimport to_bytes, handle_error_codes

cimport c_ssh2
cimport sftp
cimport error_codes


cdef object PyChannel(c_ssh2.LIBSSH2_CHANNEL *channel, Session session):
    cdef Channel _channel = Channel.__new__(Channel, session)
    _channel._channel = channel
    return _channel


cdef class Channel:

    def __cinit__(self, Session session):
        self._session = session

    def __dealloc__(self):
        if self._channel is not NULL:
            c_ssh2.libssh2_channel_free(self._channel)
        self._channel = NULL

    @property
    def session(self):
        """Originating session."""
        return self._session

    def pty(self, term="vt100"):
        """Request a PTY (physical terminal emulation) on the channel.

        :param term: Terminal type to emulate.
        :type term: str
        """
        cdef bytes b_term = to_bytes(term)
        cdef const char *_term = b_term
        cdef int rc
        with nogil:
            rc = c_ssh2.libssh2_channel_request_pty(
                self._channel, _term)
        return handle_error_codes(rc)

    def execute(self, command not None):
        """Execute command.

        :param command: Command to execute
        :type command: str

        :raises: :py:class:`ssh2.exceptions.ChannelError` on errors executing
          command

        :rtype: int
        """
        cdef int rc
        cdef bytes b_command = to_bytes(command)
        cdef char *_command = b_command
        with nogil:
            rc = c_ssh2.libssh2_channel_exec(
                self._channel, _command)
        return handle_error_codes(rc)

    def subsystem(self, subsystem not None):
        """Request subsystem from channel.

        :param subsystem: Name of subsystem
        :type subsystem: str"""
        cdef int rc
        cdef bytes b_subsystem = to_bytes(subsystem)
        cdef char *_subsystem = b_subsystem
        with nogil:
            rc = c_ssh2.libssh2_channel_subsystem(
                self._channel, _subsystem)
        return handle_error_codes(rc)

    def shell(self):
        """Request interactive shell from channel.

        :raises: :py:class:`ssh2.exceptions.ChannelError` on errors requesting
          interactive shell.
        """
        cdef int rc
        with nogil:
            rc = c_ssh2.libssh2_channel_shell(self._channel)
        return handle_error_codes(rc)

    def read(self, size_t size=1024):
        """Read the stdout stream.
        Returns return code and output buffer tuple.

        Return code is the size of the buffer when positive.
        Negative values are error codes.

        :param size: Max buffer size to read.
        :type size: int

        :rtype: (int, bytes)"""
        return self.read_ex(size=size, stream_id=0)

    def read_ex(self, size_t size=1024, int stream_id=0):
        """Read the stream with given id.
        Returns return code and output buffer tuple.

        Return code is the size of the buffer when positive.
        Negative values are error codes.

        :param size: Max buffer size to read.
        :type size: int

        :rtype: (int, bytes)"""
        cdef bytes buf = b''
        cdef char *cbuf
        cdef ssize_t rc
        with nogil:
            cbuf = <char *>malloc(sizeof(char)*size)
            if cbuf is NULL:
                with gil:
                    raise MemoryError
            rc = c_ssh2.libssh2_channel_read_ex(
                self._channel, stream_id, cbuf, size)
        try:
            if rc > 0:
                buf = cbuf[:rc]
        finally:
            free(cbuf)
        handle_error_codes(rc)
        return rc, buf

    def read_stderr(self, size_t size=1024):
        """Read the stderr stream.
        Returns return code and output buffer tuple.

        Return code is the size of the buffer when positive.
        Negative values are error codes.

        :rtype: (int, bytes)"""
        return self.read_ex(
            size=size, stream_id=c_ssh2.SSH_EXTENDED_DATA_STDERR)

    def eof(self):
        """Get channel EOF status.

        :rtype: bool"""
        cdef int rc
        with nogil:
            rc = c_ssh2.libssh2_channel_eof(self._channel)
        return bool(rc)

    def send_eof(self):
        """Tell the remote host that no further data will be sent on the
        specified channel. Processes typically interpret this as a closed stdin
        descriptor.

        Returns 0 on success or negative on failure.
        It returns ``LIBSSH2_ERROR_EAGAIN`` when it would otherwise block.

        :rtype: int
        """
        cdef int rc
        with nogil:
            rc = c_ssh2.libssh2_channel_send_eof(self._channel)
        return handle_error_codes(rc)

    def wait_eof(self):
        """Wait for the remote end to acknowledge an EOF request.

        Returns 0 on success or negative on failure. It returns
        :py:class:`ssh2.error_codes.LIBSSH2_ERROR_EAGAIN` when it
        would otherwise block.

        :rtype: int
        """
        cdef int rc
        with nogil:
            rc = c_ssh2.libssh2_channel_wait_eof(self._channel)
        return handle_error_codes(rc)

    def close(self):
        """Close channel. Typically done to be able to get exit status."""
        cdef int rc
        with nogil:
            rc = c_ssh2.libssh2_channel_close(self._channel)
        return handle_error_codes(rc)

    def flush(self):
        """Flush stdout stream"""
        cdef int rc
        with nogil:
            rc = c_ssh2.libssh2_channel_flush(self._channel)
        return handle_error_codes(rc)

    def flush_ex(self, int stream_id):
        """Flush stream with id"""
        cdef int rc
        with nogil:
            rc = c_ssh2.libssh2_channel_flush_ex(self._channel, stream_id)
        return handle_error_codes(rc)

    def flush_stderr(self):
        """Flush stderr stream"""
        cdef int rc
        with nogil:
            rc = c_ssh2.libssh2_channel_flush_stderr(self._channel)
        return handle_error_codes(rc)

    def wait_closed(self):
        """Wait for server to acknowledge channel close command."""
        cdef int rc
        with nogil:
            rc = c_ssh2.libssh2_channel_wait_closed(self._channel)
        return handle_error_codes(rc)

    def get_exit_status(self):
        """Get exit status of command.

        Note that ``0`` is also failure code for this function.

        Best used in non-blocking mode to avoid it being impossible to tell if
        ``0`` indicates failure or an actual exit status of ``0``"""
        cdef int rc
        with nogil:
            rc = c_ssh2.libssh2_channel_get_exit_status(self._channel)
        return handle_error_codes(rc)

    def get_exit_signal(self):
        """Get exit signal, message and language tag, if any, for command.

        Returns (`returncode``, ``exit signal``, ``error message``,
          ``language tag``) tuple.

        :rtype: tuple(int, bytes, bytes, bytes)"""
        cdef char *exitsignal = <char *>b'none'
        cdef size_t *exitsignal_len = <size_t *>0
        cdef char *errmsg = <char *>b'none'
        cdef size_t *errmsg_len = <size_t *>0
        cdef char *langtag = <char *>b'none'
        cdef size_t *langtag_len = <size_t *>0
        cdef int rc
        cdef bytes py_exitsignal = None
        cdef bytes py_errmsg = None
        cdef bytes py_langtag = None
        cdef size_t py_siglen = 0
        cdef size_t py_errlen = 0
        cdef size_t py_langlen = 0
        with nogil:
            rc = c_ssh2.libssh2_channel_get_exit_signal(
                self._channel, &exitsignal, exitsignal_len, &errmsg,
                errmsg_len, &langtag, langtag_len)
            if exitsignal_len is not NULL:
                py_siglen = <size_t>exitsignal_len
            if errmsg_len is not NULL:
                py_errlen = <size_t>errmsg_len
            if langtag_len is not NULL:
                py_langlen = <size_t>langtag_len
        if py_siglen > 0:
            py_exitsignal = exitsignal[:py_siglen]
        if py_errlen > 0:
            py_errmsg = errmsg[:py_errlen]
        if py_langlen > 0:
            py_langtag = langtag[:py_langlen]
        return handle_error_codes(rc), py_exitsignal, py_errmsg, py_langtag

    def setenv(self, varname not None, value not None):
        """Set environment variable on channel.

        :param varname: Name of variable to set.
        :type varname: str
        :param value: Value of variable.
        :type value: str

        :rtype: int"""
        cdef int rc
        cdef bytes b_varname = to_bytes(varname)
        cdef bytes b_value = to_bytes(value)
        cdef char *_varname = b_varname
        cdef char *_value = b_value
        with nogil:
            rc = c_ssh2.libssh2_channel_setenv(
                self._channel, _varname, _value)
        return handle_error_codes(rc)

    def window_read_ex(self, unsigned long read_avail,
                       unsigned long window_size_initial):
        cdef unsigned long rc
        with nogil:
            rc = c_ssh2.libssh2_channel_window_read_ex(
                self._channel, &read_avail, &window_size_initial)
        return handle_error_codes(rc)

    def window_read(self):
        cdef unsigned long rc
        with nogil:
            rc = c_ssh2.libssh2_channel_window_read(self._channel)
        return handle_error_codes(rc)

    def window_write_ex(self, unsigned long window_size_initial):
        cdef unsigned long rc
        with nogil:
            rc = c_ssh2.libssh2_channel_window_write_ex(
                self._channel, &window_size_initial)
        return handle_error_codes(rc)

    def window_write(self):
        cdef unsigned long rc
        with nogil:
            rc = c_ssh2.libssh2_channel_window_write(self._channel)
        return handle_error_codes(rc)

    def receive_window_adjust(self, unsigned long adjustment,
                              unsigned long force):
        cdef unsigned long rc
        with nogil:
            rc = c_ssh2.libssh2_channel_receive_window_adjust(
                self._channel, adjustment, force)
        return handle_error_codes(rc)

    def receive_window_adjust2(self, unsigned long adjustment,
                               unsigned long force):
        cdef unsigned long rc
        cdef unsigned int storewindow = 0
        with nogil:
            rc = c_ssh2.libssh2_channel_receive_window_adjust2(
                self._channel, adjustment, force, &storewindow)
        return handle_error_codes(rc)

    def write(self, buf not None):
        """Write buffer to stdin.

        Returns tuple of (``return_code``, ``bytes_written``).

        In blocking mode ``bytes_written`` will always equal ``len(buf)`` if no
        errors have occurred which would raise exception.

        In non-blocking mode ``return_code`` can be LIBSSH2_ERROR_EAGAIN and
        ``bytes_written`` *can be less than* ``len(buf)``.

        Clients should resume from that point on next call to ``write``, ie
        ``buf[bytes_written_in_last_call:]``.

        .. note::
          While this function handles unicode strings for ``buf``
          argument, ``bytes_written`` offset will always be for the *bytes*
          representation thereof as returned by the C function calls which only
          handle byte strings.

        :param buf: Buffer to write
        :type buf: str

        :rtype: tuple(int, int)
        """
        cdef bytes b_buf = to_bytes(buf)
        cdef const char *_buf = b_buf
        cdef size_t buf_remainder = len(b_buf)
        cdef size_t buf_tot_size = buf_remainder
        cdef ssize_t rc
        cdef size_t bytes_written = 0
        with nogil:
            while buf_remainder > 0:
                rc = c_ssh2.libssh2_channel_write(
                    self._channel, _buf, buf_remainder)
                if rc < 0 and rc != c_ssh2.LIBSSH2_ERROR_EAGAIN:
                    # Error that will raise exception
                    with gil:
                        return handle_error_codes(rc)
                elif rc == c_ssh2.LIBSSH2_ERROR_EAGAIN:
                    break
                _buf += rc
                buf_remainder -= rc
            bytes_written = buf_tot_size - buf_remainder
        return rc, bytes_written

    def write_ex(self, int stream_id, buf not None):
        """Write buffer to specified stream id.

        Returns tuple of (``return_code``, ``bytes_written``).

        In blocking mode ``bytes_written`` will always equal ``len(buf)`` if no
        errors have occurred which would raise exception.

        In non-blocking mode ``return_code`` can be LIBSSH2_ERROR_EAGAIN and
        ``bytes_written`` *can be less than* ``len(buf)``.

        Clients should resume from that point on next call to the function, ie
        ``buf[bytes_written_in_last_call:]``.

        .. note::
          While this function handles unicode strings for ``buf``
          argument, ``bytes_written`` offset will always be for the *bytes*
          representation thereof as returned by the C function calls which only
          handle byte strings.

        :param stream_id: Id of stream to write to
        :type stream_id: int
        :param buf: Buffer to write
        :type buf: str

        :rtype: tuple(int, int)
        """
        cdef bytes b_buf = to_bytes(buf)
        cdef const char *_buf = b_buf
        cdef size_t buf_remainder = len(b_buf)
        cdef size_t buf_tot_size = buf_remainder
        cdef ssize_t rc
        cdef size_t bytes_written = 0
        with nogil:
            # Write until buffer has been fully written or socket is blocked
            while buf_remainder > 0:
                rc = c_ssh2.libssh2_channel_write_ex(
                    self._channel, stream_id, _buf, buf_remainder)
                if rc < 0 and rc != c_ssh2.LIBSSH2_ERROR_EAGAIN:
                    # Error that will raise exception
                    with gil:
                        return handle_error_codes(rc)
                elif rc == c_ssh2.LIBSSH2_ERROR_EAGAIN:
                    break
                _buf += rc
                buf_remainder -= rc
            bytes_written = buf_tot_size - buf_remainder
        return rc, bytes_written

    def write_stderr(self, buf not None):
        """Write buffer to stderr.

        Returns tuple of (``return_code``, ``bytes_written``).

        In blocking mode ``bytes_written`` will always equal ``len(buf)`` if no
        errors have occurred which would raise exception.

        In non-blocking mode ``return_code`` can be LIBSSH2_ERROR_EAGAIN and
        ``bytes_written`` *can be less than* ``len(buf)``.

        Clients should resume from that point on next call to ``write``, ie
        ``buf[bytes_written_in_last_call:]``.

        .. note::
          While this function handles unicode strings for ``buf``
          argument, ``bytes_written`` offset will always be for the *bytes*
          representation thereof as returned by the C function calls which only
          handle byte strings.

        :param buf: Buffer to write
        :type buf: str

        :rtype: tuple(int, int)
        """
        cdef bytes b_buf = to_bytes(buf)
        cdef const char *_buf = b_buf
        cdef size_t buf_remainder = len(b_buf)
        cdef size_t buf_tot_size = buf_remainder
        cdef ssize_t rc
        cdef size_t bytes_written = 0
        with nogil:
            while buf_remainder > 0:
                rc = c_ssh2.libssh2_channel_write_stderr(
                    self._channel, _buf, buf_remainder)
                if rc < 0 and rc != c_ssh2.LIBSSH2_ERROR_EAGAIN:
                    # Error that will raise exception
                    with gil:
                        return handle_error_codes(rc)
                elif rc == c_ssh2.LIBSSH2_ERROR_EAGAIN:
                    break
                _buf += rc
                buf_remainder -= rc
            bytes_written = buf_tot_size - buf_remainder
        return rc, bytes_written

    def x11_req(self, int screen_number):
        cdef int rc
        with nogil:
            rc = c_ssh2.libssh2_channel_x11_req(
                self._channel, screen_number)
        return handle_error_codes(rc)

    def x11_req_ex(self, int single_connection,
                   const char *auth_proto,
                   const char *auth_cookie,
                   int screen_number):
        cdef int rc
        with nogil:
            rc = c_ssh2.libssh2_channel_x11_req_ex(
                self._channel, single_connection,
                auth_proto, auth_cookie, screen_number)
        return handle_error_codes(rc)

    def process_startup(self, request, message=None):
        """Startup process on server for request with message.

        Request is a supported SSH subsystem and clients would typically use
        one of execute/shell/subsystem functions depending on request type.

        :param request: Request type (exec/shell/subsystem).
        :type request: str
        :param message: Request message. Content depends on request type
          and can be ``None``.
        :type message: str or ``None``
        """
        cdef bytes b_request = to_bytes(request)
        cdef bytes b_message = None
        cdef char *_request = b_request
        cdef char *_message = NULL
        cdef size_t r_len = len(b_request)
        cdef size_t m_len = 0
        if message is not None:
            b_message = to_bytes(message)
            _message = b_message
            m_len = len(b_message)
        cdef int rc
        with nogil:
            rc = c_ssh2.libssh2_channel_process_startup(
                self._channel, _request, r_len, _message, m_len)
        return handle_error_codes(rc)

    def poll_channel_read(self, int extended):
        """Deprecated - use session.block_directions and socket polling
        instead"""
        cdef int rc
        with nogil:
            rc = c_ssh2.libssh2_poll_channel_read(self._channel, extended)
        return handle_error_codes(rc)

    def handle_extended_data(self, int ignore_mode):
        """Deprecated, use handle_extended_data2"""
        with nogil:
            c_ssh2.libssh2_channel_handle_extended_data(
                self._channel, ignore_mode)

    def handle_extended_data2(self, int ignore_mode):
        cdef int rc
        with nogil:
            rc = c_ssh2.libssh2_channel_handle_extended_data2(
                self._channel, ignore_mode)
        return handle_error_codes(rc)

    def ignore_extended_data(self, int ignore_mode):
        """Deprecated, use handle_extended_data2"""
        with nogil:
            c_ssh2.libssh2_channel_handle_extended_data(
                self._channel, ignore_mode)

    IF HAVE_AGENT_FWD:
        def request_auth_agent(self):
            """Request SSH agent authentication forwarding on channel."""
            cdef int rc
            with nogil:
                rc = c_ssh2.libssh2_channel_request_auth_agent(self._channel)
            return handle_error_codes(rc)
