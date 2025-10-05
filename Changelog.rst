Change Log
=============

1.2.0
++++++

Changes
--------

* Added constants for session related flags under `ssh2.session`.
* Added `ssh2.session.Session.flag` function for enabling/disabling session flags like compression support.
* Added `ssh2.session.userauth_keyboardinteractive_callback` for authentication using Python callback function,
  for example for Oauth and other two-factor (2FA) or more factor authentication. Thanks @MattCatz .
* `ssh2.sftp_handle.SFTPHandle.closed` is now a public property indicating whether `ssh2.sftp_handle.SFTPHandle.close`
  was called on a `SFTPHandle` or not.
* Added `ssh2.channel.Channel.signal` function for sending signals over SSH to an open channel - #221
* Added `ssh2.session.Session.direct_streamlocal_ex` for creating `Channel` objects tunneling a local UNIX socket
  via the remote host to a third party - #40
* Added new `libssh2` error codes under `ssh2.error_codes`, equivalent Python exceptions under `ssh2.exceptions`
  and updated error code handling for all functions.
* Removed deprecated `libssh2` `ssh2.channel.Channel` functions `receive_window_adjust`, `handle_extended_data`
  and `ignore_extended_data`.
* Removed deprecated `libssh2` `ssh2.session.Session` functions `startup`, `scp_recv` and `scp_send`.


Packaging
----------

* Removed Windows Python 3.7 wheel builds.
* OSX binary wheels now use embedded `libssh2` rather than brew package.


1.1.2
++++++

Changes
--------

No code changes.


Packaging
----------

* Added Windows Python 3.7 and 3.13 wheel builds.
* Removed manylinux 2010 wheels.
* Wheel builds now use embedded libssh2 and zlib.
* Dockerfiles and scripts updates.

1.1.1
+++++

Changes
--------

* Support for Python >=3.12.
* Upgraded embedded and wheel ``libssh2`` to ``1.11.1``.
* Upgraded wheel OpenSSL to 3.4.0.
* Removed testing for Python versions <3.8.

Fixes
-----

* Calling ``ssh2.session.Session.methods`` without a valid connection would cause a segfault - #203.

Packaging
----------

* Added binary wheels for Python versions 3.11, 3.12 and 3.13 on support manylinux wheel builds.
* Added OSX 12.0, 13.0 and 14.0 wheels, Apple Silicon.
* Support OSX brew OpenSSL from source builds.
* Top level tests directory is now cross platform and can be run by vendors.
* Moved CI specific integration tests to their own space.


1.0.0
++++++

Changes
--------

* Upgraded embedded and wheel libssh2 to 1.10.0.
* Upgraded wheel OpenSSL to 1.1.1q.
* Added testing for Python 3.10.
* Removed testing for Python 3.7.

Packaging
----------

* Added OSX 12.0 wheels.
* Removed OSX <= 10.0 wheels.

0.27.0
++++++

Changes
-------

* Python 3.10 support.

Fixes
-----

* Objects depending on ``ssh2.Session`` would sometimes cause segfault on interpreter shutdown.

Packaging
---------

* Added manylinux-2014 ARM (aarch64) wheel builds - #156 - Thanks @enaydanov
* Added manylinux-2014 x86_64 wheels for all currently available Python 3 versions.
* Added Windows 3.10 wheels.
* Added OSX 11.6, 11.5 and 11.4 wheels.


0.26.0
++++++

Changes
-------

* Enabled ``ssh2.fileinfo.FileInfo`` attributes on Windows builds - #131.


0.25.0
++++++

Changes
-------

* Added new in libssh2 `1.9.0` errors as exceptions.
* Added ``Session.methods``, ``Session.method_pref`` and ``Session.supported_algs`` functions.
* Added supported method types as ``ssh2.session.LIBSSH2_METHOD_*``.


0.24.0
++++++

Changes
-------

* ``Session.forward_listen_ex`` now returns (``Listener``, ``bound_port``) tuple.
* Added new in libssh2 1.9.0 host key and hash type attributes to ``ssh2.session``.
* Added new in libssh2 1.9.0 known host key attributes to ``ssh2.knownhost``.


0.23.0
++++++

Changes
-------

* Added ``ssh2.sftp.LIBSSH2_SFTP_ATTR_*`` constants for checking and setting SFTP attributes.

Fixes
-----

* ``Session.userauth_keyboardinteractive`` would cause segmentation fault.


0.20.0
++++++

Changes
--------

* Added helper function ``ssh2.utils.find_eol`` for finding end of line characters in buffer.


0.19.0
+++++++

Changes
--------

* Updated embedded libssh2 version to ``1.9.0``.
* Rebuilt sources with Cython ``0.29.21``.
* Added support for Python 3.8 and 3.9.

Fixes
------

* ``Session.userauth_publickey_frommemory`` would not work without an empty passphrase provided - #86

Packaging
----------

* Added Python 3.8 binary wheels for Linux, OSX and Windows.
* Added Python 3.9 binary wheels for Linux.
* Added OSX 10.14 and 10.15 wheels.
* Removed OSX < 10.14 wheels.
* Removed Python 2.7 OSX and Windows wheels.
* Removed Python 3.5 OSX and Windows wheels.
* Removed Windows 32-bit wheels.

0.18.0
+++++++

Changes
--------

* Session object de-allocation no longer calls session disconnect.
* Channel object de-allocation no longer calls channel close.
* Rebuilt sources with Cython ``0.29.6``.
* Updated Linux and Windows binary wheels to OpenSSL 1.1.
* Updated embedded ``libssh2`` to latest master.
* Added ``Ed25519`` publickey support via ``libssh2`` and OpenSSL upgrades.

Packaging
----------

* Source distribution builds would not include embedded libssh2 module in package - #51
* Removed OSX 10.10 binary wheel builds - deprecated by Travis-CI.
* Updated embedded OpenSSL version for Windows wheel builds.


0.17.0.post2
+++++++++++++

Packaging
----------

* Updated embedded OpenSSL version for Windows wheel builds.


0.17.0.post1
+++++++++++++

Packaging
----------

* Source distribution builds would not include embedded libssh2 module in package - #51
* Removed OSX 10.10 binary wheel builds - deprecated by Travis-CI.

0.17.0
+++++++

Changes
--------

* ``SFTPHandle.write`` function changed to return tuple of ``return_code, bytes_written`` for non-blocking applications to be able to handle partial writes within an SFTP write resulting from a blocked socket.
* ``Channel.write*`` functions changed to return tuple of ``return_code, bytes_written`` as above.

Behaviour in blocking mode has not changed. Non-blocking applications will now need to handle these functions returning a tuple and resume writes from last written offset of given data.

0.16.0
+++++++

Changes
--------

* Added ``Session.sock`` public attribute for getting socket used by ``Session``.
* Source distribution default ``libssh2`` build target updated to upstream ``libssh2`` master branch.
* Added bundled libssh2 source code for current master branch to repository and source distribution.
* Added automatic build of bundled libssh2 code for source builds and ``SYSTEM_LIBSSH2`` environment variable to control building and linking against system provided libssh2. This will require additional steps for Windows platforms and older libssh2 versions - see documentation.
* Updated binary wheels for all platforms to latest libssh2.
* Added keep alive API implementation - #47.


0.15.0
+++++++

Changes
--------

* Updated ``session.userauth_publickey*`` functions to make providing public key and private key passphrase optional.
* SFTP write calls write on all parts of buffer before returning.

Fixes
------

* ``session.last_error()`` would always return empty string.

0.14.0
+++++++

Changes
--------

* ``SFTP``, ``SFTPHandle``, ``Listener`` and ``PublicKeySystem`` functions updated to raise specific exceptions for all known ``libssh2`` errors.
* Removed exceptions ``SFTPHandleError``, ``SFTPBufferTooSmall`` and ``SFTPIOError`` that do not have corresponding ``libssh2`` error codes.
* Re-generated all C code with latest Cython release.

Fixes
------

* Removed duplicate libssh2 definitions.
* Re-enabled system package releases.
* System package builds would not work correctly - #25.


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
* ``ssh2.session.Session.disconnect`` now returns ``0`` on success and raises exceptions on errors.
* All session ``userauth_*`` functions now raise specific exceptions.

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
