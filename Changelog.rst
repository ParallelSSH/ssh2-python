Change Log
=============

0.13.0
+++++++

Changes
---------

* Upgrade embedded ``libssh2`` in binary wheels to latest version plus enhancements.
* Adds support for ECDSA host and client keys.
* Adds support for SHA-256 host key fingerprints.
* Added SSH agent forwarding implementation.
* Windows wheels switched to OpenSSL back end.
* Windows wheels include zlib and have compression enabled.
* Windows wheels no MAC and no encryption options enabled, same as posix wheels.
* SCP functions now raise appropriate exception for all known libssh2 error codes.

Fixes
-------

* SCP functions could not be used in non-blocking mode.

Note - libssh2 changes apply to binary wheels only. For building from source `see documentation <http://ssh2-python.readthedocs.io/en/latest/installation.html#installation-from-source>`_.

0.11.0
++++++++

Changes
---------

* Session functions now raise exceptions.
* Channel functions now raise specific exceptions.
* SCP errors now raise exceptions.
* SFTP open handle errors now raise exceptions.
* Added exceptions for all known libssh2 error codes.
* Added ``ssh2.utils.handle_error_codes`` function for raising appropriate exception from error code.
* Added file types to ``ssh2.sftp``.

Fixes
------

* Double de-allocation crash on objects being garbage collected in some rare cases.


0.10.0
++++++++

Changes
---------

* Added ``ssh2.channel.Channel.shell`` for opening interactive shells.


Fixes
------

* ``ssh2.channel.Channel.process_startup`` would not handle request types with no message correctly.


0.9.1
++++++

Fixes
------

* Binary wheels would have bad version info and require `git` for installation - #17


0.9.0
++++++

Changes
-------

* Enabled embedded libssh2 library functionality for versions >= 1.6.0.


0.8.0
++++++

Changes
---------

* Implemented known host API, all functions.
* Added `hostkey` method on `Session` class for retrieving server host key.
* Added server host key verification from known hosts file example.
* Added exceptions for all known host API errors.

0.7.0
++++++

Changes
---------

* Exceptions moved from C-API to Python module

Fixes
------

* PyPy build support

0.6.0
++++++

Changes
---------

* Implemented `last_errno` and `set_last_error` session functions
* Agent authentication errors raise exceptions
* C-API refactor
* SFTP IO errors raise exceptions

Fixes
-------

* Crash on de-allocation of channel in certain cases
* SFTP ``readdir_ex`` directory listing (long entry) was not returned correctly

0.5.5
++++++

Changes
---------

* Accept both bytes and unicode parameters in authentication with public key from memory.

Fixes
------

* Unicode -> bytes parameter conversion would fail in some cases.


0.5.4
++++++

Fixes
------

* Agent authentication thread safety.


0.5.3
++++++

Changes
--------

* Win32 build compatibility.
* Binary wheels for Linux, OSX and Windows, all Python versions, with embedded libssh2 and OpenSSL (embedded OpenSSL is Linux and OSX only).
* OSX CI builds.

Fixes
-----

* Session initialisation thread safety.
* Agent thread safety.

0.5.2
++++++

No code changes.

0.5.1
++++++

Changes
--------

* Implemented public key subsystem for public key management on remote servers
* Added all libssh2 error codes to ``ssh2.error_codes``

0.5.0
++++++

Changes
----------

* Implemented SFTP statvfs and SFTP handle fstatvfs methods.
* Implemented SFTPStatVFS extension class for file system statistics.
* SFTP read and readdir functions now return size/error code along with data.
* SFTP handle fstat now returns attributes.
* Implemented SFTP handle readdir* methods as python generators.
* Block directions function renamed to match libssh2.
* Example scripts.
* All session authentication methods now raise ``AuthenticationError`` on failure.

Fixes
---------

* SFTP readdir functions can now be used in non-blocking mode
* Use of SFTP openddir via context manager

0.4.0
+++++++++

Changes
---------

* Implemented SCP send and recv methods, all versions.
* Conditional compilation of features requiring newer versions of libssh2.
* Implemented channel receive window adjust, x11_*, poll and handle extended data methods.
* Implemented session get/set blocking, get/set timeout.
* Updated agent connection error exception name.
* Renamed session method name to match libssh2.
* Info extension classes for SCP file stat structure.


0.3.1
++++++++++

Changes
----------

* Added context manager to SFTP handle
* Implemented SFTP write, seek, stat, fstat and last_error methods.
* Implemented SFTPAttribute object creation and de-allocation - added unit test.


0.3.0
++++++++

Changes
----------

* Updated API
* Updated session, channel, agent and pkey to accept any string type arguments.
* Added get_exit_signal implementation for channel.
