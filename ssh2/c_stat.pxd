# This file is part of ssh2-python.
# Copyright (C) 2017 Panos Kittenis
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation, version 2.1.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

from libc.time cimport time_t


cdef extern from "<sys/stat.h>" nogil:
    cdef struct struct_stat "stat":
        long   st_dev
        unsigned long   st_ino
        unsigned long  st_mode
        long st_nlink
        long   st_uid
        long   st_gid
        long   st_rdev
        unsigned long long   st_size
        long st_blksize
        long st_blocks
        time_t  st_atime
        time_t  st_mtime
        time_t  st_ctime
