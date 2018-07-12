"""Example script for non-blocking execute.

Note that `ssh2.utils.wait_socket` is not a co-operative routine and will block
the main thread for up to <timeout> (default 1sec). Use for testing purposes
only."""

from __future__ import print_function

import argparse
import socket
import os
import pwd
from select import select

from ssh2.session import Session
# from ssh2.utils import wait_socket
from ssh2.error_codes import LIBSSH2_ERROR_EAGAIN
from ssh2.session import LIBSSH2_SESSION_BLOCK_INBOUND, \
    LIBSSH2_SESSION_BLOCK_OUTBOUND


USERNAME = pwd.getpwuid(os.geteuid()).pw_name

parser = argparse.ArgumentParser()

parser.add_argument('cmd', help="Command to run")
parser.add_argument('--host', dest='host',
                    default='localhost',
                    help='Host to connect to')
parser.add_argument('--port', dest='port', default=22,
                    help="Port to connect on", type=int)
parser.add_argument('-u', dest='user', default=USERNAME,
                    help="User name to authenticate as")


def wait_socket(_socket, session, timeout=1):
    """Helper function for testing non-blocking mode.

    This function blocks the calling thread for <timeout> seconds -
    to be used only for testing purposes.

    Also available at `ssh2.utils.wait_socket`
    """
    directions = session.block_directions()
    if directions == 0:
        return 0
    readfds = [_socket] \
        if (directions & LIBSSH2_SESSION_BLOCK_INBOUND) else ()
    writefds = [_socket] \
        if (directions & LIBSSH2_SESSION_BLOCK_OUTBOUND) else ()
    return select(readfds, writefds, (), timeout)


def main():
    args = parser.parse_args()
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect((args.host, args.port))
    s = Session()
    s.handshake(sock)
    # Agent connections cannot be used as non-blocking
    s.agent_auth(args.user)
    # Now we can set non-blocking mode
    s.set_blocking(False)
    chan = s.open_session()
    while chan == LIBSSH2_ERROR_EAGAIN:
        print("Would block on session open, waiting for socket to be ready")
        wait_socket(sock, s)
        chan = s.open_session()
    while chan.execute(args.cmd) == LIBSSH2_ERROR_EAGAIN:
        print("Would block on channel execute, waiting for socket to be ready")
        wait_socket(sock, s)
    while chan.wait_eof() == LIBSSH2_ERROR_EAGAIN:
        print("Waiting for command to finish")
        wait_socket(sock, s)
    size, data = chan.read()
    while size == LIBSSH2_ERROR_EAGAIN:
        print("Waiting to read data from channel")
        wait_socket(sock, s)
        size, data = chan.read()
    while size > 0:
        print(data)
        size, data = chan.read()


if __name__ == "__main__":
    main()
