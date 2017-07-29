ssh2-python
============

Super fast SSH2 protocol library. ``ssh2-python`` provides Python bindings for `libssh2`_.

.. image:: https://img.shields.io/badge/License-LGPL%20v2-blue.svg
  :target: https://pypi.python.org/pypi/ssh2-python
  :alt: License
.. image:: https://img.shields.io/pypi/v/ssh2-python.svg
  :target: https://pypi.python.org/pypi/ssh2-python
  :alt: Latest Version

Features
---------

Majority of the `libssh2`_ API has been implemented as Python native code extensions. ``ssh2-python`` is a thin wrapper of ``libssh2`` - ``libssh2`` code examples can be ported straight over to Python with only minimal changes.

*Library is usable for testing purposes and at the moment available as source code only. API, module names and documentation not yet finalised. Contributions welcome.*

SSH Functionality provided
++++++++++++++++++++++++++++

* SSH channel operations (exec,shell,subsystem)
* SSH agent
* Public key authentication and management
* SFTP
* SCP
* SSH port forwarding and tunnelling
* Non-blocking mode
* Listener for port forwarding

And more, as per `libssh2`_ functionality.


Native Code Extension Features
+++++++++++++++++++++++++++++++

The library uses `Cython`_ based native code extensions as wrappers to ``libssh2``.

Extension features:

* Thread safe - GIL is released as much as possible
* Very low overhead
* Super fast as a consequence of the excellent C library it uses and that it uses native code prodigiously
* Object oriented - memory freed automatically and safely as objects expire
* Use Python semantics where applicable, such as iterator support for SFTP file handles
* Expose errors as Python exceptions where possible
* Provide access to ``libssh2`` error code definitions


Example
--------

A simple usage example looks very similar to ``libssh2`` `usage examples <https://www.libssh2.org/examples/>`_.

As mentioned, ``ssh2-python`` is intentially a thin wrapper over ``libssh2`` and directly maps most of its API.

Clients using this library can be much simpler to use than interfacing with the ``libssh2`` API directly.

.. code-block:: python

   from __future__ import print_function

   import os
   import socket

   from ssh2 import Session

   host = 'localhost'
   user = os.getlogin()

   sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
   sock.connect((host, 22))

   session = Session()
   session.handshake(sock)
   session.agent_auth(user)

   channel = session.open_session()
   channel.execute('echo me; exit 2')
   size, data = channel.read()
   while size > 0:
       print(data)
       size, data = channel.read()
   channel.close()
   print("Exit status: %s" % channel.get_exit_status())


:Output:

   me

   Exit status: 2


Comparison with other Python SSH2 libraries
---------------------------------------------

Performance of above example, compared with Paramiko.

.. code-block:: shell

   time python examples/example_echo.py
   time python examples/paramiko_comparison.py

:Output:

   ``ssh2-python``::

     real	0m0.141s
     user	0m0.037s
     sys	0m0.008s

   ``paramiko``::

     real	0m0.592s
     user	0m0.351s
     sys	0m0.021s


See `examples directory <https://github.com/ParallelSSH/ssh2-python/tree/master/examples>`_ for more complete example scripts.

.. _libssh2: https://www.libssh2.org
.. _Cython: https://www.cython.org
