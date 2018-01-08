"""Connect to localhost, verifying host by reading from ~/.ssh/known_hosts"""

from __future__ import print_function
import os
import socket

from ssh2.session import Session
from ssh2.session import LIBSSH2_HOSTKEY_HASH_SHA1, LIBSSH2_HOSTKEY_TYPE_RSA
from ssh2.knownhost import LIBSSH2_KNOWNHOST_TYPE_PLAIN, \
    LIBSSH2_KNOWNHOST_KEYENC_RAW, LIBSSH2_KNOWNHOST_KEY_SSHRSA

# Connection settings
host = 'localhost'
user = os.getlogin()
known_hosts = os.sep.join([os.path.expanduser('~'), '.ssh', 'known_hosts'])

# Make socket, connect
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.connect((host, 22))

# Initialise
session = Session()
session.handshake(sock)

host_key, key_type = session.hostkey()

server_key_type = LIBSSH2_KNOWNHOST_KEY_SSHRSA \
                  if key_type == LIBSSH2_HOSTKEY_TYPE_RSA \
                     else LIBSSH2_KNOWNHOST_KEY_SSHDSS

kh = session.knownhost_init()
_read_hosts = kh.readfile(known_hosts)
print("Read %s hosts from known hosts file at %s" % (_read_hosts, known_hosts))

# Verification
type_mask = LIBSSH2_KNOWNHOST_TYPE_PLAIN | \
            LIBSSH2_KNOWNHOST_KEYENC_RAW | \
            server_key_type
kh.checkp(host, 22, host_key, type_mask)
print("Host verification passed.")

# Verification passed, continue with authentication
session.agent_auth(user)

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
