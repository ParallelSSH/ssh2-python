import os
from unittest import skipUnless

from .base_test import SSH2TestCase
from ssh2.session import Session, LIBSSH2_HOSTKEY_HASH_MD5, \
    LIBSSH2_HOSTKEY_HASH_SHA1
from ssh2.sftp import SFTP
from ssh2.channel import Channel
from ssh2.error_codes import LIBSSH2_ERROR_EAGAIN
from ssh2.exceptions import AuthenticationError, AgentAuthenticationError, \
    SCPProtocolError, RequestDeniedError, InvalidRequestError, SocketSendError
from ssh2.utils import wait_socket


class SessionTestCase(SSH2TestCase):

    def test_fromfile_auth(self):
        self.assertEqual(self._auth(), 0)
        self.assertTrue(self.session.userauth_authenticated())

    def test_get_auth_list(self):
        auth_list = sorted(self.session.userauth_list(self.user))
        expected = sorted(['publickey', 'password', 'keyboard-interactive'])
        self.assertListEqual(auth_list, expected)

    def test_direct_tcpip(self):
        self.assertEqual(self._auth(), 0)
        chan = self.session.direct_tcpip(self.host, self.port)
        self.assertTrue(chan is not None)

    def test_agent(self):
        agent = self.session.agent_init()
        self.assertTrue(agent.connect() == 0)

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

    def test_failed_agent_auth(self):
        self.assertRaises(AgentAuthenticationError,
                          self.session.agent_auth, 'FAKE USER')

    def test_failed_pkey_auth(self):
        self.assertRaises(AuthenticationError,
                          self.session.userauth_publickey_fromfile,
                          'FAKE USER', self.user_pub_key, self.user_key,
                          '')
        self.assertRaises(AuthenticationError,
                          self.session.userauth_publickey_fromfile,
                          self.user, 'FAKE FILE', 'EVEN MORE FAKE FILE',
                          '')

    @skipUnless(hasattr(Session, 'scp_recv2'),
                "Function not supported by libssh2")
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
        self.assertRaises(SCPProtocolError, self.session.scp_recv2, remote_filename)

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
        self.assertRaises(SCPProtocolError, self.session.scp_recv, remote_filename)

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
            try:
                os.unlink(to_copy)
            except OSError:
                pass
        self.assertRaises(SCPProtocolError, self.session.scp_send,
                          '/cannot_write', 1 & 777, 1)

    @skipUnless(hasattr(Session, 'scp_send64'),
                "Function not supported by libssh2")
    def test_scp_send64(self):
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
            chan = self.session.scp_send64(
                to_copy, fileinfo.st_mode & 777, fileinfo.st_size,
                fileinfo.st_mtime, fileinfo.st_atime)
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
            try:
                os.unlink(to_copy)
            except OSError:
                pass
        self.assertRaises(SCPProtocolError, self.session.scp_send64,
                          '/cannot_write', 0 & 777, 1, 1, 1)

    def test_non_blocking(self):
        self.assertEqual(self._auth(), 0)
        self.session.set_blocking(False)
        self.assertFalse(self.session.get_blocking())
        sftp = self.session.sftp_init()
        while sftp == LIBSSH2_ERROR_EAGAIN:
            wait_socket(self.sock, self.session)
            sftp = self.session.sftp_init()
        self.assertIsNotNone(sftp)
        self.assertIsInstance(sftp, SFTP)
        chan = self.session.open_session()
        while chan == LIBSSH2_ERROR_EAGAIN:
            wait_socket(self.sock, self.session)
            chan = self.session.open_session()
        self.assertIsInstance(chan, Channel)

    def test_hostkey(self):
        self.assertEqual(self._auth(), 0)
        for _type in [LIBSSH2_HOSTKEY_HASH_MD5, LIBSSH2_HOSTKEY_HASH_SHA1]:
            hostkey = self.session.hostkey_hash(_type)
            self.assertTrue(len(hostkey) > 0)

    def test_forward_listen_failure(self):
        self.assertEqual(self._auth(), 0)
        self.assertRaises(RequestDeniedError, self.session.forward_listen, 80)

    def test_sftp_init_failure(self):
        self.assertRaises(InvalidRequestError, self.session.sftp_init)

    def test_open_channel_failure(self):
        self.sock.close()
        self.assertRaises(SocketSendError, self.session.open_session)

    def test_direct_tcpip_failure(self):
        self.sock.close()
        self.assertRaises(SocketSendError, self.session.direct_tcpip,
                          'localhost', 80)
