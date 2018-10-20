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

System packages can be built for Centos/RedHat 7, Ubuntu 14.04/16.04/18.04, Debian 8 and Fedora 22/23/24 by running `ci/docker/build-packages.sh <https://github.com/ParallelSSH/ssh2-python/blob/master/ci/docker/build-packages.sh>`_ script in the repository's directory, based on Docker.

To use the built packages, install via the system's package manager, for example for Centos/RedHat based systems:

.. code-block:: shell

   yum install -y python-ssh2-python-<version>-1.el7.x86_64.rpm

.. note::

  System packages as built by the above script use system provided ``libssh2`` and do not have all features enabled as most distributions do not have a new enough version. In addition, there are known issues with older versions of ``libssh2`` like what is provided by distributions.

  For best compatibility, it is recommended to install binary packages with ``pip``.

Conda package
===============

A `conda <https://conda.io/miniconda.html>`_ package is available in the ``conda-forge`` channel.

To install, run the following.

.. code-block:: shell

   conda install -c conda-forge ssh2-python

Installation from Source
==========================

Source distributions inlude a bundled ``libssh2`` which is built automatically by default. OpenSSL development libraries are required.

For builds against system provided ``libssh2``, the ``SYSTEM_LIBSSH2=1`` environment variable setting can be used.

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
_______

Example for Debian or Ubuntu based distributions.

.. code-block:: shell

   sudo apt-get install libssh2-1-dev python-dev
   virtualenv my_env
   source my_env/bin/activate
   export SYSTEM_LIBSSH2=1
   python setup.py install


RedHat
_______

Example for RedHat based distributions.
   
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
