#!/usr/bin/python

"""Example script for SFTP read"""

from __future__ import print_function

import argparse
import socket
import os
import pwd
import sys
from datetime import datetime

from ssh2.session import Session


USERNAME = pwd.getpwuid(os.geteuid()).pw_name

parser = argparse.ArgumentParser()


parser.add_argument('file', help="File to read")
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
    now = datetime.now()
    print("Starting read for remote file %s" % (args.file,))
    with sftp.open(args.file, 0, 0) as fh:
        for size, data in fh:
            pass
    print("Finished file read in %s" % (datetime.now() - now,))


if __name__ == "__main__":
    main()
