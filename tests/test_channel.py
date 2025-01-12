from ssh2.channel import Channel
from ssh2.session import Session

from .base_test import SSH2TestCase


class ChannelTestCase(SSH2TestCase):

    def test_init(self):
        session = Session()
        chan = Channel(session)
        self.assertIsInstance(chan, Channel)
        self.assertEqual(chan.session, session)
