import os
import socket
from unittest import skipUnless

from .base_test import SSH2TestCase
from ssh2.session import Session, LIBSSH2_HOSTKEY_HASH_MD5, \
    LIBSSH2_HOSTKEY_HASH_SHA1
# from ssh2.sftp import SFTP
from ssh2.agent import Agent
# from ssh2.error_codes import LIBSSH2_ERROR_EAGAIN
from ssh2.exceptions import AuthenticationError, AgentAuthenticationError, \
    SCPProtocolError, RequestDeniedError, InvalidRequestError, \
    SocketSendError, FileError, PublickeyUnverifiedError
from ssh2.utils import wait_socket


class SessionTestCase(SSH2TestCase):

    def test_agent_pyobject(self):
        agent = Agent(self.session)
        self.assertIsInstance(agent, Agent)

    def test_agent_get_identities(self):
        agent = Agent(self.session)
        agent.connect()
        ids = agent.get_identities()
        self.assertIsInstance(ids, list)
        agent.disconnect()

    def test_agent_id_path(self):
        agent = Agent(self.session)
        agent.connect()
        _path = b'my_path'
        agent.set_identity_path(_path)
        path = agent.get_identity_path()
        self.assertEqual(_path, path)
        agent.disconnect()
