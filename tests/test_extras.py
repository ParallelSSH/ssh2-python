from unittest import TestCase
from unittest.mock import MagicMock

from ssh2.error_codes import LIBSSH2_ERROR_EAGAIN
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
        rc = eagain_write_errcode(my_write_func, poller, some_data)
        poller.assert_called_once()
        self.assertIsNone(rc)
        self.assertEqual(my_write_func.call_count, 2)
        my_write_func.assert_called_with(some_data[offset:])
