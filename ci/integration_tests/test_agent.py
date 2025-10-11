#  This file is part of ssh2-python.
#  Copyright (C) 2017-2025 Panos Kittenis
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation, version 2.1.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

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
