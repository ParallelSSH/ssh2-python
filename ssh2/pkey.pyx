# This file is part of ssh2-python.
# Copyright (C) 2017 Panos Kittenis

# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation, version 2.1.

# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.

# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

cimport c_ssh2


cdef object PyPublicKey(c_ssh2.libssh2_agent_publickey *pkey):
    cdef PublicKey _pkey = PublicKey.__new__(PublicKey)
    _pkey._pkey = pkey
    return _pkey


cdef class PublicKey:
    """Extension class for representing public key data from libssh2.

    Can be used for authentication via :py:func:`ssh2.agent.Agent.userauth`"""

    def __cinit__(self):
        self._pkey = NULL

    @property
    def blob(self):
        """Blob of public key data.

        :rtype: bytes
        """
        if self._pkey is NULL:
            return
        return self._pkey.blob[:self._pkey.blob_len]

    @property
    def magic(self):
        """Magic number of public key.

        :rtype: int
        """
        if self._pkey is NULL:
            return
        return self._pkey.magic

    @property
    def blob_len(self):
        """Blob length of public key.

        :rtype: int
        """
        if self._pkey is NULL:
            return
        return self._pkey.blob_len

    @property
    def comment(self):
        """Public key comment

        :rtype: bytes
        """
        if self._pkey is NULL:
            return
        return self._pkey.comment
