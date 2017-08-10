#!/usr/bin/python

"""Example script for non-blocking SFTP readdir"""

from __future__ import print_function

import argparse
import socket
import os
import pwd
from datetime import datetime

from ssh2.session import Session
from ssh2.utils import wait_socket
from ssh2.error_codes import LIBSSH2_ERROR_EAGAIN


USERNAME = pwd.getpwuid(os.geteuid()).pw_name

parser = argparse.ArgumentParser()


parser.add_argument('dir', help="Directory to read")
parser.add_argument('--host', dest='host',
                    default='localhost',
                    help='Host to connect to')
parser.add_argument('--port', dest='port', default=22,
                    help="Port to connect on", type=int)
parser.add_argument('-u', dest='user', default=USERNAME,
                    help="User name to authenticate as")


def main():
    args = parser.parse_args()
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect((args.host, args.port))
    s = Session()
    s.handshake(sock)
    s.agent_auth(args.user)
    sftp = s.sftp_init()
    now = datetime.now()
    print("Starting read for remote dir %s" % (args.dir,))
    with sftp.opendir(args.dir) as fh:
        # Can set blocking to false at any point, as long as the
        # libssh2 operations support running in non-blocking mode.
        s.set_blocking(False)
        for size, buf, attrs in fh.readdir():
            if size == LIBSSH2_ERROR_EAGAIN:
                print("Would block on readdir, waiting on socket..")
                wait_socket(sock, s)
                continue
            print(buf)
    print("Finished read dir in %s" % (datetime.now() - now,))


if __name__ == "__main__":
    main()
