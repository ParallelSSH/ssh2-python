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

from libc.time cimport time_t
from posix.types cimport blkcnt_t, blksize_t, dev_t, gid_t, ino_t, \
    nlink_t, off_t, time_t, uid_t, mode_t


cdef extern from "<sys/stat.h>" nogil:
    cdef struct struct_stat "stat":
        dev_t   st_dev
        ino_t   st_ino
        mode_t  st_mode
        nlink_t st_nlink
        uid_t   st_uid
        gid_t   st_gid
        dev_t   st_rdev
        off_t   st_size
        blksize_t st_blksize
        blkcnt_t st_blocks
        time_t  st_atime
        time_t  st_mtime
        time_t  st_ctime
