FROM debian:bullseye-slim
LABEL maintainer "Dave Curylo <dave@curylo.org>, Michael Hendricks <michael@ndrix.org>"
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libarchive13 \
    libtcmalloc-minimal4 \
    libgmp10 \
    libossp-uuid16 \
    libssl1.1 \
    ca-certificates \
    libpcre3 \
    libedit2 \
    libncurses6 && \
    rm -rf /var/lib/apt/lists/*
ENV LANG C.UTF-8
#COPY patches /tmp/patches
RUN set -eux; \
    SWIPL_VER=9.0.2; \
    SWIPL_CHECKSUM=33b5de34712d58f14c1e019bd1613df9a474f5e5fd024155a0f6e67ebb01c307; \
    BUILD_DEPS='make cmake gcc g++ ninja-build wget git autoconf libarchive-dev libgmp-dev libossp-uuid-dev libpcre3-dev libreadline-dev libedit-dev libssl-dev zlib1g-dev libgoogle-perftools-dev'; \
    apt-get update; apt-get install -y --no-install-recommends $BUILD_DEPS; rm -rf /var/lib/apt/lists/*; \
    mkdir /tmp/src; \
    cd /tmp/src; \
    wget http://www.swi-prolog.org/download/stable/src/swipl-$SWIPL_VER.tar.gz; \
    echo "$SWIPL_CHECKSUM  swipl-$SWIPL_VER.tar.gz" >> swipl-$SWIPL_VER.tar.gz-CHECKSUM; \
    sha256sum -c swipl-$SWIPL_VER.tar.gz-CHECKSUM; \
    tar -xzf swipl-$SWIPL_VER.tar.gz; \
    cd swipl-$SWIPL_VER; \
#    for PATCH in /tmp/patches/*; do git apply $PATCH; done; \
    mkdir build; \
    cd build; \
    cmake -DCMAKE_BUILD_TYPE=PGO \
          -DSWIPL_PACKAGES_X=OFF \
	  -DSWIPL_PACKAGES_JAVA=OFF \
          -DCMAKE_INSTALL_PREFIX=/usr \
          -DINSTALL_DOCUMENTATION=OFF \
          -DSWIPL_PACKAGES_ODBC=OFF \
          -G Ninja \
          ..; \
    ninja; \
    ninja install; \
    rm -rf /tmp/src; rm -rf /tmp/patches; \
    mkdir -p /usr/lib/swipl/pack; \
    cd /usr/lib/swipl/pack; \
    dpkgArch="$(dpkg --print-architecture)"; \
    apt-get purge -y --auto-remove $BUILD_DEPS;

CMD ["swipl"]
