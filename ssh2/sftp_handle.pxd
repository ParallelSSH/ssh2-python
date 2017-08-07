cimport c_sftp
from sftp cimport SFTP


cdef object PySFTPHandle(c_sftp.LIBSSH2_SFTP_HANDLE *handle, SFTP sftp)


cdef class SFTPHandle:
    cdef c_sftp.LIBSSH2_SFTP_HANDLE *_handle
    cdef SFTP _sftp
    cdef bint closed


cdef class SFTPAttributes:
    cdef c_sftp.LIBSSH2_SFTP_ATTRIBUTES *_attrs


cdef class SFTPStatVFS:
    cdef c_sftp.LIBSSH2_SFTP_STATVFS *_ptr
    cdef object _sftp_ref
