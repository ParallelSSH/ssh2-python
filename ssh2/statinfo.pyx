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
from c_stat cimport struct_stat


cdef class StatInfo:
    """Representation of stat structure - libssh2 <1.7 version"""

    def __cinit__(self):
        with nogil:
            self._stat = <struct_stat *>malloc(
                sizeof(struct_stat))
            if self._stat is NULL:
                with gil:
                    raise MemoryError

    def __dealloc__(self):
        free(self._stat)

    @property
    def st_size(self):
        return self._stat.st_size

    IF UNAME_SYSNAME != "Windows":
        @property
        def st_ino(self):
            return self._stat.st_ino

        @property
        def st_mode(self):
            return self._stat.st_mode

        @property
        def st_nlink(self):
            return self._stat.st_nlink

        @property
        def st_uid(self):
            return self._stat.st_uid

        @property
        def st_gid(self):
            return self._stat.st_gid

        @property
        def st_rdev(self):
            return self._stat.st_rdev

        @property
        def st_blksize(self):
            return self._stat.st_blksize

        @property
        def st_blocks(self):
            return self._stat.st_blocks

        @property
        def st_atime(self):
            return self._stat.st_atime

        @property
        def st_mtime(self):
            return self._stat.st_mtime

        @property
        def st_ctime(self):
            return self._stat.st_ctime
