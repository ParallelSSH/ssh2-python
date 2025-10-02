# This file is part of ssh2-python.
# Copyright (C) 2017-2025 Panos Kittenis
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

from .c_ssh2 cimport (LIBSSH2_FLAG_SIGPIPE, LIBSSH2_FLAG_COMPRESS, LIBSSH2_FLAG_QUOTE_PATHS,
                      LIBSSH2_SK_PRESENCE_REQUIRED, LIBSSH2_SK_VERIFICATION_REQUIRED)
from .flags cimport FlagType


cdef class FlagType:
    def __cinit__(self, value):
        self.value = value


FLAG_SIGPIPE = FlagType(LIBSSH2_FLAG_SIGPIPE)
FLAG_COMPRESS = FlagType(LIBSSH2_FLAG_COMPRESS)
FLAG_QUOTE_PATHS = FlagType(LIBSSH2_FLAG_QUOTE_PATHS)
FLAG_SK_PRESENCE_REQUIRED = FlagType(LIBSSH2_SK_PRESENCE_REQUIRED)
FLAG_SK_VERIFICATION_REQUIRED = FlagType(LIBSSH2_SK_VERIFICATION_REQUIRED)
