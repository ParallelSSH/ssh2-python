from .base_test import SSH2TestCase
from ssh2.agent import Agent


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
