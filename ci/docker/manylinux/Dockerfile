FROM quay.io/pypa/manylinux1_x86_64

ENV CMAKE cmake-2.8.11.1-5.4.x86_64
ENV OPENSSL openssl-1.1.1b
ENV SYSTEM_LIBSSH2 1

RUN yum install zlib-devel -y

ADD libssh2.tar.gz libssh2.tar.gz
ADD ${CMAKE}.rpm cmake.rpm
ADD ${OPENSSL}.tar.gz ${OPENSSL}.tar.gz
ADD local-perl-5.10.0-62.ep.x86_64.rpm local-perl.rpm
ADD local-perl-Pod-Simple-3.07-62.ep.x86_64.rpm local-perl-Pod-Simple.rpm
ADD local-perl-Module-Pluggable-3.60-62.ep.x86_64.rpm local-perl-Module-Pluggable.rpm
ADD local-perl-XSLoader-0.10-1.noarch.rpm local-perl-XSLoader.rpm
ADD local-perl-version-0.74-62.ep.x86_64.rpm local-perl-version.rpm
ADD local-perl-libs-5.10.0-62.ep.x86_64.rpm local-perl-libs.rpm
ADD local-perl-Pod-Escapes-1.04-62.ep.x86_64.rpm local-perl-Pod-Escapes.rpm

RUN rpm -i cmake.rpm local-perl-Module-Pluggable.rpm local-perl-Pod-Escapes.rpm local-perl-Pod-Simple.rpm local-perl-XSLoader.rpm local-perl-version.rpm local-perl-libs.rpm local-perl.rpm

# Openssl
RUN cd ${OPENSSL}.tar.gz/${OPENSSL} && \
    ./config --prefix=/usr --openssldir=/usr/openssl threads shared && \
    make -j4 && make install

# Libssh2
RUN mkdir -p build_libssh2 && cd build_libssh2 && \
    cmake ../libssh2.tar.gz -DBUILD_SHARED_LIBS=ON -DENABLE_ZLIB_COMPRESSION=ON \
    -DENABLE_CRYPT_NONE=ON -DENABLE_MAC_NONE=ON -DCMAKE_INSTALL_PREFIX=/usr && \
    cmake --build . --config Release --target install

RUN rm -rf ${OPENSSL}* build_libssh2 libssh2.tar.gz

VOLUME /var/cache
