Change Log
=============

0.5.3
++++++

* Win32 build compatibility.
* Binary wheels for Linux, OSX and Windows, all Python versions, with embedded libssh2 and OpenSSL (embedded OpenSSL is Linux and OSX only).
* OSX CI builds.

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
