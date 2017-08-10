#!/usr/bin/python

"""Example script for non-blocking SFTP read"""

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


parser.add_argument('file', help="File to read")
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
    # Agent connections cannot be used as non-blocking
    s.agent_auth(args.user)
    # Now we can set non-blocking mode
    s.set_blocking(False)
    sftp = s.sftp_init()
    while sftp is None:
        print("Would block on sftp init, waiting for socket to be ready")
        wait_socket(sock, s)
        sftp = s.sftp_init()
    wait_socket(sock, s)
    now = datetime.now()
    print("Starting read for remote file %s" % (args.file,))
    # This will hang if the file is missing, should do a stat first
    # to check if it exists.
    fh = sftp.open(args.file, 0, 0)
    while fh is None:
        print("Would block on handle open")
        wait_socket(sock, s)
        fh = sftp.open(args.file, 0, 0)
    size, data = fh.read()
    while size == LIBSSH2_ERROR_EAGAIN:
        print("Would block on read, waiting..")
        wait_socket(sock, s)
        size, data = fh.read()
    for size, data in fh:
        pass
    # Handle is also closed when object is garbage collected.
    # It is safe to close it explicitly as well.
    fh.close()
    print("Finished file read in %s" % (datetime.now() - now,))


if __name__ == "__main__":
    main()
