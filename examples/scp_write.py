#!/usr/bin/python

"""Example script for SCP write"""

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
    fileinfo = os.stat(args.source)
    chan = s.scp_send64(args.destination, fileinfo.st_mode & 0o777, fileinfo.st_size,
                        fileinfo.st_mtime, fileinfo.st_atime)
    print("Starting SCP of local file %s to remote %s:%s" % (
        args.source, args.host, args.destination))
    now = datetime.now()
    with open(args.source, 'rb') as local_fh:
        for data in local_fh:
            chan.write(data)
    taken = datetime.now() - now
    rate = (fileinfo.st_size / (1024000.0)) / taken.total_seconds()
    print("Finished writing remote file in %s, transfer rate %s MB/s" % (
        taken, rate))


if __name__ == "__main__":
    main()
