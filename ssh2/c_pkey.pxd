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

cdef extern from "libssh2_publickey.h" nogil:
    ctypedef struct LIBSSH2_PUBLICKEY:
        pass
    ctypedef struct libssh2_publickey_attribute:
        const char *name
        unsigned long name_len
        const char *value
        unsigned long value_len
        char mandatory
    ctypedef struct libssh2_publickey_list:
        unsigned char *packet  # For freeing
        const unsigned char *name
        unsigned long name_len
        const unsigned char *blob
        unsigned long blob_len
        unsigned long num_attrs
        libssh2_publickey_attribute *attrs  # free me
    LIBSSH2_PUBLICKEY *libssh2_publickey_init(c_ssh2.LIBSSH2_SESSION *session)
    int libssh2_publickey_add_ex(LIBSSH2_PUBLICKEY *pkey,
                                 const unsigned char *name,
                                 unsigned long name_len,
                                 const unsigned char *blob,
                                 unsigned long blob_len, char overwrite,
                                 unsigned long num_attrs,
                                 const libssh2_publickey_attribute attrs[])
    int libssh2_publickey_add(LIBSSH2_PUBLICKEY *pkey,
                              const unsigned char *name,
                              const unsigned char *blob,
                              unsigned long blob_len, char overwrite,
                              unsigned long num_attrs,
                              const libssh2_publickey_attribute attrs[])
    int libssh2_publickey_remove_ex(LIBSSH2_PUBLICKEY *pkey,
                                    const unsigned char *name,
                                    unsigned long name_len,
                                    const unsigned char *blob,
                                    unsigned long blob_len)
    int libssh2_publickey_remove(LIBSSH2_PUBLICKEY *pkey,
                                 const unsigned char *name,
                                 const unsigned char *blob,
                                 unsigned long blob_len)
    int libssh2_publickey_list_fetch(LIBSSH2_PUBLICKEY *pkey,
                                     unsigned long *num_keys,
                                     libssh2_publickey_list **pkey_list)
    void libssh2_publickey_list_free(LIBSSH2_PUBLICKEY *pkey,
                                     libssh2_publickey_list *pkey_list)
    int libssh2_publickey_shutdown(LIBSSH2_PUBLICKEY *pkey)
