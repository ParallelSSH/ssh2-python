# This file is part of ssh2-python.
# Copyright (C) 2017-2020 Panos Kittenis
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
from c_stat cimport struct_stat


cdef extern from "libssh2.h" nogil:
    ctypedef long long libssh2_int64_t
    ctypedef int libssh2_socket_t
    ctypedef unsigned long long libssh2_uint64_t
    int libssh2_init(int flags)
    enum:
        LIBSSH2_SESSION_BLOCK_INBOUND
        LIBSSH2_SESSION_BLOCK_OUTBOUND
        LIBSSH2_VERSION_MAJOR
        LIBSSH2_VERSION_MINOR
        LIBSSH2_VERSION_PATCH
        LIBSSH2_CHANNEL_FLUSH_EXTENDED_DATA
        LIBSSH2_CHANNEL_FLUSH_ALL
        LIBSSH2_HOSTKEY_HASH_MD5
        LIBSSH2_HOSTKEY_HASH_SHA1
        LIBSSH2_HOSTKEY_TYPE_UNKNOWN
        LIBSSH2_HOSTKEY_TYPE_RSA
        LIBSSH2_HOSTKEY_TYPE_DSS
    IF EMBEDDED_LIB:
        enum:
            LIBSSH2_HOSTKEY_HASH_SHA256
            LIBSSH2_HOSTKEY_TYPE_ECDSA_256
            LIBSSH2_HOSTKEY_TYPE_ECDSA_384
            LIBSSH2_HOSTKEY_TYPE_ECDSA_521
            LIBSSH2_HOSTKEY_TYPE_ED25519
            LIBSSH2_METHOD_KEX
            LIBSSH2_METHOD_HOSTKEY
            LIBSSH2_METHOD_CRYPT_CS
            LIBSSH2_METHOD_CRYPT_SC
            LIBSSH2_METHOD_MAC_CS
            LIBSSH2_METHOD_MAC_SC
            LIBSSH2_METHOD_COMP_CS
            LIBSSH2_METHOD_COMP_SC
            LIBSSH2_METHOD_LANG_CS
            LIBSSH2_METHOD_LANG_SC

    ctypedef struct_stat libssh2_struct_stat
    ctypedef struct LIBSSH2_USERAUTH_KBDINT_PROMPT:
        char *text
        unsigned int length
        unsigned char echo
    ctypedef struct LIBSSH2_USERAUTH_KBDINT_RESPONSE:
        char *text
        unsigned int length
    ctypedef struct LIBSSH2_SESSION:
        pass
    ctypedef struct LIBSSH2_CHANNEL:
        pass
    ctypedef struct LIBSSH2_LISTENER:
        pass
    ctypedef struct LIBSSH2_KNOWNHOSTS:
        pass
    ctypedef struct LIBSSH2_AGENT:
        pass
    ctypedef struct LIBSSH2_POLLFD:
        unsigned char type
        # union fd:
        #     pass
        unsigned long events
        unsigned long revents
    int libssh2_init(int flags)
    void libssh2_exit()
    void libssh2_free(LIBSSH2_SESSION *session, void *ptr)
    int libssh2_session_supported_algs(LIBSSH2_SESSION* session,
                                       int method_type,
                                       const char*** algs)
    LIBSSH2_SESSION *libssh2_session_init_ex((void *),
                                             (void *),
                                             (void *),
                                             (void *))
    LIBSSH2_SESSION *libssh2_session_init()
    void **libssh2_session_abstract(LIBSSH2_SESSION *session)
    void *libssh2_session_callback_set(LIBSSH2_SESSION *session,
                                       int cbtype, void *callback)
    int libssh2_session_banner_set(LIBSSH2_SESSION *session,
                                   const char *banner)
    int libssh2_banner_set(LIBSSH2_SESSION *session,
                           const char *banner)
    int libssh2_session_startup(LIBSSH2_SESSION *session, int sock)
    int libssh2_session_handshake(LIBSSH2_SESSION *session,
                                  libssh2_socket_t sock)
    int libssh2_session_disconnect_ex(LIBSSH2_SESSION *session,
                                      int reason,
                                      const char *description,
                                      const char *lang)
    int libssh2_session_disconnect(LIBSSH2_SESSION *session,
                                   const char *description)
    int libssh2_session_free(LIBSSH2_SESSION *session)
    const char *libssh2_hostkey_hash(LIBSSH2_SESSION *session,
                                     int hash_type)
    const char *libssh2_session_hostkey(LIBSSH2_SESSION *session,
                                        size_t *len, int *type)
    int libssh2_session_method_pref(LIBSSH2_SESSION *session,
                                    int method_type,
                                    const char *prefs)
    const char *libssh2_session_methods(LIBSSH2_SESSION *session,
                                        int method_type)
    int libssh2_session_last_error(LIBSSH2_SESSION *session,
                                   char **errmsg,
                                   int *errmsg_len, int want_buf)
    int libssh2_session_last_errno(LIBSSH2_SESSION *session)
    int libssh2_session_set_last_error(LIBSSH2_SESSION* session,
                                       int errcode,
                                       const char* errmsg)
    int libssh2_session_block_directions(LIBSSH2_SESSION *session)
    int libssh2_session_flag(LIBSSH2_SESSION *session, int flag,
                             int value)
    const char *libssh2_session_banner_get(LIBSSH2_SESSION *session)
    char *libssh2_userauth_list(LIBSSH2_SESSION *session,
                                const char *username,
                                unsigned int username_len)
    int libssh2_userauth_authenticated(LIBSSH2_SESSION *session)
    int libssh2_userauth_password_ex(LIBSSH2_SESSION *session,
                                     const char *username,
                                     unsigned int username_len,
                                     const char *password,
                                     unsigned int password_len,
                                     (void *))
    int libssh2_userauth_password(LIBSSH2_SESSION *session,
                                  const char *username, const char *password)
    int libssh2_userauth_keyboard_interactive_ex(LIBSSH2_SESSION *session,
                                                 const char *username,
                                                 unsigned int username_len,
                                                 const char *password,
                                                 unsigned int password_len,
                                                 (void *))
    int libssh2_userauth_keyboard_interactive(LIBSSH2_SESSION *session,
                                              const char *username,
                                              (void *))
    int libssh2_userauth_publickey_fromfile_ex(LIBSSH2_SESSION *session,
                                               const char *username,
                                               unsigned int username_len,
                                               const char *publickey,
                                               const char *privatekey,
                                               const char *passphrase)
    int libssh2_userauth_publickey_fromfile(LIBSSH2_SESSION *session,
                                            const char *username,
                                            const char *publickey,
                                            const char *privatekey,
                                            const char *passphrase)
    int libssh2_userauth_publickey(LIBSSH2_SESSION *session,
                                   const char *username,
                                   const unsigned char *pubkeydata,
                                   size_t pubkeydata_len,
                                   (void *), (void *))
    int libssh2_userauth_hostbased_fromfile_ex(
        LIBSSH2_SESSION *session,
        const char *username,
        unsigned int username_len,
        const char *publickey,
        const char *privatekey,
        const char *passphrase,
        const char *hostname,
        unsigned int hostname_len,
        const char *local_username,
        unsigned int local_username_len)
    int libssh2_userauth_hostbased_fromfile(
        LIBSSH2_SESSION *session,
        const char *username,
        const char *publickey,
        const char *privatekey,
        const char *passphrase,
        const char *hostname)
    int libssh2_userauth_publickey_frommemory(
        LIBSSH2_SESSION *session,
        const char *username,
        size_t username_len,
        const char *publickeyfiledata,
        size_t publickeyfiledata_len,
        const char *privatekeyfiledata,
        size_t privatekeyfiledata_len,
        const char *passphrase)
    int libssh2_poll(LIBSSH2_POLLFD *fds, unsigned int nfds,
                     long timeout)
    enum:
        LIBSSH2_CHANNEL_WINDOW_DEFAULT
        LIBSSH2_CHANNEL_PACKET_DEFAULT
        LIBSSH2_CHANNEL_MINADJUST
        LIBSSH2_CHANNEL_EXTENDED_DATA_NORMAL
        LIBSSH2_CHANNEL_EXTENDED_DATA_IGNORE
        LIBSSH2_CHANNEL_EXTENDED_DATA_MERGE
        LIBSSH2CHANNEL_EAGAIN
        LIBSSH2_ERROR_EAGAIN
        SSH_EXTENDED_DATA_STDERR
    LIBSSH2_CHANNEL *libssh2_channel_open_ex(
        LIBSSH2_SESSION *session, const char *channel_type,
        unsigned int channel_type_len,
        unsigned int window_size, unsigned int packet_size,
        const char *message, unsigned int message_len)
    LIBSSH2_CHANNEL *libssh2_channel_open_session(LIBSSH2_SESSION *session)
    LIBSSH2_CHANNEL *libssh2_channel_direct_tcpip_ex(
        LIBSSH2_SESSION *session, const char *host,
        int port, const char *shost, int sport)
    LIBSSH2_CHANNEL *libssh2_channel_direct_tcpip(
        LIBSSH2_SESSION *session, const char *host,
        int port)
    LIBSSH2_LISTENER *libssh2_channel_forward_listen_ex(
        LIBSSH2_SESSION *session, const char *host,
        int port, int *bound_port, int queue_maxsize)
    LIBSSH2_LISTENER *libssh2_channel_forward_listen(
        LIBSSH2_SESSION *session, int port)
    int libssh2_channel_forward_cancel(LIBSSH2_LISTENER *listener)
    LIBSSH2_CHANNEL *libssh2_channel_forward_accept(
        LIBSSH2_LISTENER *listener)
    int libssh2_channel_setenv_ex(LIBSSH2_CHANNEL *channel,
                                  const char *varname,
                                  unsigned int varname_len,
                                  const char *value,
                                  unsigned int value_len)
    int libssh2_channel_setenv(LIBSSH2_CHANNEL *channel,
                               const char *varname,
                               const char *value)
    int libssh2_channel_request_pty_ex(LIBSSH2_CHANNEL *channel,
                                       const char *term,
                                       unsigned int term_len,
                                       const char *modes,
                                       unsigned int modes_len,
                                       int width, int height,
                                       int width_px, int height_px)
    int libssh2_channel_request_pty(LIBSSH2_CHANNEL *channel,
                                    const char *term)
    int libssh2_channel_request_pty_size_ex(LIBSSH2_CHANNEL *channel,
                                            int width, int height,
                                            int width_px,
                                            int height_px)
    int libssh2_channel_request_pty_size(LIBSSH2_CHANNEL *channel,
                                         int width, int height)
    int libssh2_channel_x11_req_ex(LIBSSH2_CHANNEL *channel,
                                   int single_connection,
                                   const char *auth_proto,
                                   const char *auth_cookie,
                                   int screen_number)
    int libssh2_channel_x11_req(LIBSSH2_CHANNEL *channel,
                                int screen_number)
    int libssh2_channel_process_startup(LIBSSH2_CHANNEL *channel,
                                        const char *request,
                                        unsigned int request_len,
                                        const char *message,
                                        unsigned int message_len)
    int libssh2_channel_shell(LIBSSH2_CHANNEL *channel)
    int libssh2_channel_exec(LIBSSH2_CHANNEL *channel,
                             const char *command)
    int libssh2_channel_subsystem(LIBSSH2_CHANNEL *channel,
                                  const char *subsystem)
    ssize_t libssh2_channel_read_ex(LIBSSH2_CHANNEL *channel,
                                    int stream_id, char *buf,
                                    size_t buflen)
    ssize_t libssh2_channel_read(LIBSSH2_CHANNEL *channel,
                                 char *buf,
                                 size_t buflen)
    ssize_t libssh2_channel_read_stderr(LIBSSH2_CHANNEL *channel,
                                        char *buf,
                                        size_t buflen)
    int libssh2_poll_channel_read(LIBSSH2_CHANNEL *channel,
                                  int extended)
    unsigned long \
        libssh2_channel_window_read_ex(LIBSSH2_CHANNEL *channel,
                                       unsigned long *read_avail,
                                       unsigned long *window_size_initial)
    unsigned long libssh2_channel_window_read(LIBSSH2_CHANNEL *channel)
    unsigned long \
        libssh2_channel_receive_window_adjust(LIBSSH2_CHANNEL *channel,
                                              unsigned long adjustment,
                                              unsigned char force)
    int \
        libssh2_channel_receive_window_adjust2(LIBSSH2_CHANNEL *channel,
                                               unsigned long adjustment,
                                               unsigned char force,
                                               unsigned int *storewindow)
    ssize_t libssh2_channel_write_ex(LIBSSH2_CHANNEL *channel,
                                     int stream_id, const char *buf,
                                     size_t buflen)
    ssize_t libssh2_channel_write(LIBSSH2_CHANNEL *channel,
                                  char *buf, size_t buflen)
    ssize_t libssh2_channel_write_stderr(LIBSSH2_CHANNEL *channel,
                                         char *buf, size_t buflen)
    unsigned long \
        libssh2_channel_window_write_ex(LIBSSH2_CHANNEL *channel,
                                        unsigned long *window_size_initial)
    unsigned long libssh2_channel_window_write(LIBSSH2_CHANNEL *channel)
    void libssh2_session_set_blocking(LIBSSH2_SESSION* session,
                                      int blocking)
    int libssh2_session_get_blocking(LIBSSH2_SESSION* session)
    void libssh2_channel_set_blocking(LIBSSH2_CHANNEL *channel,
                                      int blocking)
    void libssh2_session_set_timeout(LIBSSH2_SESSION* session,
                                     long timeout)
    long libssh2_session_get_timeout(LIBSSH2_SESSION* session)
    void libssh2_channel_handle_extended_data(LIBSSH2_CHANNEL *channel,
                                              int ignore_mode)
    int libssh2_channel_handle_extended_data2(LIBSSH2_CHANNEL *channel,
                                              int ignore_mode)
    int libssh2_channel_ignore_extended_data(LIBSSH2_CHANNEL *channel,
                                             int ignore)
    int libssh2_channel_flush_ex(LIBSSH2_CHANNEL *channel,
                                 int streamid)
    int libssh2_channel_flush(LIBSSH2_CHANNEL *channel)
    int libssh2_channel_flush_stderr(LIBSSH2_CHANNEL *channel)
    int libssh2_channel_get_exit_status(LIBSSH2_CHANNEL* channel)
    int libssh2_channel_get_exit_signal(LIBSSH2_CHANNEL* channel,
                                        char **exitsignal,
                                        size_t *exitsignal_len,
                                        char **errmsg,
                                        size_t *errmsg_len,
                                        char **langtag,
                                        size_t *langtag_len)
    int libssh2_channel_send_eof(LIBSSH2_CHANNEL *channel)
    int libssh2_channel_eof(LIBSSH2_CHANNEL *channel)
    int libssh2_channel_wait_eof(LIBSSH2_CHANNEL *channel)
    int libssh2_channel_close(LIBSSH2_CHANNEL *channel)
    int libssh2_channel_wait_closed(LIBSSH2_CHANNEL *channel)
    int libssh2_channel_free(LIBSSH2_CHANNEL *channel)

    # libssh2_scp_recv is DEPRECATED, do not use!
    LIBSSH2_CHANNEL *libssh2_scp_recv(LIBSSH2_SESSION *session,
                                      const char *path,
                                      struct_stat *sb)
    # Use libssh2_scp_recv2 for large (> 2GB) file support on windows
    LIBSSH2_CHANNEL *libssh2_scp_recv2(LIBSSH2_SESSION *session,
                                       const char *path,
                                       libssh2_struct_stat *sb)
    LIBSSH2_CHANNEL *libssh2_scp_send_ex(LIBSSH2_SESSION *session,
                                         const char *path, int mode,
                                         size_t size, long mtime,
                                         long atime)
    LIBSSH2_CHANNEL *libssh2_scp_send64(
        LIBSSH2_SESSION *session, const char *path, int mode,
        libssh2_int64_t size, time_t mtime, time_t atime)
    LIBSSH2_CHANNEL *libssh2_scp_send(
        LIBSSH2_SESSION *session,
        const char *path, int mode,
        libssh2_int64_t size)
    int libssh2_base64_decode(LIBSSH2_SESSION *session, char **dest,
                              unsigned int *dest_len,
                              const char *src, unsigned int src_len)
    const char *libssh2_version(int req_version_num)

    # Known host API
    struct libssh2_knownhost:
        unsigned int magic
        void *node
        char *name
        char *key
        int typemask
    LIBSSH2_KNOWNHOSTS *libssh2_knownhost_init(LIBSSH2_SESSION *session)
    int libssh2_knownhost_add(LIBSSH2_KNOWNHOSTS *hosts,
                              const char *host,
                              const char *salt,
                              const char *key, size_t keylen, int typemask,
                              libssh2_knownhost **store)
    int libssh2_knownhost_addc(
        LIBSSH2_KNOWNHOSTS *hosts,
        const char *host,
        const char *salt,
        const char *key, size_t keylen,
        const char *comment, size_t commentlen, int typemask,
        libssh2_knownhost **store)
    int libssh2_knownhost_check(LIBSSH2_KNOWNHOSTS *hosts,
                                const char *host, const char *key,
                                size_t keylen, int typemask,
                                libssh2_knownhost **knownhost)
    int libssh2_knownhost_checkp(LIBSSH2_KNOWNHOSTS *hosts,
                                 const char *host, int port,
                                 const char *key, size_t keylen,
                                 int typemask,
                                 libssh2_knownhost **knownhost)
    int libssh2_knownhost_del(LIBSSH2_KNOWNHOSTS *hosts,
                              libssh2_knownhost *entry)
    void libssh2_knownhost_free(LIBSSH2_KNOWNHOSTS *hosts)
    int libssh2_knownhost_readline(LIBSSH2_KNOWNHOSTS *hosts,
                                   const char *line, size_t len, int type)
    int libssh2_knownhost_readfile(LIBSSH2_KNOWNHOSTS *hosts,
                                   const char *filename, int type)
    int libssh2_knownhost_writeline(LIBSSH2_KNOWNHOSTS *hosts,
                                    libssh2_knownhost *known,
                                    char *buffer, size_t buflen,
                                    size_t *outlen,
                                    int type)
    int libssh2_knownhost_writefile(LIBSSH2_KNOWNHOSTS *hosts,
                                    const char *filename, int type)
    int libssh2_knownhost_get(LIBSSH2_KNOWNHOSTS *hosts,
                              libssh2_knownhost **store,
                              libssh2_knownhost *prev)
    enum:
        LIBSSH2_KNOWNHOST_FILE_OPENSSH
        LIBSSH2_KNOWNHOST_CHECK_MATCH
        LIBSSH2_KNOWNHOST_CHECK_MISMATCH
        LIBSSH2_KNOWNHOST_CHECK_NOTFOUND
        LIBSSH2_KNOWNHOST_CHECK_FAILURE
        LIBSSH2_KNOWNHOST_TYPE_MASK
        LIBSSH2_KNOWNHOST_TYPE_PLAIN
        LIBSSH2_KNOWNHOST_TYPE_SHA1
        LIBSSH2_KNOWNHOST_TYPE_CUSTOM
        LIBSSH2_KNOWNHOST_KEYENC_MASK
        LIBSSH2_KNOWNHOST_KEYENC_RAW
        LIBSSH2_KNOWNHOST_KEYENC_BASE64
        LIBSSH2_KNOWNHOST_KEY_MASK
        LIBSSH2_KNOWNHOST_KEY_SHIFT
        LIBSSH2_KNOWNHOST_KEY_RSA1
        LIBSSH2_KNOWNHOST_KEY_SSHRSA
        LIBSSH2_KNOWNHOST_KEY_SSHDSS
    IF EMBEDDED_LIB:
        enum:
            LIBSSH2_KNOWNHOST_KEY_ECDSA_256
            LIBSSH2_KNOWNHOST_KEY_ECDSA_384
            LIBSSH2_KNOWNHOST_KEY_ECDSA_521
            LIBSSH2_KNOWNHOST_KEY_ED25519
            LIBSSH2_KNOWNHOST_KEY_UNKNOWN

    # Public Key API
    struct libssh2_agent_publickey:
        unsigned int magic
        void *node
        unsigned char *blob
        size_t blob_len
        char *comment
    LIBSSH2_AGENT *libssh2_agent_init(LIBSSH2_SESSION *session)
    int libssh2_agent_connect(LIBSSH2_AGENT *agent)
    int libssh2_agent_list_identities(LIBSSH2_AGENT *agent)
    int libssh2_agent_get_identity(LIBSSH2_AGENT *agent,
                                   libssh2_agent_publickey **store,
                                   libssh2_agent_publickey *prev)
    int libssh2_agent_userauth(LIBSSH2_AGENT *agent,
                               const char *username,
                               libssh2_agent_publickey *identity)
    int libssh2_agent_disconnect(LIBSSH2_AGENT *agent)
    void libssh2_agent_free(LIBSSH2_AGENT *agent)
    void libssh2_keepalive_config(LIBSSH2_SESSION *session,
                                  int want_reply,
                                  unsigned interval)
    int libssh2_keepalive_send(LIBSSH2_SESSION *session,
                               int *seconds_to_next)
    int libssh2_trace(LIBSSH2_SESSION *session, int bitmask)
    ctypedef void(*libssh2_trace_handler_func)(LIBSSH2_SESSION*,
                                               void*,
                                               const char *,
                                               size_t)
    int libssh2_trace_sethandler(LIBSSH2_SESSION *session,
                                 void* context,
                                 libssh2_trace_handler_func callback)
    const char *libssh2_agent_get_identity_path(LIBSSH2_AGENT *agent)
    void libssh2_agent_set_identity_path(LIBSSH2_AGENT *agent,
                                         const char *path)
    void libssh2_free(LIBSSH2_SESSION *session, void *ptr)
    IF HAVE_AGENT_FWD:
        int libssh2_channel_request_auth_agent(LIBSSH2_CHANNEL *channel)
