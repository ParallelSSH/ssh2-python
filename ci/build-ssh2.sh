#!/bin/bash -xe

mkdir -p src && cd src
cmake ../libssh2 -DBUILD_SHARED_LIBS=ON -DENABLE_ZLIB_COMPRESSION=ON \
    -DENABLE_CRYPT_NONE=ON -DENABLE_MAC_NONE=ON
cmake --build . --config Release
