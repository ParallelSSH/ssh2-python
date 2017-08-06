from posix.stat cimport struct_stat


cdef class StatInfo:
    """Representation of stat structure - older version"""
    cdef struct_stat* _stat
