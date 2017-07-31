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

cimport c_ssh2
cimport sftp
cimport error_codes

from session cimport Session
from exceptions cimport ChannelError
# from utils cimport to_bytes


cdef object PyChannel(c_ssh2.LIBSSH2_CHANNEL *channel, Session session):
    cdef Channel _channel = Channel(session)
    _channel._channel = channel
    return _channel


cdef class Channel:

    def __cinit__(self, Session session):
        self._channel = NULL
        self._session = session

    def __dealloc__(self):
        with nogil:
            c_ssh2.libssh2_channel_free(self._channel)

    def pty(self, term="vt100"):
        cdef const char *_term = term
        cdef int rc
        with nogil:
            rc = c_ssh2.libssh2_channel_request_pty(
                self._channel, _term)
            if rc != 0 and rc != c_ssh2._LIBSSH2_ERROR_EAGAIN:
                with gil:
                    raise ChannelError(
                        "Error requesting PTY with error code %s",
                        rc)
        return rc

    def execute(self, const char *command):
        cdef int rc
        with nogil:
            rc = c_ssh2.libssh2_channel_exec(
                self._channel, command)
            if rc != 0 and rc != c_ssh2._LIBSSH2_ERROR_EAGAIN:
                with gil:
                    raise ChannelError(
                        "Error executing command %s - error code %s",
                        command, rc)
        return rc

    def subsystem(self, const char *subsystem):
        """Request subsystem from channel

        :param subsystem: Name of subsystem
        :type subsystem: str"""
        cdef int rc
        with nogil:
            rc = c_ssh2.libssh2_channel_subsystem(
                self._channel, subsystem)
            if rc != 0 and rc != c_ssh2._LIBSSH2_ERROR_EAGAIN:
                with gil:
                    raise ChannelError(
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
            rc = c_ssh2.libssh2_channel_read_ex(
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
        return self.read_ex(size=size, stream_id=c_ssh2._SSH_EXTENDED_DATA_STDERR)

    def eof(self):
        """Get channel EOF status

        :rtype: bool"""
        cdef int rc
        with nogil:
            rc = c_ssh2.libssh2_channel_eof(self._channel)
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
            rc = c_ssh2.libssh2_channel_send_eof(self._channel)
        return rc

    def wait_eof(self):
        """Wait for the remote end to acknowledge an EOF request

        Return 0 on success or negative on failure. It returns
        LIBSSH2_ERROR_EAGAIN when it would otherwise block

        :rtype: int
        """
        cdef int rc
        with nogil:
            rc = c_ssh2.libssh2_channel_wait_eof(self._channel)
        return rc

    def close(self):
        cdef int rc
        with nogil:
            rc = c_ssh2.libssh2_channel_close(self._channel)
        return rc

    def flush(self):
        """Flush stdout stream"""
        cdef int rc
        with nogil:
            rc = c_ssh2.libssh2_channel_flush(self._channel)
        return rc

    def flush_ex(self, int stream_id):
        """Flush stream with id"""
        cdef int rc
        with nogil:
            rc = c_ssh2.libssh2_channel_flush_ex(self._channel, stream_id)
        return rc

    def flush_stderr(self):
        """Flush stderr stream"""
        cdef int rc
        with nogil:
            rc = c_ssh2.libssh2_channel_flush_stderr(self._channel)
        return rc

    def wait_closed(self):
        cdef int rc
        with nogil:
            rc = c_ssh2.libssh2_channel_wait_closed(self._channel)
        return rc

    def get_exit_status(self):
        cdef int rc
        with nogil:
            rc = c_ssh2.libssh2_channel_get_exit_status(self._channel)
        return rc

    def get_exit_signal(self):
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
        return rc, py_exitsignal, py_errmsg, py_langtag

    def setenv(self, const char *varname, const char *value):
        cdef int rc
        with nogil:
            rc = c_ssh2.libssh2_channel_setenv(
                self._channel, varname, value)
        return rc

    def window_read_ex(self, unsigned long read_avail,
                       unsigned long window_size_initial):
        cdef unsigned long rc
        with nogil:
            rc = c_ssh2.libssh2_channel_window_read_ex(
                self._channel, &read_avail, &window_size_initial)
        return rc

    def window_read(self):
        cdef unsigned long rc
        with nogil:
            rc = c_ssh2.libssh2_channel_window_read(self._channel)
        return rc

    def window_write_ex(self, unsigned long window_size_initial):
        cdef unsigned long rc
        with nogil:
            rc = c_ssh2.libssh2_channel_window_write_ex(
                self._channel, &window_size_initial)
        return rc

    def window_write(self):
        cdef unsigned long rc
        with nogil:
            rc = c_ssh2.libssh2_channel_window_write(self._channel)
        return rc

    def write(self, bytes buf):
        """Write buffer to stdin"""
        cdef const char *_buf = buf
        cdef size_t buflen = len(buf)
        cdef ssize_t rc
        with nogil:
            rc = c_ssh2.libssh2_channel_write(self._channel, _buf, buflen)
        return rc

    def write_ex(self, int stream_id, bytes buf):
        """Write buffer to specified stream id"""
        cdef const char *_buf = buf
        cdef size_t buflen = len(buf)
        cdef ssize_t rc
        with nogil:
            rc = c_ssh2.libssh2_channel_write_ex(
                self._channel, stream_id, _buf, buflen)
        return rc

    def write_stderr(self, bytes buf):
        """Write buffer to stderr"""
        cdef const char *_buf = buf
        cdef size_t buflen = len(buf)
        cdef ssize_t rc
        with nogil:
            rc = c_ssh2.libssh2_channel_write_stderr(
                self._channel, _buf, buflen)
        return rc

    def x11_req(self):
        raise NotImplementedError

    def x11_req_ex(self):
        raise NotImplementedError
