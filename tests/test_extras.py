from unittest import TestCase
from unittest.mock import MagicMock

from ssh2.error_codes import LIBSSH2_ERROR_EAGAIN
from ssh2.exceptions import SSH2Error
from ssh2.extras import eagain_errcode, eagain_write_errcode


class ExtrasTest(TestCase):

    def test_eagain_no_args(self):
        poller = MagicMock()
        my_func = MagicMock()
        my_func.side_effect = [LIBSSH2_ERROR_EAGAIN, 1]
        eagain_errcode(my_func, poller)
        poller.assert_called_once()

    def test_eagain_no_args_no_call(self):
        poller = MagicMock()
        my_func = MagicMock()
        my_func.return_value = 1
        eagain_errcode(my_func, poller)
        poller.assert_not_called()

    def test_eagain_with_args(self):
        poller = MagicMock()
        my_func = MagicMock()
        args = ('arg1', 'arg2')
        kwargs = {'kwarg1': "value", 'kwarg2': "other value"}
        expected_rc = 99
        my_func.side_effect = [LIBSSH2_ERROR_EAGAIN, expected_rc]
        rc = eagain_errcode(my_func, poller, *args, **kwargs)
        poller.assert_called_once()
        self.assertEqual(rc, expected_rc)
        my_func.assert_called_with(*args, **kwargs)

    def test_eagain_write(self):
        some_data = b'some data'
        my_write_func = MagicMock()
        offset = 1
        my_write_func.side_effect = [
            (LIBSSH2_ERROR_EAGAIN, offset),
            (0, len(some_data) - offset),
        ]
        poller = MagicMock()
        self.assertIsNone(eagain_write_errcode(my_write_func, poller, some_data))
        poller.assert_called_once()
        self.assertEqual(my_write_func.call_count, 2)
        my_write_func.assert_called_with(some_data[offset:])

    def test_eagain_write_no_call(self):
        some_data = b'some data'
        my_write_func = MagicMock()
        my_write_func.side_effect = [
            (len(some_data), len(some_data)),
        ]
        poller = MagicMock()
        self.assertIsNone(eagain_write_errcode(my_write_func, poller, some_data))
        poller.assert_not_called()

        self.assertEqual(my_write_func.call_count, 1)
        my_write_func.assert_called_once_with(some_data)

    def test_eagain_read_error(self):
        poller = MagicMock()
        my_func = MagicMock()
        my_func.side_effect = [LIBSSH2_ERROR_EAGAIN, SSH2Error]
        self.assertRaises(SSH2Error, eagain_errcode, my_func, poller)
        poller.assert_called_once()

    def test_eagain_write_error(self):
        my_write_func = MagicMock()
        my_write_func.side_effect = [
            (LIBSSH2_ERROR_EAGAIN, 1),
            SSH2Error,
        ]
        poller = MagicMock()
        self.assertRaises(SSH2Error, eagain_write_errcode, my_write_func, poller, b"data")
        poller.assert_called_once()
        self.assertEqual(my_write_func.call_count, 2)
