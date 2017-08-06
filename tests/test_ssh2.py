import platform
import unittest
import pwd
import os
import socket
import time
from sys import version_info
import stat

from ssh2.exceptions import SFTPHandleError, SFTPBufferTooSmall
from ssh2.session import Session
from ssh2.utils import wait_socket
from ssh2.sftp import SFTPAttributes, LIBSSH2_FXF_CREAT, LIBSSH2_FXF_WRITE, \
    LIBSSH2_SFTP_S_IRUSR, LIBSSH2_SFTP_S_IRGRP, LIBSSH2_SFTP_S_IWUSR, \
    LIBSSH2_SFTP_S_IROTH
from embedded_server.openssh import OpenSSHServer


PKEY_FILENAME = os.path.sep.join([os.path.dirname(__file__), 'unit_test_key'])
PUB_FILE = "%s.pub" % (PKEY_FILENAME,)


class SSH2TestCase(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        _mask = int('0600') if version_info <= (2,) else 0o600
        os.chmod(PKEY_FILENAME, _mask)
        cls.host = '127.0.0.1'
        cls.port = 2222
        cls.server = OpenSSHServer()
        cls.server.start_server()

    def setUp(self):
        self.cmd = 'echo me'
        self.resp = u'me'
        self.user_key = PKEY_FILENAME
        self.user_pub_key = PUB_FILE
        self.user = pwd.getpwuid(os.geteuid()).pw_name
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.connect((self.host, self.port))
        self.sock = sock
        self.session = Session()
        self.session.handshake(self.sock)

    def tearDown(self):
        del self.session
        del self.sock

    def _auth(self):
        return self.session.userauth_publickey_fromfile(
            self.user, self.user_pub_key, self.user_key,
            '')

    def test_fromfile_auth(self):
        self.assertEqual(self._auth(), 0)
        self.assertTrue(self.session.userauth_authenticated())

    def test_get_auth_list(self):
        auth_list = sorted(self.session.userauth_list(self.user))
        expected = sorted(['publickey', 'password', 'keyboard-interactive'])
        self.assertListEqual(auth_list, expected)

    def test_agent(self):
        agent = self.session.agent_init()
        self.assertTrue(agent.connect() == 0)

    def test_execute(self):
        self.assertEqual(self._auth(), 0)
        chan = self.session.open_session()
        self.assertTrue(chan is not None)
        self.assertTrue(chan.execute(self.cmd) == 0)
        size, data = chan.read()
        lines = [s.decode('utf-8') for s in data.splitlines()]
        self.assertTrue(size > 0)
        self.assertTrue(lines, [self.resp])
        self.assertTrue(chan.close() == 0)
        self.assertTrue(chan.wait_eof() == 0)

    def test_exit_code(self):
        self.assertEqual(self._auth(), 0)
        chan = self.session.open_session()
        chan.execute('exit 2')
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
        lines = [s.decode('utf-8') for s in data.splitlines()]
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
        lines = [s.decode('utf-8') for s in data.splitlines()]
        self.assertListEqual(expected, lines)

    def test_write_stdin(self):
        self.assertEqual(self._auth(), 0)
        _in = u'writing to stdin'
        chan = self.session.open_session()
        chan.execute('cat')
        chan.write(_in + '\n')
        chan.close()
        chan.wait_closed()
        size, data = chan.read()
        self.assertTrue(size > 0)
        lines = [s.decode('utf-8') for s in data.splitlines()]
        self.assertListEqual([_in], lines)

    def test_write_ex(self):
        self.assertEqual(self._auth(), 0)
        _in = u'writing to stdin'
        chan = self.session.open_session()
        chan.execute('cat')
        chan.write_ex(0, _in + '\n')
        chan.close()
        chan.wait_closed()
        size, data = chan.read()
        self.assertTrue(size > 0)
        lines = [s.decode('utf-8') for s in data.splitlines()]
        self.assertListEqual([_in], lines)

    def test_write_stderr(self):
        self.assertEqual(self._auth(), 0)
        chan = self.session.open_session()
        chan.execute('echo something')
        _in = u'stderr'
        self.assertTrue(chan.write_stderr(_in + '\n') > 0)
        chan.close()
        chan.wait_closed()

    def test_sftp_read(self):
        self.assertEqual(self._auth(), 0)
        sftp = self.session.sftp_init()
        self.assertTrue(sftp is not None)
        if int(platform.python_version_tuple()[0]) >= 3:
            test_file_data = b'test' + bytes(os.linesep, 'utf-8')
        else:
            test_file_data = b'test' + os.linesep
        remote_filename = os.sep.join([os.path.dirname(__file__),
                                       'remote_test_file'])
        with open(remote_filename, 'wb') as test_fh:
            test_fh.write(test_file_data)
        with sftp.open(remote_filename, 0, 0) as remote_fh:
            try:
                self.assertTrue(remote_fh is not None)
                remote_data = b""
                for data in remote_fh:
                    remote_data += data
                self.assertEqual(remote_fh.close(), 0)
                self.assertEqual(remote_data, test_file_data)
            finally:
                os.unlink(remote_filename)

    def test_sftp_write(self):
        self.assertEqual(self._auth(), 0)
        sftp = self.session.sftp_init()
        self.assertTrue(sftp is not None)
        data = b"test file data"
        remote_filename = os.sep.join([os.path.dirname(__file__),
                                       "remote_test_file"])
        mode = LIBSSH2_SFTP_S_IRUSR | \
               LIBSSH2_SFTP_S_IWUSR | \
               LIBSSH2_SFTP_S_IRGRP | \
               LIBSSH2_SFTP_S_IROTH
        with sftp.open(remote_filename,
                       LIBSSH2_FXF_CREAT | LIBSSH2_FXF_WRITE,
                       mode) as remote_fh:
            remote_fh.write(data)
        with open(remote_filename, 'rb') as fh:
            written_data = fh.read()
        _stat = os.stat(remote_filename)
        try:
            self.assertTrue(stat.S_IMODE(_stat.st_mode) > 400)
            self.assertTrue(fh.closed)
            self.assertEqual(data, written_data)
        except Exception:
            raise
        finally:
            os.unlink(remote_filename)

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

    def test_sftp_attrs(self):
        attrs = SFTPAttributes()
        self.assertTrue(attrs is not None)
        del attrs
        self.assertEqual(self._auth(), 0)
        sftp = self.session.sftp_init()
        self.assertTrue(sftp is not None)
        test_data = b"data"
        remote_filename = os.sep.join([os.path.dirname(__file__),
                                       "remote_test_file"])
        with open(remote_filename, 'wb') as fh:
            fh.write(test_data)
        _mask = int('0644') if version_info <= (2,) else 0o644
        os.chmod(remote_filename, _mask)
        _size = os.stat(remote_filename).st_size
        try:
            attrs = sftp.stat(remote_filename)
            self.assertTrue(isinstance(attrs, SFTPAttributes))
            self.assertEqual(attrs.uid, os.getuid())
            self.assertEqual(attrs.gid, os.getgid())
            self.assertEqual(stat.S_IMODE(attrs.permissions), 420)
            self.assertTrue(attrs.atime > 0)
            self.assertTrue(attrs.mtime > 0)
            self.assertTrue(attrs.flags > 0)
            self.assertEqual(attrs.filesize, _size)
        except Exception:
            raise
        finally:
            os.unlink(remote_filename)
        self.assertRaises(SFTPHandleError, sftp.stat, remote_filename)
        self.assertNotEqual(sftp.last_error(), 0)

    def test_sftp_setstat(self):
        self.assertEqual(self._auth(), 0)
        sftp = self.session.sftp_init()
        self.assertTrue(sftp is not None)
        test_data = b"data"
        remote_filename = os.sep.join([os.path.dirname(__file__),
                                       "remote_test_file"])
        with open(remote_filename, 'wb') as fh:
            fh.write(test_data)
        _mask = int('0644') if version_info <= (2,) else 0o644
        os.chmod(remote_filename, _mask)
        attrs = sftp.stat(remote_filename)
        attrs.permissions = LIBSSH2_SFTP_S_IRUSR
        try:
            self.assertEqual(sftp.setstat(remote_filename, attrs), 0)
            attrs = sftp.stat(remote_filename)
            self.assertEqual(attrs.permissions, 33024)
        except Exception:
            raise
        finally:
            os.unlink(remote_filename)

    def test_realpath_failure(self):
        self.assertEqual(self._auth(), 0)
        sftp = self.session.sftp_init()
        self.assertTrue(sftp is not None)
        # Depends on library version which error is returned
        try:
            self.assertRaises(SFTPBufferTooSmall,
                              sftp.realpath, 'fake path', max_len=1)
        except SFTPHandleError:
            pass

    def test_sftp_symlink_realpath_lstat(self):
        self.assertEqual(self._auth(), 0)
        sftp = self.session.sftp_init()
        self.assertTrue(sftp is not None)
        test_data = b"data"
        remote_filename = os.sep.join([os.path.dirname(__file__),
                                       "remote_test_file"])
        with open(remote_filename, 'wb') as fh:
            fh.write(test_data)
        symlink_target = os.sep.join([os.path.dirname(__file__),
                                      'remote_symlink'])
        try:
            self.assertEqual(sftp.symlink(remote_filename, symlink_target), 0)
            lstat = sftp.lstat(symlink_target)
            self.assertTrue(lstat is not None)
            self.assertEqual(lstat.filesize, os.lstat(symlink_target).st_size)
            realpath = sftp.realpath(symlink_target)
            self.assertTrue(realpath is not None)
            self.assertEqual(realpath, remote_filename)
        except Exception:
            raise
        finally:
            os.unlink(symlink_target)
            os.unlink(remote_filename)

    @unittest.expectedFailure
    def test_scp_recv2(self):        
        self.assertEqual(self._auth(), 0)
        test_data = b"data"
        remote_filename = os.sep.join([os.path.dirname(__file__),
                                       "remote_test_file"])
        with open(remote_filename, 'wb') as fh:
            fh.write(test_data)
        try:
            (file_chan, fileinfo) = self.session.scp_recv2(remote_filename)
        except TypeError:
            os.unlink(remote_filename)
            raise
        try:
            total = 0
            size, data = file_chan.read(size=fileinfo.st_size)
            total += size
            while total < fileinfo.st_size:
                total += size
                size, data = file_chan.read()
            self.assertEqual(total, fileinfo.st_size)
        except Exception:
            raise
        finally:
            os.unlink(remote_filename)

    def test_scp_recv(self):
        self.assertEqual(self._auth(), 0)
        test_data = b"data"
        remote_filename = os.sep.join([os.path.dirname(__file__),
                                       "remote_test_file"])
        with open(remote_filename, 'wb') as fh:
            fh.write(test_data)
        try:
            (file_chan, fileinfo) = self.session.scp_recv(remote_filename)
        except TypeError:
            os.unlink(remote_filename)
            raise
        try:
            total = 0
            size, data = file_chan.read(size=fileinfo.st_size)
            total += size
            while total < fileinfo.st_size:
                total += size
                size, data = file_chan.read()
            self.assertEqual(total, fileinfo.st_size)
        except Exception:
            raise
        finally:
            os.unlink(remote_filename)

    def test_scp_send(self):
        self.assertEqual(self._auth(), 0)
        test_data = b"data"
        remote_filename = os.sep.join([os.path.dirname(__file__),
                                       "remote_test_file"])
        to_copy = os.sep.join([os.path.dirname(__file__),
                               "copied"])
        with open(remote_filename, 'wb') as fh:
            fh.write(test_data)
        fileinfo = os.stat(remote_filename)
        try:
            chan = self.session.scp_send(
                to_copy, fileinfo.st_mode & 777, fileinfo.st_size)
            with open(remote_filename, 'rb') as local_fh:
                for data in local_fh:
                    chan.write(data)
            chan.send_eof()
            chan.wait_eof()
            chan.wait_closed()
            self.assertEqual(os.stat(to_copy).st_size,
                             os.stat(remote_filename).st_size)
        except Exception:
            raise
        finally:
            os.unlink(remote_filename)
            os.unlink(to_copy)

    def test_session_get_set(self):
        self.assertEqual(self._auth(), 0)
        self.session.set_timeout(10)
        self.assertEqual(self.session.get_timeout(), 10)
        self.session.set_timeout(0)
        self.assertEqual(self.session.get_timeout(), 0)
        self.session.set_blocking(0)
        self.assertEqual(self.session.get_blocking(), 0)
        self.session.set_blocking(1)
        self.assertEqual(self.session.get_blocking(), 1)
