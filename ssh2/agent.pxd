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

from session cimport Session
cimport c_ssh2


cdef object PyAgent(c_ssh2.LIBSSH2_AGENT *agent, Session session)


cdef class Agent:
    cdef c_ssh2.LIBSSH2_AGENT *_agent
    cdef Session _session


cdef int auth_identity(const char *username,
                       c_ssh2.LIBSSH2_AGENT *agent,
                       c_ssh2.libssh2_agent_publickey **identity,
                       c_ssh2.libssh2_agent_publickey *prev) nogil except -1

cdef void clear_agent(c_ssh2.LIBSSH2_AGENT *agent) nogil

cdef int agent_auth(char * _username,
                    c_ssh2.LIBSSH2_AGENT * agent) nogil except 1

cdef c_ssh2.LIBSSH2_AGENT * init_connect_agent(
    c_ssh2.LIBSSH2_SESSION *_session) nogil except NULL

cdef c_ssh2.LIBSSH2_AGENT * agent_init(
    c_ssh2.LIBSSH2_SESSION *_session) nogil except NULL
