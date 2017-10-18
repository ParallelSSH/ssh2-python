Installation
*************

Pip Binary Packages
====================

Binary wheel packages are provided for Linux, OSX and Windows, all Python versions, with ``libssh2`` and its required libraries included.

Wheel packages have **no dependencies**.

``pip`` may need to be updated to be able to install binary wheel packages.

.. code-block:: shell

   pip install -U pip

   pip install ssh2-python

.. note::

   Latest version of OpenSSL is included in Linux and OSX binary wheel packages. On Windows, the native WinCNG back-end is used instead.

   To control which version of OpenSSL is used for the installation either use system packages which use system libraries, the conda package, or install from source.

System Binary Packages
=======================

System packages are available on the `latest releases page <https://github.com/ParallelSSH/ssh2-python/releases/latest>`_ built on Centos/RedHat 6/7, Ubuntu 14.04/16.04, Debian 7/8 and Fedora 22/23/24.

To use, download and install via the system's package manager, for example for Centos/RedHat based systems:

.. code-block:: shell

   yum install -y python-ssh2-python-0.6.0-1.el7.x86_64.rpm

Conda package
===============

A `conda <https://conda.io/miniconda.html>`_ package is available in the `conda-forge` channel.

To install, run the following.

.. code-block:: shell

   conda install -c conda-forge ssh2-python

Installation from Source
==========================

To install from source, ``libssh2`` and Python development headers are required.

Clone the repository, install dependencies and run install in a new virtualenv from the repository's root directory.

Ubuntu
--------

.. code-block:: shell

   sudo apt-get install libssh2-1-dev python-dev
   virtualenv my_env
   source my_env/bin/activate
   python setup.py install


RedHat
-------
   
.. code-block:: shell

   sudo yum install libssh2-devel python-devel
   virtualenv my_env
   source my_env/bin/activate
   python setup.py install


Testing Installation
=====================

Importing the library should exit without error if installation is successful.

.. code-block:: shell

   python -c 'from ssh2.session import Session'
   echo $?

:Output:

   ``0``
