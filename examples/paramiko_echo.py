from __future__ import print_function

import paramiko

client = paramiko.SSHClient()
client.set_missing_host_key_policy(
    paramiko.MissingHostKeyPolicy())
client.connect('localhost')
transport = client.get_transport()
channel = transport.open_session()
stdout = channel.makefile('rb')
channel.exec_command('echo me')
for line in stdout:
    print(line)
channel.close()
print("Exit status: %s" % channel.recv_exit_status())
