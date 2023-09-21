#!/usr/bin/python

"""Example script for authentication with password"""

from __future__ import print_function

import argparse
import socket
import os
import pwd
import functools


from ssh2.session import Session


USERNAME = pwd.getpwuid(os.geteuid()).pw_name

parser = argparse.ArgumentParser()

parser.add_argument('password', help="User password")
parser.add_argument('oauth', help="OAUTH key to use for authentication")
parser.add_argument('cmd', help="Command to run")
parser.add_argument('--host', dest='host',
                    default='localhost',
                    help='Host to connect to')
parser.add_argument('--port', dest='port', default=22, help="Port to connect on", type=int)
parser.add_argument('-u', dest='user', default=USERNAME, help="User name to authenticate as")


def oauth_handler(name, instruction, prompts, password, oauth):
    responses = []

    for prompt in prompts:
        if "Password:" in prompt:
            responses.append(password)
        if "One-time password (OATH) for" in prompt:
            responses.append(oauth)
    
    return responses

def main():
    args = parser.parse_args()

    callback = functools.partial(oauth_handler,password=args.password,oauth=args.oauth)

    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect((args.host, args.port))
    s = Session()
    s.handshake(sock)
    s.userauth_keyboardinteractive_callback(args.user, callback)
    chan = s.open_session()
    chan.execute(args.cmd)
    size, data = chan.read()
    while size > 0:
        print(data)
        size, data = chan.read()


if __name__ == "__main__":
    main()
