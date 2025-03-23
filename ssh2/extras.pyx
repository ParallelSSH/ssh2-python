"""
Additional functionality not part of the libssh2 API.
"""
from typing import Callable, Any

from . cimport error_codes
from .utils import find_eol


def eagain_errcode(func: Callable, poller_func: Callable, *args, **kwargs) -> Any:
    """Helper function for reading in non-blocking mode.

    Any additional arguments and keyword arguments provided are used as arguments to the session function `func`.
    `func` should return an integer return code.

    :param func: The session function to call to read data from.
    :param poller_func: A python function to handle socket polling that takes no arguments.

    :returns: Output of func.
    :rtype: int
    """
    ret = func(*args, **kwargs)
    while ret == error_codes._LIBSSH2_ERROR_EAGAIN:
        poller_func()
        ret = func(*args, **kwargs)
    return ret


def eagain_write_errcode(write_func: Callable, poller_func: Callable, bytes data: bytes) -> None:
    """Helper function for writing in non-blocking mode.

    Any additional arguments and keyword arguments provided are used as arguments to the session function `write_func`.
    `write_func` should return an integer tuple `(rc, bytes_written)` for return code and bytes written respectively.

    :param write_func: The session function to call to read data from.
    :param poller_func: A python function to handle socket polling that takes no arguments.
    :param data: The data to write.
    :type data: bytes
    """
    cdef size_t data_len = len(data)
    cdef size_t total_written = 0
    cdef rc
    cdef size_t bytes_written
    while total_written < data_len:
        rc, bytes_written = write_func(data[total_written:])
        total_written += bytes_written
        if rc == error_codes._LIBSSH2_ERROR_EAGAIN:
            poller_func()
