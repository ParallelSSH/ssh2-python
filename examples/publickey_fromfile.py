"""Example script for authentication with public key from file"""

from __future__ import print_function

import argparse
import socket
import os
import pwd
import sys

from ssh2.session import Session


USERNAME = pwd.getpwuid(os.geteuid()).pw_name

parser = argparse.ArgumentParser()

parser.add_argument('privatekey', help="Private key file to authenticate with")
parser.add_argument('cmd', help="Command to run")
parser.add_argument('--host', dest='host',
                    default='localhost',
                    help='Host to connect to')
parser.add_argument('--port', dest='port', default=22, help="Port to connect on", type=int)
parser.add_argument('-u', dest='user', default=USERNAME, help="User name to authenticate as")
parser.add_argument('-p', '--passphrase', dest="passphrase",
                    help="Passphrase to unlock key with", default='')

def main():
    args = parser.parse_args()
    if not os.path.isfile(args.privatekey):
        print("No such private key %s" % (args.privatekey,))
        sys.exit(1)

    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect((args.host, args.port))
    s = Session()
    s.handshake(sock)
    s.userauth_publickey_fromfile(
        args.user, args.privatekey, passphrase=args.passphrase)
    chan = s.open_session()
    chan.execute(args.cmd)
    size, data = chan.read()
    while size > 0:
        print(data)
        size, data = chan.read()

if __name__ == "__main__":
    main()
