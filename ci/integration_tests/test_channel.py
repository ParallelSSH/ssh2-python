import os
from subprocess import check_output
from unittest import skipUnless

from ssh2.channel import Channel
from ssh2.exceptions import SocketSendError
from ssh2.flags import FLAG_COMPRESS

from .base_test import SSH2TestCase


class ChannelTestCase(SSH2TestCase):

    def test_execute(self):
        self.assertEqual(self._auth(), 0)
        chan = self.session.open_session()
        self.assertTrue(chan is not None)
        self.assertTrue(chan.execute(self.cmd) == 0)
        size, data = chan.read()
        lines = [line.decode('utf-8') for line in data.splitlines()]
        self.assertTrue(size > 0)
        self.assertTrue(lines, [self.resp])
        self.assertEqual(chan.wait_eof(), 0)
        self.assertEqual(chan.wait_closed(), 0)

    def test_exit_code(self):
        self.assertEqual(self._auth(), 0)
        chan = self.session.open_session()
        chan.execute('exit 2')
        chan.send_eof()
        chan.wait_eof()
        chan.close()
        chan.wait_closed()
        exit_code = chan.get_exit_status()
        self.assertEqual(exit_code, 2)

    def test_long_running_execute(self):
        self.assertEqual(self._auth(), 0)
        chan = self.session.open_session()
        chan.execute('sleep 1; exit 3')
        self.assertTrue(chan.wait_eof() == 0)
        self.assertTrue(chan.close() == 0)
        self.assertTrue(chan.wait_closed() == 0)
        self.assertEqual(chan.get_exit_status(), 3)

    def test_read_stderr(self):
        self.assertEqual(self._auth(), 0)
        chan = self.session.open_session()
        expected = ['stderr output']
        chan.execute('echo "stderr output" >&2')
        size, data = chan.read_stderr()
        self.assertTrue(size > 0)
        lines = [line.decode('utf-8') for line in data.splitlines()]
        self.assertListEqual(expected, lines)

    def test_pty(self):
        self.assertEqual(self._auth(), 0)
        chan = self.session.open_session()
        self.assertTrue(chan.pty() == 0)
        _out = u'stderr output'
        expected = [_out]
        chan.execute(u'echo "%s" >&2' % (_out,))
        # stderr output gets redirected to stdout with a PTY
        size, data = chan.read()
        self.assertTrue(size > 0)
        lines = [line.decode('utf-8') for line in data.splitlines()]
        self.assertListEqual(expected, lines)

    def test_pty_failure(self):
        self.assertEqual(self._auth(), 0)
        chan = self.session.open_session()
        self.sock.close()
        self.assertRaises(SocketSendError, chan.pty)

    def test_write_stdin(self):
        self.assertEqual(self._auth(), 0)
        _in = u'writing to stdin'
        chan = self.session.open_session()
        chan.execute('cat')
        chan.write(_in + '\n')
        self.assertEqual(chan.send_eof(), 0)
        size, data = chan.read()
        self.assertTrue(size > 0)
        lines = [line.decode('utf-8') for line in data.splitlines()]
        self.assertListEqual([_in], lines)
        chan.close()
        self.assertEqual(chan.wait_eof(), 0)
        self.assertTrue(chan.eof())
        self.assertEqual(chan.wait_closed(), 0)

    def test_write_ex(self):
        self.assertEqual(self._auth(), 0)
        _in = u'writing to stdin'
        chan = self.session.open_session()
        chan.execute('cat')
        chan.write_ex(0, _in + '\n')
        self.assertEqual(chan.send_eof(), 0)
        size, data = chan.read()
        self.assertTrue(size > 0)
        lines = [line.decode('utf-8') for line in data.splitlines()]
        self.assertListEqual([_in], lines)

    def test_write_stderr(self):
        self.assertEqual(self._auth(), 0)
        chan = self.session.open_session()
        chan.execute('echo something')
        _in = u'stderr'
        self.assertTrue(chan.write_stderr(_in + '\n')[0] > 0)
        self.assertEqual(chan.close(), 0)

    def test_setenv(self):
        self.assertEqual(self._auth(), 0)
        chan = self.session.open_session()
        _var = 'LC_MY_VAR'
        _val = 'value'
        self.assertEqual(chan.setenv('LC_MY_VAR', _val), 0)
        chan.execute('env | grep LC_MY_VAR')
        expected = u'%s=%s\n' % (_var, _val)
        size, data = chan.read()
        self.assertTrue(size > 0)
        self.assertEqual(data.decode('utf-8'), expected)

    def test_shell(self):
        self.assertEqual(self._auth(), 0)
        chan = self.session.open_session()
        self.assertTrue(chan is not None)
        self.assertEqual(chan.shell(), 0)
        chan.write('echo me\n')
        size, data = chan.read()
        lines = [line.decode('utf-8') for line in data.splitlines()]
        self.assertTrue(size > 0)
        self.assertTrue(lines, [self.resp])
        self.assertTrue(chan.close() == 0)
        self.assertTrue(chan.wait_eof() == 0)

    def test_process_startup(self):
        self.assertEqual(self._auth(), 0)
        # Shell
        chan = self.session.open_session()
        self.assertTrue(chan is not None)
        self.assertEqual(chan.process_startup('shell'), 0)
        chan.write('echo me\n')
        size, data = chan.read()
        lines = [line.decode('utf-8') for line in data.splitlines()]
        self.assertTrue(size > 0)
        self.assertTrue(lines, [self.resp])
        self.assertTrue(chan.close() == 0)
        self.assertTrue(chan.wait_eof() == 0)
        # Exec
        chan = self.session.open_session()
        self.assertTrue(chan is not None)
        self.assertEqual(chan.process_startup('exec', self.cmd), 0)
        size, data = chan.read()
        lines = [line.decode('utf-8') for line in data.splitlines()]
        self.assertTrue(size > 0)
        self.assertTrue(lines, [self.resp])
        self.assertTrue(chan.close() == 0)
        self.assertTrue(chan.wait_eof() == 0)

    @skipUnless(hasattr(Channel, 'request_auth_agent'),
                "No agent forwarding implementation")
    def test_agent_forwarding(self):
        self.assertEqual(self._auth(), 0)
        chan = self.session.open_session()
        self.assertEqual(chan.request_auth_agent(), 0)

    def test_read_file(self):
        self._auth()
        abs_file = os.sep.join([
            os.path.dirname(__file__), '..', '..', 'setup.py',
        ])
        wc_output = check_output(['wc', '-l', abs_file]).split()[0]
        chan = self.session.open_session()
        cmd = 'cat %s' % (abs_file,)
        chan.execute(cmd)
        tot_data = b""
        size, data = chan.read()
        while size > 0:
            tot_data += data
            size, data = chan.read()
        lines = [line for line in tot_data.splitlines()]
        self.assertEqual(len(lines), int(wc_output))

    def test_multi_execute(self):
        self.assertEqual(self._auth(), 0)
        chan = self.session.open_session()
        self.assertTrue(chan is not None)
        self.assertTrue(chan.execute(self.cmd) == 0)
        size, data = chan.read()
        self.assertTrue(size > 0)
        self.assertEqual(chan.wait_eof(), 0)
        chan = self.session.open_session()
        self.assertTrue(chan is not None)
        self.assertTrue(chan.execute(self.cmd) == 0)
        size, data = chan.read()
        self.assertTrue(size > 0)

    def test_execute_with_session_compression(self):
        rc = self.session.flag(FLAG_COMPRESS)
        self.assertEqual(rc, 0)
        self.assertEqual(self._auth(), 0)
        chan = self.session.open_session()
        self.assertTrue(chan is not None)
        self.assertTrue(chan.execute(self.cmd) == 0)
        size, data = chan.read()
        lines = [line.decode('utf-8') for line in data.splitlines()]
        self.assertTrue(lines, [self.resp])
