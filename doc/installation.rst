Installation
*************

System Binary Packages
=======================

System packages are available on the `latest releases page <https://github.com/ParallelSSH/ssh2-python/releases/latest>`_ built on Centos/RedHat 6/7, Ubuntu 14.04/16.04, Debian 7/8 and Fedora 22/23/24.

To use, download and install via the system's package manager, for example for Centos/RedHat based systems:

.. code-block:: shell

   yum install -y python-ssh2-python-0.4.0-1.el7.x86_64.rpm

Installation from Source
==========================

To install from source, ``libssh2`` and Python development headers are required.

Ubuntu
--------

.. code-block:: shell

   apt-get install libssh2-1-dev python-dev
   pip install ssh2-python


RedHat
-------
   
.. code-block:: shell

   yum install libssh2-devel python-devel
   pip install ssh2-python


Testing Installation
=====================

Importing the library should exit without error if installation is successful.

.. code-block:: shell

   python -c 'from ssh2.session import Session'
   echo $?

:Output:

   ``0``
