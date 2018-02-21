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

from pkey cimport PublicKey, PyPublicKey
from utils cimport to_bytes

from .exceptions import AgentConnectionError, AgentListIdentitiesError, \
    AgentGetIdentityError, AgentAuthenticationError, AgentError

cimport c_ssh2


cdef int agent_auth(char * _username,
                    c_ssh2.LIBSSH2_AGENT * agent) nogil except 1:
    cdef c_ssh2.libssh2_agent_publickey *identity = NULL
    cdef c_ssh2.libssh2_agent_publickey *prev = NULL
    if c_ssh2.libssh2_agent_list_identities(agent) != 0:
        clear_agent(agent)
        with gil:
            raise AgentListIdentitiesError(
                "Failure requesting identities from agent")
    while 1:
        if auth_identity(_username, agent, &identity, prev) == 1:
            with gil:
                raise AgentAuthenticationError(
                    "No identities match for user %s",
                    _username)
        if c_ssh2.libssh2_agent_userauth(
                agent, _username, identity) == 0:
            clear_agent(agent)
            return 0
        prev = identity
    return 1


cdef int auth_identity(const char *username,
                       c_ssh2.LIBSSH2_AGENT *agent,
                       c_ssh2.libssh2_agent_publickey **identity,
                       c_ssh2.libssh2_agent_publickey *prev) nogil except -1:
    cdef int rc
    rc = c_ssh2.libssh2_agent_get_identity(
        agent, identity, prev)
    if rc == 1:
        clear_agent(agent)
    elif rc < 0:
        clear_agent(agent)
        with gil:
            raise AgentGetIdentityError(
                "Failure getting identity for user %s from agent",
                username)
    return rc


cdef c_ssh2.LIBSSH2_AGENT * agent_init(
        c_ssh2.LIBSSH2_SESSION *_session) nogil except NULL:
    cdef c_ssh2.LIBSSH2_AGENT *agent = c_ssh2.libssh2_agent_init(
        _session)
    if agent is NULL:
        with gil:
            raise AgentError("Error initialising agent")
    return agent


cdef c_ssh2.LIBSSH2_AGENT * init_connect_agent(
        c_ssh2.LIBSSH2_SESSION *_session) nogil except NULL:
    cdef c_ssh2.LIBSSH2_AGENT *agent
    agent = c_ssh2.libssh2_agent_init(_session)
    if c_ssh2.libssh2_agent_connect(agent) != 0:
        c_ssh2.libssh2_agent_free(agent)
        with gil:
            raise AgentConnectionError("Unable to connect to agent")
    return agent


cdef void clear_agent(c_ssh2.LIBSSH2_AGENT *agent) nogil:
    c_ssh2.libssh2_agent_disconnect(agent)
    c_ssh2.libssh2_agent_free(agent)


cdef object PyAgent(c_ssh2.LIBSSH2_AGENT *agent, Session session):
    cdef Agent _agent = Agent.__new__(Agent, session)
    _agent._agent = agent
    return _agent


cdef class Agent:

    def __cinit__(self, Session session):
        self._agent = NULL
        self._session = session

    def __dealloc__(self):
        with nogil:
            clear_agent(self._agent)

    def list_identities(self):
        """This method is a no-op - use
        :py:func:`ssh2.agent.Agent.get_identities()` to list and retrieve
        identities."""
        pass

    def get_identities(self):
        """List and get identities from agent

        :rtype: list(:py:class:`ssh2.pkey.PublicKey`)"""
        cdef int rc
        cdef list identities = []
        cdef c_ssh2.libssh2_agent_publickey *identity = NULL
        cdef c_ssh2.libssh2_agent_publickey *prev = NULL
        if c_ssh2.libssh2_agent_list_identities(self._agent) != 0:
            raise AgentListIdentitiesError(
                "Failure requesting identities from agent."
                "Agent must be connected first")
        while c_ssh2.libssh2_agent_get_identity(
                self._agent, &identity, prev) == 0:
            identities.append(PyPublicKey(identity))
            prev = identity
        return identities

    def userauth(self, username not None,
                 PublicKey pkey):
        """Perform user authentication with specific public key

        :param username: User name to authenticate as
        :type username: str
        :param pkey: Public key to authenticate with
        :type pkey: :py:class:`ssh2.pkey.PublicKey`

        :raises: :py:class:`ssh2.exceptions.AgentAuthenticationError` on errors
          authenticating.

        :rtype: int"""
        cdef int rc
        cdef bytes b_username = to_bytes(username)
        cdef char *_username = b_username
        with nogil:
            rc = c_ssh2.libssh2_agent_userauth(
                self._agent, _username, pkey._pkey)
            if rc != 0 and rc != c_ssh2.LIBSSH2_ERROR_EAGAIN:
                with gil:
                    raise AgentAuthenticationError(
                        "Error authenticating user %s with provided public key",
                        username)
        return rc

    def disconnect(self):
        """Disconnect from agent.

        :rtype: int"""
        cdef int rc
        with nogil:
            rc = c_ssh2.libssh2_agent_disconnect(self._agent)
        return rc

    def connect(self):
        """Connect to agent.

        :raises: :py:class:`ssh2.exceptions.AgentConnectionError` on errors
          connecting to agent.

        :rtype: int"""
        cdef int rc
        rc = c_ssh2.libssh2_agent_connect(self._agent)
        if rc != 0:
            raise AgentConnectionError("Unable to connect to agent")
        return rc
