cimport c_ssh2

IF EMBEDDED_LIB:
    cdef class FileInfo:
        """Representation of stat structure"""
        cdef c_ssh2.libssh2_struct_stat* _stat
