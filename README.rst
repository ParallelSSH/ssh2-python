ssh2-python
============

Super fast SSH2 protocol library. ``ssh2-python`` provides Python bindings for `libssh2`_.

.. image:: https://img.shields.io/badge/License-LGPL%20v2.1-blue.svg
   :target: https://pypi.python.org/pypi/ssh2-python
   :alt: License
.. image:: https://img.shields.io/pypi/v/ssh2-python.svg
   :target: https://pypi.python.org/pypi/ssh2-python
   :alt: Latest Version
.. image:: https://circleci.com/gh/ParallelSSH/ssh2-python/tree/master.svg?style=svg
   :target: https://circleci.com/gh/ParallelSSH/ssh2-python
.. image:: https://ci.appveyor.com/api/projects/status/github/parallelssh/ssh2-python?svg=true&branch=master
   :target: https://ci.appveyor.com/project/pkittenis/ssh2-python
.. image:: https://img.shields.io/pypi/wheel/ssh2-python.svg
   :target: https://pypi.python.org/pypi/ssh2-python
.. image:: https://img.shields.io/pypi/pyversions/ssh2-python.svg
   :target: https://pypi.python.org/pypi/ssh2-python
.. image:: https://readthedocs.org/projects/ssh2-python/badge/?version=latest
  :target: http://ssh2-python.readthedocs.org/en/latest/
  :alt: Latest documentation


Installation
______________

Binary wheel packages are provided for Linux, OSX and Windows, all Python versions. Wheel packages have **no dependencies**.

``pip`` may need to be updated to be able to install binary wheel packages - ``pip install -U pip``.

.. code-block:: shell

   pip install ssh2-python

For from source installation instructions, including building against system provided libssh2, `see documentation <https://ssh2-python.readthedocs.io/en/latest/installation.html#installation-from-source>`_.

Who Should Use This
___________________

Most developers will want to use the `high level clients <https://parallel-ssh.readthedocs.io/en/latest/quickstart.html#single-host-client>`_
in `parallel-ssh <https://github.com/ParallelSSH/parallel-ssh>`_
based on this library.

This library provides bindings to the low-level libssh2 C-API. It is *not* high level, nor easy to use. A *lot* of code
would need to be written to use this library that is already provided by `parallel-ssh`.

Use `parallel-ssh <https://github.com/ParallelSSH/parallel-ssh>`_ unless *really* sure using a C-API is what is wanted.

API Feature Set
________________

At this time all of the `libssh2`_ API has been implemented up to the libssh2 version in the repository. Please report any missing implementation.

Complete example scripts for various operations can be found in the `examples directory`_.

In addition, as ``ssh2-python`` is a thin wrapper of ``libssh2`` with Python semantics, `its code examples <https://libssh2.org/examples/>`_ can be ported straight over to Python with only minimal changes.

Examples
_____________

See `examples directory <https://github.com/ParallelSSH/ssh2-python/tree/master/examples>`_  for complete examples.

Again, most developers will want to use `parallel-ssh <https://github.com/ParallelSSH/parallel-ssh>`_ rather than this
library directly.

Comparison with other Python SSH libraries
-------------------------------------------

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


.. _libssh2: https://www.libssh2.org
.. _Cython: https://www.cython.org
.. _`examples directory`: https://github.com/ParallelSSH/ssh2-python/tree/master/examples
.. _`mail group`: https://groups.google.com/forum/#!forum/ssh2-python
