FROM cdrx/fpm-fedora:23

RUN dnf -y install libssh2-devel python-devel python-setuptools git
RUN curl -sLO https://bootstrap.pypa.io/get-pip.py && python get-pip.py && rm -f get-pip.py && pip install -U setuptools wheel && pip install cython

ENV EMBEDDED_LIB 0
ENV HAVE_AGENT_FWD 0
ENV SYSTEM_LIBSSH2 1
