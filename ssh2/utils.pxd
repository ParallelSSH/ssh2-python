cdef extern from "find_eol.h" nogil:
    int c_find_eol "find_eol" (char* data, int* new_pos)
cdef bytes to_bytes(_str)
cdef object to_str(char *c_str)
cdef object to_str_len(char *c_str, int length)
cpdef int handle_error_codes(int errcode) except -1
