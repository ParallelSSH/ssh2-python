from __future__ import print_function
import os
import socket

from ssh2.session import Session
from ssh2.utils import version

# Connection settings
host = 'localhost'
user = os.getlogin()

# Make socket, connect
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.connect((host, 22))

# Initialise
session = Session()
session.handshake(sock)

# List available authentication methods
print(session.userauth_list(user))

# Convenience function for agent based authentication
session.agent_auth(user)

# Agent capabilities
agent = session.agent_init()
agent.connect()
identities = agent.get_identities()
print(identities)
print(identities[0].magic)
del agent

# Public key blob available as identities[0].blob

# Channel initialise, exec and wait for end
channel = session.open_session()
channel.execute('echo me')
channel.wait_eof()
channel.close()
channel.wait_closed()

# Get exit status
print("Exit status: %s" % channel.get_exit_status())

# Print output
size, data = channel.read()
while size > 0:
    print(data)
    size, data = channel.read()

# SFTP capabilities, uncomment and enter a filename

# sftp = session.sftp_init()
# fh = sftp.open('<my file>', 0, 0)
# for data in fh:
#     pass
# del session
