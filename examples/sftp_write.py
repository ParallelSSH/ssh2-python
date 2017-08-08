#!/usr/bin/python

"""Example script for SFTP write"""

from __future__ import print_function

import argparse
import socket
import os
import pwd
import sys
from datetime import datetime

from ssh2.session import Session
from ssh2.sftp import LIBSSH2_FXF_CREAT, LIBSSH2_FXF_WRITE, \
    LIBSSH2_SFTP_S_IRUSR, LIBSSH2_SFTP_S_IRGRP, LIBSSH2_SFTP_S_IWUSR, \
    LIBSSH2_SFTP_S_IROTH


USERNAME = pwd.getpwuid(os.geteuid()).pw_name

parser = argparse.ArgumentParser()


parser.add_argument('source', help="Source file to copy")
parser.add_argument('destination', help="Remote destination file to copy to")
parser.add_argument('--host', dest='host',
                    default='localhost',
                    help='Host to connect to')
parser.add_argument('--port', dest='port', default=22, help="Port to connect on", type=int)
parser.add_argument('-u', dest='user', default=USERNAME, help="User name to authenticate as")


def main():
    args = parser.parse_args()
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect((args.host, args.port))
    s = Session()
    s.handshake(sock)
    s.agent_auth(args.user)
    sftp = s.sftp_init()
    mode = LIBSSH2_SFTP_S_IRUSR | \
           LIBSSH2_SFTP_S_IWUSR | \
           LIBSSH2_SFTP_S_IRGRP | \
           LIBSSH2_SFTP_S_IROTH
    f_flags = LIBSSH2_FXF_CREAT | LIBSSH2_FXF_WRITE
    print("Starting copy of local file %s to remote %s:%s" % (
        args.source, args.host, args.destination))
    now = datetime.now()
    with open(args.source, 'rb') as local_fh, \
            sftp.open(args.destination, f_flags, mode) as remote_fh:
        for data in local_fh:
            remote_fh.write(data)
    print("Finished writing remote file in %s" % (datetime.now() - now,))


if __name__ == "__main__":
    main()
