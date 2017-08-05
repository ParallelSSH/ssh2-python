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

cimport error_codes
cimport c_ssh2


LIBSSH2_ERROR_NONE = error_codes._LIBSSH2_ERROR_NONE
LIBSSH2_ERROR_NONE = error_codes._LIBSSH2_ERROR_NONE
LIBSSH2CHANNEL_EAGAIN = error_codes._LIBSSH2CHANNEL_EAGAIN
LIBSSH2_ERROR_EAGAIN = error_codes._LIBSSH2_ERROR_EAGAIN
LIBSSH2_ERROR_AUTHENTICATION_FAILED = error_codes._LIBSSH2_ERROR_AUTHENTICATION_FAILED
LIBSSH2_ERROR_SOCKET_RECV = error_codes._LIBSSH2_ERROR_SOCKET_RECV
LIBSSH2_SESSION_BLOCK_INBOUND = c_ssh2._LIBSSH2_SESSION_BLOCK_INBOUND
LIBSSH2_SESSION_BLOCK_OUTBOUND = c_ssh2._LIBSSH2_SESSION_BLOCK_OUTBOUND
# LIBSSH2_CHANNEL_FLUSH_EXTENDED_DATA = c_ssh2._LIBSSH2_CHANNEL_FLUSH_EXTENDED_DATA
# LIBSSH2_CHANNEL_FLUSH_ALL = c_ssh2._LIBSSH2_CHANNEL_FLUSH_ALL
LIBSSH2_ERROR_TIMEOUT = error_codes._LIBSSH2_ERROR_TIMEOUT
LIBSSH2_ERROR_SOCKET_TIMEOUT = error_codes._LIBSSH2_ERROR_SOCKET_TIMEOUT
