import os
import platform
import shutil
import stat
from sys import version_info
from unittest import skipUnless

from ssh2.error_codes import LIBSSH2_ERROR_EAGAIN
from ssh2.exceptions import SFTPProtocolError, BufferTooSmallError
from ssh2.session import Session
from ssh2.sftp import LIBSSH2_FXF_CREAT, LIBSSH2_FXF_WRITE, \
    LIBSSH2_SFTP_S_IRUSR, LIBSSH2_SFTP_S_IRGRP, LIBSSH2_SFTP_S_IROTH, LIBSSH2_SFTP_S_IXUSR, SFTP, \
    LIBSSH2_SFTP_S_IWUSR, LIBSSH2_SFTP_S_IWGRP, LIBSSH2_SFTP_S_IWOTH, \
    LIBSSH2_SFTP_ATTR_PERMISSIONS
from ssh2.sftp_handle import SFTPHandle, SFTPAttributes
from ssh2.utils import wait_socket

from .base_test import SSH2TestCase


class SFTPTestCase(SSH2TestCase):

    def test_init(self):
        self.assertEqual(self._auth(), 0)
        sftp = self.session.sftp_init()
        self.assertIsInstance(sftp, SFTP)
        self.assertIsInstance(sftp.session, Session)
        self.assertEqual(sftp.session, self.session)

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
                for rc, data in remote_fh:
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

    def test_sftp_stat(self):
        self.assertEqual(self._auth(), 0)
        sftp = self.session.sftp_init()
        self.assertTrue(sftp is not None)
        test_data = b"data"
        remote_filename = os.sep.join([os.path.dirname(__file__),
                                       "remote_test_file"])
        with open(remote_filename, 'wb') as fh:
            fh.write(test_data)
        _mask = 0o644
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
        self.assertRaises(SFTPProtocolError, sftp.stat, remote_filename)
        self.assertNotEqual(sftp.last_error(), 0)

    def test_sftp_fstat(self):
        self.assertEqual(self._auth(), 0)
        sftp = self.session.sftp_init()
        self.assertTrue(sftp is not None)
        test_data = b"data"
        remote_filename = os.sep.join([os.path.dirname(__file__),
                                       "remote_test_file"])
        with open(remote_filename, 'wb') as fh:
            fh.write(test_data)
        try:
            with sftp.open(remote_filename, 0, 0) as fh:
                attrs = fh.fstat()
                self.assertTrue(isinstance(attrs, SFTPAttributes))
                self.assertEqual(attrs.uid, os.getuid())
                self.assertEqual(attrs.gid, os.getgid())
                self.assertTrue(attrs.flags > 0)
        except Exception:
            raise
        finally:
            os.unlink(remote_filename)

    def test_sftp_setstat(self):
        self.assertEqual(self._auth(), 0)
        sftp = self.session.sftp_init()
        self.assertTrue(sftp is not None)
        test_data = b"data"
        remote_filename = os.sep.join([os.path.dirname(__file__),
                                       "remote_test_file"])
        rdonly_perms = LIBSSH2_SFTP_S_IRUSR |  LIBSSH2_SFTP_S_IRGRP | \
            LIBSSH2_SFTP_S_IROTH
        rw_perms = LIBSSH2_SFTP_S_IRUSR |  LIBSSH2_SFTP_S_IRGRP | \
            LIBSSH2_SFTP_S_IROTH | LIBSSH2_SFTP_S_IWUSR |  \
            LIBSSH2_SFTP_S_IWGRP | LIBSSH2_SFTP_S_IWOTH
        with open(remote_filename, 'wb') as fh:
            fh.write(test_data)
        _mask = 0o666
        os.chmod(remote_filename, _mask)
        attrs = sftp.stat(remote_filename)
        attrs.permissions = LIBSSH2_SFTP_S_IRUSR
        attrs.flags = LIBSSH2_SFTP_ATTR_PERMISSIONS
        try:
            self.assertEqual(sftp.setstat(remote_filename, attrs), 0)
            attrs = sftp.stat(remote_filename)
            expected = '0100400L' if version_info.major <= 2 else '0o100400'
            self.assertEqual(oct(attrs.permissions), expected)
            attrs.permissions = rdonly_perms
            attrs.flags = LIBSSH2_SFTP_ATTR_PERMISSIONS
            self.assertEqual(sftp.setstat(remote_filename, attrs), 0)
            attrs = sftp.stat(remote_filename)
            expected = '0100444L' if version_info.major <= 2 else '0o100444'
            self.assertEqual(oct(attrs.permissions), expected)
            attrs.permissions = rw_perms
            attrs.flags = LIBSSH2_SFTP_ATTR_PERMISSIONS
            self.assertEqual(sftp.setstat(remote_filename, attrs), 0)
            attrs = sftp.stat(remote_filename)
            expected = '0100666L' if version_info.major <= 2 else '0o100666'
            self.assertEqual(oct(attrs.permissions), expected)
        except Exception:
            raise
        finally:
            os.unlink(remote_filename)

    def test_realpath_failure(self):
        self.assertEqual(self._auth(), 0)
        sftp = self.session.sftp_init()
        self.assertTrue(sftp is not None)
        self.assertRaises(
            BufferTooSmallError, sftp.realpath, '/', max_len=0)

    def test_realpath(self):
        self.assertEqual(self._auth(), 0)
        sftp = self.session.sftp_init()
        self.assertTrue(sftp is not None)
        self.assertIsNotNone(sftp.realpath('.'))

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

    def test_readdir(self):
        self.assertEqual(self._auth(), 0)
        sftp = self.session.sftp_init()
        with sftp.opendir('.') as fh:
            dir_data = list(fh.readdir())
        self.assertTrue(len(dir_data) > 0)
        self.assertTrue(b'..' in (_ls for (_, _ls, _) in dir_data))

    def test_readdir_ex(self):
        self.assertEqual(self._auth(), 0)
        sftp = self.session.sftp_init()
        with sftp.opendir('.') as fh:
            dir_data = list(fh.readdir_ex())
        self.assertTrue(len(dir_data) > 0)
        self.assertTrue(b'..' in (_ls for (_, _ls, _, _) in dir_data))
        self.assertTrue(len(dir_data[0][2].split(b' ')) > 0)

    def test_readdir_failure(self):
        self.assertEqual(self._auth(), 0)
        sftp = self.session.sftp_init()
        self.assertRaises(SFTPProtocolError, sftp.opendir, 'fakeyfakey')

    @skipUnless(hasattr(SFTPHandle, 'fsync'),
                "Function not supported by libssh2")
    def test_fsync(self):
        self.assertEqual(self._auth(), 0)
        sftp = self.session.sftp_init()
        test_data = b"data"
        remote_filename = os.sep.join([os.path.dirname(__file__),
                                       "remote_test_file"])
        with open(remote_filename, 'wb') as fh:
            fh.write(test_data)
        try:
            with sftp.open(remote_filename, 0, 0) as fh:
                self.assertEqual(fh.fsync(), 0)
        except Exception:
            raise
        finally:
            os.unlink(remote_filename)

    def test_statvfs(self):
        self.assertEqual(self._auth(), 0)
        sftp = self.session.sftp_init()
        vfs = sftp.statvfs('.')
        self.assertTrue(vfs is not None)
        self.assertTrue(vfs.f_files >= 0)
        self.assertTrue(vfs.f_bsize > 0)
        self.assertTrue(vfs.f_namemax > 0)

    def test_fstatvfs(self):
        self.assertEqual(self._auth(), 0)
        sftp = self.session.sftp_init()
        test_data = b"data"
        remote_filename = os.sep.join([os.path.dirname(__file__),
                                       "remote_test_file"])
        with open(remote_filename, 'wb') as fh:
            fh.write(test_data)
        try:
            with sftp.open(remote_filename, 0, 0) as fh:
                vfs = fh.fstatvfs()
                self.assertTrue(vfs is not None)
                self.assertTrue(vfs.f_files >= 0)
                self.assertTrue(vfs.f_bsize > 0)
                self.assertTrue(vfs.f_namemax > 0)
        except Exception:
            raise
        finally:
            os.unlink(remote_filename)

    def test_readdir_nonblocking(self):
        self.assertEqual(self._auth(), 0)
        sftp = self.session.sftp_init()
        with sftp.opendir('.') as fh:
            self.session.set_blocking(False)
            dir_data = []
            for size, buf, attrs in fh.readdir():
                if size == LIBSSH2_ERROR_EAGAIN:
                    wait_socket(self.sock, self.session)
                    continue
                dir_data.append(buf)
        self.assertTrue(len(dir_data) > 0)
        self.assertTrue(b'..' in dir_data)

    def test_mkdir(self):
        mode = LIBSSH2_SFTP_S_IRUSR | \
            LIBSSH2_SFTP_S_IWUSR | \
            LIBSSH2_SFTP_S_IRGRP | \
            LIBSSH2_SFTP_S_IROTH | \
            LIBSSH2_SFTP_S_IXUSR
        _path = 'tmp'
        abspath = os.path.join(os.path.expanduser('~'), _path)
        self._auth()
        sftp = self.session.sftp_init()
        try:
            shutil.rmtree(abspath)
        except OSError:
            pass
        sftp.mkdir(_path, mode)
        try:
            self.assertTrue(os.path.isdir(abspath))
        finally:
            shutil.rmtree(abspath)

    def test_handle_open_nonblocking(self):
        self._auth()
        sftp = self.session.sftp_init()
        self.session.set_blocking(False)
        try:
            fh = sftp.open('fakey fake fake', 0, 0)
            while fh == LIBSSH2_ERROR_EAGAIN:
                wait_socket(self.sock, self.session)
                fh = sftp.open('fakey fake fake', 0, 0)
        except SFTPProtocolError:
            pass
        else:
            raise Exception("Should have raised SFTPProtocolError")
