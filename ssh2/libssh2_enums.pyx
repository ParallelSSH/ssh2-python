# This file is part of ssh2-python.
# Copyright (C) 2020 Red_M

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

import enum

cimport error_codes
cimport c_ssh2
cimport c_sftp


class Session(enum.Enum):
    BLOCK_INBOUND = c_ssh2.LIBSSH2_SESSION_BLOCK_INBOUND
    BLOCK_OUTBOUND = c_ssh2.LIBSSH2_SESSION_BLOCK_OUTBOUND


class Hostkey(enum.Enum):
    HASH_MD5 = c_ssh2.LIBSSH2_HOSTKEY_HASH_MD5
    HASH_SHA1 = c_ssh2.LIBSSH2_HOSTKEY_HASH_SHA1
    TYPE_UNKNOWN = c_ssh2.LIBSSH2_HOSTKEY_TYPE_UNKNOWN
    TYPE_RSA = c_ssh2.LIBSSH2_HOSTKEY_TYPE_RSA
    TYPE_DSS = c_ssh2.LIBSSH2_HOSTKEY_TYPE_DSS
    TYPE_ECDSA_256 = c_ssh2.LIBSSH2_HOSTKEY_TYPE_ECDSA_256
    TYPE_ECDSA_384 = c_ssh2.LIBSSH2_HOSTKEY_TYPE_ECDSA_384
    TYPE_ECDSA_521 = c_ssh2.LIBSSH2_HOSTKEY_TYPE_ECDSA_521
    TYPE_ED25519 = c_ssh2.LIBSSH2_HOSTKEY_TYPE_ED25519


class Callback(enum.Enum):
    RECV = c_ssh2.LIBSSH2_CALLBACK_RECV
    SEND = c_ssh2.LIBSSH2_CALLBACK_SEND
    X11 = c_ssh2.LIBSSH2_CALLBACK_X11


class Method(enum.Enum):
    KEX = c_ssh2.LIBSSH2_METHOD_KEX
    HOSTKEY = c_ssh2.LIBSSH2_METHOD_HOSTKEY
    CRYPT_CS = c_ssh2.LIBSSH2_METHOD_CRYPT_CS
    CRYPT_SC = c_ssh2.LIBSSH2_METHOD_CRYPT_SC
    MAC_CS = c_ssh2.LIBSSH2_METHOD_MAC_CS
    MAC_SC = c_ssh2.LIBSSH2_METHOD_MAC_SC
    COMP_CS = c_ssh2.LIBSSH2_METHOD_COMP_CS
    COMP_SC = c_ssh2.LIBSSH2_METHOD_COMP_SC
    LANG_CS = c_ssh2.LIBSSH2_METHOD_LANG_CS
    LANG_SC = c_ssh2.LIBSSH2_METHOD_LANG_SC


class Flag(enum.Enum):
    SIGPIPE = c_ssh2.LIBSSH2_FLAG_SIGPIPE
    COMPRESS = c_ssh2.LIBSSH2_FLAG_COMPRESS


class SFTP(enum.Enum):
    # Type of file mask
    S_IFMT = c_sftp.LIBSSH2_SFTP_S_IFMT
    # named pipe (fifo)
    S_IFIFO = c_sftp.LIBSSH2_SFTP_S_IFIFO
    # character special
    S_IFCHR = c_sftp.LIBSSH2_SFTP_S_IFCHR
    # directory
    S_IFDIR = c_sftp.LIBSSH2_SFTP_S_IFDIR
    # block special (block device)
    S_IFBLK = c_sftp.LIBSSH2_SFTP_S_IFBLK
    # regular
    S_IFREG = c_sftp.LIBSSH2_SFTP_S_IFREG
    # symbolic link
    S_IFLNK = c_sftp.LIBSSH2_SFTP_S_IFLNK
    # socket
    S_IFSOCK = c_sftp.LIBSSH2_SFTP_S_IFSOCK

    # File Transfer Flags
    FXF_READ = c_sftp.LIBSSH2_FXF_READ
    FXF_WRITE = c_sftp.LIBSSH2_FXF_WRITE
    FXF_APPEND = c_sftp.LIBSSH2_FXF_APPEND
    FXF_CREAT = c_sftp.LIBSSH2_FXF_CREAT
    FXF_TRUNC = c_sftp.LIBSSH2_FXF_TRUNC
    FXF_EXCL = c_sftp.LIBSSH2_FXF_EXCL

    # File mode masks
    # Read, write, execute/search by owner
    S_IRWXU = c_sftp.LIBSSH2_SFTP_S_IRWXU
    S_IRUSR = c_sftp.LIBSSH2_SFTP_S_IRUSR
    S_IWUSR = c_sftp.LIBSSH2_SFTP_S_IWUSR
    S_IXUSR = c_sftp.LIBSSH2_SFTP_S_IXUSR
    # Read, write, execute/search by group
    S_IRWXG = c_sftp.LIBSSH2_SFTP_S_IRWXG
    S_IRGRP = c_sftp.LIBSSH2_SFTP_S_IRGRP
    S_IWGRP = c_sftp.LIBSSH2_SFTP_S_IWGRP
    S_IXGRP = c_sftp.LIBSSH2_SFTP_S_IXGRP
    # Read, write, execute/search by others
    S_IRWXO = c_sftp.LIBSSH2_SFTP_S_IRWXO
    S_IROTH = c_sftp.LIBSSH2_SFTP_S_IROTH
    S_IWOTH = c_sftp.LIBSSH2_SFTP_S_IWOTH
    S_IXOTH = c_sftp.LIBSSH2_SFTP_S_IXOTH

    # Read only
    ST_RDONLY = c_sftp.LIBSSH2_SFTP_ST_RDONLY
    # No suid
    ST_NOSUID = c_sftp.LIBSSH2_SFTP_ST_NOSUID


class KnownHost(enum.Enum):
    # Host format type masks
    TYPE_MASK = c_ssh2.LIBSSH2_KNOWNHOST_TYPE_MASK
    TYPE_PLAIN = c_ssh2.LIBSSH2_KNOWNHOST_TYPE_PLAIN
    TYPE_SHA1 = c_ssh2.LIBSSH2_KNOWNHOST_TYPE_SHA1
    TYPE_CUSTOM = c_ssh2.LIBSSH2_KNOWNHOST_TYPE_CUSTOM

    # Key format type masks
    KEYENC_MASK = c_ssh2.LIBSSH2_KNOWNHOST_KEYENC_MASK
    KEYENC_RAW = c_ssh2.LIBSSH2_KNOWNHOST_KEYENC_RAW
    KEYENC_BASE64 = c_ssh2.LIBSSH2_KNOWNHOST_KEYENC_BASE64

    # Key type masks
    KEY_MASK = c_ssh2.LIBSSH2_KNOWNHOST_KEY_MASK
    KEY_SHIFT = c_ssh2.LIBSSH2_KNOWNHOST_KEY_SHIFT
    KEY_RSA1 = c_ssh2.LIBSSH2_KNOWNHOST_KEY_RSA1
    KEY_SSHRSA = c_ssh2.LIBSSH2_KNOWNHOST_KEY_SSHRSA
    KEY_SSHDSS = c_ssh2.LIBSSH2_KNOWNHOST_KEY_SSHDSS
    IF EMBEDDED_LIB:
        KEY_UNKNOWN = c_ssh2.LIBSSH2_KNOWNHOST_KEY_UNKNOWN


class ErrorCodes(enum.Enum):
    NONE = error_codes._LIBSSH2_ERROR_NONE
    SOCKET_NONE = error_codes._LIBSSH2_ERROR_SOCKET_NONE
    BANNER_RECV = error_codes._LIBSSH2_ERROR_BANNER_RECV
    BANNER_SEND = error_codes._LIBSSH2_ERROR_BANNER_SEND
    KEY_EXCHANGE_FAILURE \
        = error_codes._LIBSSH2_ERROR_KEY_EXCHANGE_FAILURE
    TIMEOUT = error_codes._LIBSSH2_ERROR_TIMEOUT
    HOSTKEY_INIT = error_codes._LIBSSH2_ERROR_HOSTKEY_INIT
    HOSTKEY_SIGN = error_codes._LIBSSH2_ERROR_HOSTKEY_SIGN
    DECRYPT = error_codes._LIBSSH2_ERROR_DECRYPT
    SOCKET_DISCONNECT = error_codes._LIBSSH2_ERROR_SOCKET_DISCONNECT
    PROTO = error_codes._LIBSSH2_ERROR_PROTO
    PASSWORD_EXPIRED = error_codes._LIBSSH2_ERROR_PASSWORD_EXPIRED
    FILE = error_codes._LIBSSH2_ERROR_FILE
    METHOD_NONE \
        = error_codes._LIBSSH2_ERROR_METHOD_NONE
    AUTHENTICATION_FAILED \
        = error_codes._LIBSSH2_ERROR_AUTHENTICATION_FAILED
    PUBLICKEY_UNRECOGNIZED \
        = error_codes._LIBSSH2_ERROR_PUBLICKEY_UNRECOGNIZED
    PUBLICKEY_UNVERIFIED \
        = error_codes._LIBSSH2_ERROR_PUBLICKEY_UNVERIFIED
    CHANNEL_OUTOFORDER = error_codes._LIBSSH2_ERROR_CHANNEL_OUTOFORDER
    CHANNEL_FAILURE = error_codes._LIBSSH2_ERROR_CHANNEL_FAILURE
    CHANNEL_REQUEST_DENIED \
        = error_codes._LIBSSH2_ERROR_CHANNEL_REQUEST_DENIED
    CHANNEL_UNKNOWN = error_codes._LIBSSH2_ERROR_CHANNEL_UNKNOWN
    CHANNEL_WINDOW_EXCEEDED \
        = error_codes._LIBSSH2_ERROR_CHANNEL_WINDOW_EXCEEDED
    CHANNEL_PACKET_EXCEEDED \
        = error_codes._LIBSSH2_ERROR_CHANNEL_PACKET_EXCEEDED
    CHANNEL_CLOSED = error_codes._LIBSSH2_ERROR_CHANNEL_CLOSED
    CHANNEL_EOF_SENT = error_codes._LIBSSH2_ERROR_CHANNEL_EOF_SENT
    SCP_PROTOCOL = error_codes._LIBSSH2_ERROR_SCP_PROTOCOL
    ZLIB = error_codes._LIBSSH2_ERROR_ZLIB
    SOCKET_TIMEOUT = error_codes._LIBSSH2_ERROR_SOCKET_TIMEOUT
    SFTP_PROTOCOL = error_codes._LIBSSH2_ERROR_SFTP_PROTOCOL
    REQUEST_DENIED = error_codes._LIBSSH2_ERROR_REQUEST_DENIED
    METHOD_NOT_SUPPORTED \
        = error_codes._LIBSSH2_ERROR_METHOD_NOT_SUPPORTED
    INVAL = error_codes._LIBSSH2_ERROR_INVAL
    INVALID_POLL_TYPE = error_codes._LIBSSH2_ERROR_INVALID_POLL_TYPE
    PUBLICKEY_PROTOCOL = error_codes._LIBSSH2_ERROR_PUBLICKEY_PROTOCOL
    EAGAIN = error_codes._LIBSSH2_ERROR_EAGAIN
    LIBSSH2CHANNEL_EAGAIN = error_codes._LIBSSH2CHANNEL_EAGAIN
    BUFFER_TOO_SMALL = error_codes._LIBSSH2_ERROR_BUFFER_TOO_SMALL
    BAD_USE = error_codes._LIBSSH2_ERROR_BAD_USE
    COMPRESS = error_codes._LIBSSH2_ERROR_COMPRESS
    OUT_OF_BOUNDARY = error_codes._LIBSSH2_ERROR_OUT_OF_BOUNDARY
    AGENT_PROTOCOL = error_codes._LIBSSH2_ERROR_AGENT_PROTOCOL
    SOCKET_RECV = error_codes._LIBSSH2_ERROR_SOCKET_RECV
    SOCKET_SEND = error_codes._LIBSSH2_ERROR_SOCKET_SEND
    ENCRYPT = error_codes._LIBSSH2_ERROR_ENCRYPT
    BAD_SOCKET = error_codes._LIBSSH2_ERROR_BAD_SOCKET
    KEX_FAILURE = error_codes._LIBSSH2_ERROR_KEX_FAILURE
    INVALID_MAC = error_codes._LIBSSH2_ERROR_INVALID_MAC
    IF EMBEDDED_LIB:
        KNOWN_HOSTS = error_codes._LIBSSH2_ERROR_KNOWN_HOSTS
