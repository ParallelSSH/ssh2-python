Examples
==========

In this directory can be found example scripts using ``ssh2-python`` for various operations.

To try them out, install the library and run the scripts like so:

Pkey from file
---------------

.. code-block:: shell

   python examples/publickey_fromfile.py ~/.ssh/id_rsa 'echo me'

::

   me

Non-blocking execute
----------------------

.. code-block:: shell

   python examples/nonblocking_execute.py 'echo me'

::

   Would block, waiting for socket to be ready
   Would block, waiting for socket to be ready
   Waiting for command to finish
   Waiting for command to finish
   me

SFTP write
-----------

.. code-block:: shell

   python examples/sftp_write.py ~/<my source file> ~/<my dest file>

::

   Starting copy of local file <source file> to remote localhost:<dest file>
   Finished writing remote file in 0:00:00.006304

Do *not* use the same filename for source and destination when connecting to localhost if you want to keep your file intact.

SFTP read
-----------

.. code-block:: shell

   python examples/sftp_read.py ~/<remote file>

::

   Starting read for remote file <remote file>
   Finished file read in 0:00:00.045763

Non-blocking SFTP read
-----------------------

Note there is no error checking and file is assumed to exist. The script will hang if it does not.

.. code-block:: shell

   python examples/nonblocking_sftp_read.py <remote file>

::

   Would block on sftp init, waiting for socket to be ready
   <..>
   Would block on sftp init, waiting for socket to be ready
   Starting read for remote file <remote file>
   Would block on handle open
   Would block on read, waiting..
   Finished file read in 0:00:00.056730

Non-blocking SFTP readdir
---------------------------

Print a directory listing in non-blocking mode.

.. code-block:: shell

   python examples/nonblocking_sftp_readdir.py .

::

   Starting read for remote dir .
   Would block on readdir, waiting on socket..
   b'<..>'

Password authentication
-------------------------

Authentication with wrong password raises ``AuthenticationError`` exception.

.. code-block:: shell

   python examples/password_auth.py 'asdfadf' 'echo me'

::

   Traceback (most recent call last):
     File "examples/password_auth.py", line 45, in <module>
       main()
     File "examples/password_auth.py", line 35, in main
       s.userauth_password(args.user, args.password)
     File "ssh2/session.pyx", line 250, in ssh2.session.Session.userauth_password
      raise AuthenticationError(
   ssh2.exceptions.AuthenticationError: ('Error authenticating user %s with password', '<user>')

SSH Agent authentication
--------------------------

Simple SSH agent authentication. The method used here is a helper function, not part of the libssh2 API, to do all the individual steps needed to retrieve, check and attempt to authenticate with an available SSH agent, raising exceptions on errors.

.. code-block:: shell

   python examples/agent_auth.py 'echo me'

::

   me
