cdef bytes to_bytes(_str)
cdef object to_str(char *c_str)
cdef object to_str_len(char *c_str, int length)
cpdef int handle_error_codes(int errcode) except -1
cdef extern from "readline.h" nogil:
    char* c_read_line "read_line" (char* data)
