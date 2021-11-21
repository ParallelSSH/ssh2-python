# This file is part of ssh2-python.
# Copyright (C) 2017-2021 Panos Kittenis and contributors.
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
FROM quay.io/pypa/manylinux2010_x86_64

ENV OPENSSL openssl-1.1.1g
ENV SYSTEM_LIBSSH2 1
ENV LIBSSH2_VERSION 1.9.0

RUN yum install zlib-devel -y

ADD libssh2-${LIBSSH2_VERSION}.tar.gz libssh2-${LIBSSH2_VERSION}.tar.gz
ADD https://www.openssl.org/source/${OPENSSL}.tar.gz ${OPENSSL}.tar.gz

RUN tar -xzf ${OPENSSL}.tar.gz
# Openssl
RUN cd ${OPENSSL} && \
    ./config --prefix=/usr --openssldir=/usr/openssl threads shared && \
    make -j4 && make install

# Libssh2
RUN mkdir -p build_libssh2 && cd build_libssh2 && \
    cmake ../libssh2-${LIBSSH2_VERSION}.tar.gz/libssh2-libssh2-${LIBSSH2_VERSION} \
    -DBUILD_SHARED_LIBS=ON -DENABLE_ZLIB_COMPRESSION=ON \
    -DENABLE_CRYPT_NONE=ON -DENABLE_MAC_NONE=ON -DCMAKE_INSTALL_PREFIX=/usr && \
    cmake --build . --config Release --target install

RUN rm -rf ${OPENSSL}* build_libssh2 libssh2.tar.gz

VOLUME /var/cache
