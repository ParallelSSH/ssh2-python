cimport c_ssh2

cdef class FileInfo:
    """Representation of stat structure"""
    cdef c_ssh2.libssh2_struct_stat* _stat
