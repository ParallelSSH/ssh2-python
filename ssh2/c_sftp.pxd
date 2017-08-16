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

from c_ssh2 cimport LIBSSH2_SESSION, LIBSSH2_CHANNEL, libssh2_uint64_t


cdef extern from "libssh2_sftp.h" nogil:
    ctypedef struct LIBSSH2_SFTP:
        pass
    ctypedef struct LIBSSH2_SFTP_HANDLE:
        pass
    ctypedef struct LIBSSH2_SFTP_ATTRIBUTES:
        unsigned long flags
        libssh2_uint64_t filesize
        unsigned long uid, gid
        unsigned long permissions
        unsigned long atime, mtime
    # SFTP statvfs flag bits
    enum:
        LIBSSH2_SFTP_ST_RDONLY
        LIBSSH2_SFTP_ST_NOSUID
    ctypedef struct LIBSSH2_SFTP_STATVFS:
        libssh2_uint64_t  f_bsize    # file system block size
        libssh2_uint64_t  f_frsize   # fragment size
        libssh2_uint64_t  f_blocks   # size of fs in f_frsize units
        libssh2_uint64_t  f_bfree    # free blocks
        libssh2_uint64_t  f_bavail   # free blocks for non-root
        libssh2_uint64_t  f_files    # inodes
        libssh2_uint64_t  f_ffree    # free inodes
        libssh2_uint64_t  f_favail   # free inodes for non-root
        libssh2_uint64_t  f_fsid     # file system ID
        libssh2_uint64_t  f_flag     # mount flags
        libssh2_uint64_t  f_namemax  # maximum filename length
    # SFTP File types
    enum:
        LIBSSH2_SFTP_S_IFMT         # type of file mask
        LIBSSH2_SFTP_S_IFIFO        # named pipe (fifo)
        LIBSSH2_SFTP_S_IFCHR        # character special
        LIBSSH2_SFTP_S_IFDIR        # directory
        LIBSSH2_SFTP_S_IFBLK        # block special
        LIBSSH2_SFTP_S_IFREG        # regular
        LIBSSH2_SFTP_S_IFLNK        # symbolic link
        LIBSSH2_SFTP_S_IFSOCK       # socket
    # SFTP File Transfer Flags
    enum:
        LIBSSH2_FXF_READ
        LIBSSH2_FXF_WRITE
        LIBSSH2_FXF_APPEND
        LIBSSH2_FXF_CREAT
        LIBSSH2_FXF_TRUNC
        LIBSSH2_FXF_EXCL
    # SFTP File modes
    enum:
        # Read, write, execute/search by owner
        LIBSSH2_SFTP_S_IRWXU        # RWX mask for owner
        LIBSSH2_SFTP_S_IRUSR        # R for owner
        LIBSSH2_SFTP_S_IWUSR        # W for owner
        LIBSSH2_SFTP_S_IXUSR        # X for owner
        # Read, write, execute/search by group
        LIBSSH2_SFTP_S_IRWXG        # RWX mask for group
        LIBSSH2_SFTP_S_IRGRP        # R for group
        LIBSSH2_SFTP_S_IWGRP        # W for group
        LIBSSH2_SFTP_S_IXGRP        # X for group
        # Read, write, execute/search by others
        LIBSSH2_SFTP_S_IRWXO        # RWX mask for other
        LIBSSH2_SFTP_S_IROTH        # R for other
        LIBSSH2_SFTP_S_IWOTH        # W for other
        LIBSSH2_SFTP_S_IXOTH        # X for other
    int LIBSSH2_SFTP_S_ISLNK(unsigned long m)
    int LIBSSH2_SFTP_S_ISREG(unsigned long m)
    int LIBSSH2_SFTP_S_ISDIR(unsigned long m)
    int LIBSSH2_SFTP_S_ISCHR(unsigned long m)
    int LIBSSH2_SFTP_S_ISBLK(unsigned long m)
    int LIBSSH2_SFTP_S_ISFIFO(unsigned long m)
    int LIBSSH2_SFTP_S_ISSOCK(unsigned long m)
    LIBSSH2_SFTP *libssh2_sftp_init(LIBSSH2_SESSION *session)
    int libssh2_sftp_shutdown(LIBSSH2_SFTP *sftp)
    unsigned long libssh2_sftp_last_error(LIBSSH2_SFTP *sftp)
    LIBSSH2_CHANNEL *libssh2_sftp_get_channel(LIBSSH2_SFTP *sftp)
    LIBSSH2_SFTP_HANDLE *libssh2_sftp_open_ex(LIBSSH2_SFTP *sftp,
                                              const char *filename,
                                              unsigned int filename_len,
                                              unsigned long flags,
                                              long mode, int open_type)
    LIBSSH2_SFTP_HANDLE *libssh2_sftp_open(
        LIBSSH2_SFTP *sftp, const char *filename,
        unsigned long flags, long mode)
    LIBSSH2_SFTP_HANDLE *libssh2_sftp_opendir(
        LIBSSH2_SFTP *sftp, const char *path)
    ssize_t libssh2_sftp_read(LIBSSH2_SFTP_HANDLE *handle,
                              char *buffer, size_t buffer_maxlen)
    int libssh2_sftp_readdir_ex(LIBSSH2_SFTP_HANDLE *handle,
                                char *buffer, size_t buffer_maxlen,
                                char *longentry,
                                size_t longentry_maxlen,
                                LIBSSH2_SFTP_ATTRIBUTES *attrs)
    int libssh2_sftp_readdir(LIBSSH2_SFTP_HANDLE *handle, char *buffer,
                             size_t buffer_maxlen,
                             LIBSSH2_SFTP_ATTRIBUTES *attrs)
    ssize_t libssh2_sftp_write(LIBSSH2_SFTP_HANDLE *handle,
                               const char *buffer, size_t count)
    int libssh2_sftp_fsync(LIBSSH2_SFTP_HANDLE *handle)
    int libssh2_sftp_close_handle(LIBSSH2_SFTP_HANDLE *handle)
    int libssh2_sftp_close(LIBSSH2_SFTP_HANDLE *handle)
    int libssh2_sftp_closedir(LIBSSH2_SFTP_HANDLE *handle)
    void libssh2_sftp_seek(LIBSSH2_SFTP_HANDLE *handle, size_t offset)
    void libssh2_sftp_seek64(LIBSSH2_SFTP_HANDLE *handle,
                             libssh2_uint64_t offset)
    void libssh2_sftp_rewind(LIBSSH2_SFTP_HANDLE *handle)
    size_t libssh2_sftp_tell(LIBSSH2_SFTP_HANDLE *handle)
    libssh2_uint64_t libssh2_sftp_tell64(LIBSSH2_SFTP_HANDLE *handle)
    int libssh2_sftp_fstat_ex(LIBSSH2_SFTP_HANDLE *handle,
                              LIBSSH2_SFTP_ATTRIBUTES *attrs,
                              int setstat)
    int libssh2_sftp_fstat(LIBSSH2_SFTP_HANDLE *handle,
                           LIBSSH2_SFTP_ATTRIBUTES *attrs)
    int libssh2_sftp_fsetstat(LIBSSH2_SFTP_HANDLE *handle,
                              LIBSSH2_SFTP_ATTRIBUTES *attrs)
    int libssh2_sftp_rename_ex(LIBSSH2_SFTP *sftp,
                               const char *source_filename,
                               unsigned int srouce_filename_len,
                               const char *dest_filename,
                               unsigned int dest_filename_len,
                               long flags)
    int libssh2_sftp_rename(LIBSSH2_SFTP *sftp,
                            const char *sourcefile,
                            const char *destfile)
    int libssh2_sftp_unlink_ex(LIBSSH2_SFTP *sftp,
                               const char *filename,
                               unsigned int filename_len)
    int libssh2_sftp_unlink(LIBSSH2_SFTP *sftp, const char *filename)
    int libssh2_sftp_fstatvfs(LIBSSH2_SFTP_HANDLE *handle,
                              LIBSSH2_SFTP_STATVFS *st)
    int libssh2_sftp_statvfs(LIBSSH2_SFTP *sftp,
                             const char *path,
                             size_t path_len,
                             LIBSSH2_SFTP_STATVFS *st)
    int libssh2_sftp_mkdir_ex(LIBSSH2_SFTP *sftp,
                              const char *path,
                              unsigned int path_len, long mode)
    int libssh2_sftp_mkdir(LIBSSH2_SFTP *sftp,
                           const char *path,
                           long mode)
    int libssh2_sftp_rmdir_ex(LIBSSH2_SFTP *sftp,
                              const char *path,
                              unsigned int path_len)
    int libssh2_sftp_rmdir(LIBSSH2_SFTP *sftp, const char *path)
    int libssh2_sftp_stat_ex(LIBSSH2_SFTP *sftp,
                             const char *path,
                             unsigned int path_len,
                             int stat_type,
                             LIBSSH2_SFTP_ATTRIBUTES *attrs)
    int libssh2_sftp_stat(LIBSSH2_SFTP *sftp, const char *path,
                          LIBSSH2_SFTP_ATTRIBUTES *attrs)
    int libssh2_sftp_lstat(LIBSSH2_SFTP *sftp, const char *path,
                           LIBSSH2_SFTP_ATTRIBUTES *attrs)
    int libssh2_sftp_setstat(LIBSSH2_SFTP *sftp, const char *path,
                             LIBSSH2_SFTP_ATTRIBUTES *attrs)
    int libssh2_sftp_symlink_ex(LIBSSH2_SFTP *sftp,
                                const char *path,
                                unsigned int path_len,
                                char *target,
                                unsigned int target_len, int link_type)
    int libssh2_sftp_symlink(LIBSSH2_SFTP *sftp,
                             const char *orig,
                             char *linkpath)
    int libssh2_sftp_readlink(LIBSSH2_SFTP *sftp, const char *path,
                              char *target, unsigned int maxlen)
    int libssh2_sftp_realpath(LIBSSH2_SFTP *sftp, const char *path,
                              char *target, unsigned int maxlen)
