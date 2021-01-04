Installation
*************

The recommended installation method is ``pip``.

Pip Binary Packages
====================

Binary wheel packages are provided for Linux, OSX and Windows, all Python versions, with ``libssh2`` and its dependencies included.

Wheel packages have **no dependencies**.

``pip`` may need to be updated to be able to install binary wheel packages.

.. code-block:: shell

   pip install -U pip

   pip install ssh2-python

.. note::

   Latest available version of OpenSSL at the time the package is built is included in binary wheel packages.

   To control which version of OpenSSL is used for the installation either use system packages which use system libraries, the conda package, or install from source.

System Binary Packages
=======================

System packages can be built for Centos/RedHat 7, Ubuntu 18.04, Debian 8 and Fedora 24 by running `ci/docker/build-packages.sh <https://github.com/ParallelSSH/ssh2-python/blob/master/ci/docker/build-packages.sh>`_ script in the repository's directory, based on Docker.

The docker files and scripts can be adjusted for newer distribution versions, or other distributions.

To use the built packages, install via the system's package manager, for example for Centos/RedHat based systems:

.. code-block:: shell

   yum install -y python-ssh2-python-<version>-1.el7.x86_64.rpm

.. note::

  These scripts will use the distribution's libssh2 package.

  Starting from ``ssh2-python`` version ``0.27.0``, libssh2 >= ``1.7.0`` is required.

  For best compatibility, it is recommended to install binary packages with ``pip``.

Installation from Source
=========================

Source distributions inlude a bundled ``libssh2`` which is built automatically by default. OpenSSL development libraries are required.

To build against system provided ``libssh2``, the ``SYSTEM_LIBSSH2=1`` environment variable setting can be used.

Dependencies
------------

================================= ============
Package                           Version
================================= ============
libssh2 (ssh2-python >= 0.27.0)   >=1.7.0
libssh2 (ssh2-python <= 0.26.0)   >=1.4.0
OpenSSL                           1.0 or 1.1
zlib (for compression support)    Any
Kerberos (for GSS-API support)    5
================================= ============

Other cryptography libraries are supported by libssh2, though more authentication methods are supported with OpenSSL.

Newer public key types like ED-25519 require OpenSSL 1.1.

Standard build
---------------

Source distributions include a bundled ``libssh2`` which is used by default.

.. code-block:: shell

   git clone git@github.com:ParallelSSH/ssh2-python.git
   virtualenv my_env
   source my_env/bin/activate
   python setup.py install


System library build
---------------------

Building against system provided ``libssh2`` is another option which may be preferred. This can be done by setting the ``SYSTEM_LIBSSH2=1`` environment variable:

.. code-block:: shell

   git clone git@github.com:ParallelSSH/ssh2-python.git
   virtualenv my_env
   source my_env/bin/activate
   export SYSTEM_LIBSSH2=1
   python setup.py install


Custom Compiler Configuration
-------------------------------

If there are multiple ``libssh2`` installations on the system, the following can be used to set the include path, runtime and build time library directory paths respectively:

.. code-block:: shell

   git clone git@github.com:ParallelSSH/ssh2-python.git
   virtualenv my_env
   source my_env/bin/activate
   python setup.py build_ext -I /usr/local/include -R /usr/local/lib/x86_64-linux-gnu -L /usr/local/lib/x86_64-linux-gnu
   python setup.py install


Ubuntu
-------

Example build for Debian or Ubuntu based distributions.

.. code-block:: shell

   sudo apt-get install libssh2-1-dev python-dev
   virtualenv my_env
   source my_env/bin/activate
   export SYSTEM_LIBSSH2=1
   python setup.py install


RedHat
-------

Example build for RedHat based distributions.
   
.. code-block:: shell

   sudo yum install libssh2-devel python-devel
   virtualenv my_env
   source my_env/bin/activate
   export SYSTEM_LIBSSH2=1
   python setup.py install


Testing Installation
=====================

Importing the library should exit without error if installation is successful.

.. code-block:: shell

   python -c 'from ssh2.session import Session'
   echo $?

:Output:

   ``0``
