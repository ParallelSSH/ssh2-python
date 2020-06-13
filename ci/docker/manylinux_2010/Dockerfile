#FROM quay.io/pypa/manylinux2014_x86_64
FROM quay.io/pypa/manylinux2010_x86_64

ENV SYSTEM_LIBSSH2 1

COPY ./libssh2 /libssh2

RUN yum -y --disablerepo="epel" install zlib-devel openssl-devel cmake gcc
RUN /opt/python/cp27-cp27m/bin/pip install enum
RUN /opt/python/cp27-cp27mu/bin/pip install enum

# Libssh2
RUN mkdir -p build_libssh2 && cd build_libssh2 && \
    cmake /libssh2 -DBUILD_SHARED_LIBS=ON -DENABLE_ZLIB_COMPRESSION=ON \
    -DENABLE_CRYPT_NONE=ON -DENABLE_MAC_NONE=ON -DCMAKE_INSTALL_PREFIX=/usr && \
    cmake --build . --config Release --target install

RUN rm -rf build_libssh2
