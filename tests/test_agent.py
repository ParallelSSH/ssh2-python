from ssh2.agent import Agent
from ssh2.session import Session

from .base_test import SSH2TestCase


class SessionTestCase(SSH2TestCase):

    def test_agent(self):
        session = Session()
        agent = Agent(session)
        self.assertIsInstance(agent, Agent)
