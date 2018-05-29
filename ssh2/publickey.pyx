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

from libc.stdlib cimport malloc, free

from session cimport Session
from utils cimport to_bytes, handle_error_codes
cimport c_pkey


cdef object PyPublicKeyList(c_pkey.libssh2_publickey_list *_list):
    cdef PublicKeyList key_list = PublicKeyList.__new__(PublicKeyList)
    key_list.key_list = _list
    return key_list


cdef class PublicKeyList:
    cdef c_pkey.libssh2_publickey_list *key_list
    cdef PublicKeySystem pkey_s

    def __cinit__(self, PublicKeySystem pkey_s):
        self.key_list = NULL
        self.pkey_s = pkey_s

    def __dealloc__(self):
        with nogil:
            c_pkey.libssh2_publickey_list_free(
                self.pkey_s.pkey_s, self.key_list)

    @property
    def name(self):
        return self.attr.name

    @property
    def name_len(self):
        return self.attr.name_len

    @property
    def blob(self):
        return self.attr.blob

    @property
    def blob_len(self):
        return self.attr.blob_len

    @property
    def num_attrs(self):
        return self.attr.num_attrs


cdef class PublicKeyAttribute:
    """Public key attributes"""
    cdef c_pkey.libssh2_publickey_attribute attr

    def __cinit__(self, bytes name, bytes value, char mandatory):
        cdef char *_name = name
        cdef char *_value = value
        cdef unsigned long name_len = len(name)
        cdef unsigned long value_len = len(value)
        self.attr = c_pkey.libssh2_publickey_attribute(
            _name, name_len, _value, value_len, mandatory)

    @property
    def name(self):
        return self.attr.name

    @property
    def name_len(self):
        return self.attr.name_len

    @property
    def value(self):
        return self.attr.value

    @property
    def value_len(self):
        return self.attr.value_len

    @property
    def mandatory(self):
        return self.attr.mandatory


cdef c_pkey.libssh2_publickey_attribute * to_c_attr(list attrs):
    cdef c_pkey.libssh2_publickey_attribute *_attrs
    cdef size_t size = len(attrs)
    cdef c_pkey.libssh2_publickey_attribute attr
    with nogil:
        _attrs = <c_pkey.libssh2_publickey_attribute *>malloc(
            (size + 1) * sizeof(c_pkey.libssh2_publickey_attribute))
        if _attrs is NULL:
            with gil:
                raise MemoryError
    for i in range(size):
        attr = attrs[i].attr
        with nogil:
            _attrs[i] = attr
    return _attrs


cdef object PyPublicKeySystem(c_pkey.LIBSSH2_PUBLICKEY *_pkey_s,
                              Session session):
    cdef PublicKeySystem pkey_s = PublicKeySystem.__new__(
        PublicKeySystem, session)
    pkey_s.pkey_s = _pkey_s
    return pkey_s


cdef class PublicKeySystem:
    """Public Key subsystem. Methods for managing public keys on remote
    server, like with the ``ssh-*-id`` utilities.
    Not related to pkey authentication."""
    cdef c_pkey.LIBSSH2_PUBLICKEY *pkey_s
    cdef Session session

    def __cinit__(self, Session session):
        self.pkey_s = NULL
        self.session = session

    def __dealloc__(self):
        with nogil:
            c_pkey.libssh2_publickey_shutdown(self.pkey_s)

    def add(self, bytes name, bytes blob,
            char overwrite,
            list attrs):
        cdef unsigned long name_len = len(name)
        cdef unsigned long num_attrs = len(attrs)
        cdef c_pkey.libssh2_publickey_attribute *_attrs = NULL
        if num_attrs > 0:
            _attrs = to_c_attr(attrs)
        cdef const unsigned char *_name = name
        cdef size_t blob_len = len(blob)
        cdef const unsigned char *_blob = blob
        with nogil:
            rc = c_pkey.libssh2_publickey_add_ex(
                self.pkey_s, _name, name_len, _blob,
                blob_len, overwrite, num_attrs, _attrs)
            if _attrs is not NULL:
                free(_attrs)
        return handle_error_codes(rc)

    def remove(self, bytes name, bytes blob):
        cdef unsigned long name_len = len(name)
        cdef unsigned long blob_len = len(blob)
        cdef const unsigned char *_name = name
        cdef const unsigned char *_blob = blob
        with nogil:
            rc = c_pkey.libssh2_publickey_remove_ex(
                self.pkey_s, _name, name_len, _blob, blob_len)
        return handle_error_codes(rc)

    def list_fetch(self):
        cdef unsigned long num_keys = 0
        cdef c_pkey.libssh2_publickey_list **pkey_list = NULL
        cdef int rc
        cdef list keys
        with nogil:
            rc = c_pkey.libssh2_publickey_list_fetch(
                self.pkey_s, &num_keys, pkey_list)
        if rc != 0:
            return handle_error_codes(rc)
        if num_keys < 1:
            return []
        keys = [PyPublicKeyList(pkey_list[i]) for i in range(num_keys)]
        return keys

    def list_free(self):
        """No-op - list_free called automatically by
        :py:class:`ssh2.publickey.PublicKeyList` destructor"""
        pass

    def shutdown(self):
        """Shutdown public key subsystem.
        Called automatically by object destructor"""
        cdef int rc
        with nogil:
            rc = c_pkey.libssh2_publickey_shutdown(self.pkey_s)
        return handle_error_codes(rc)
