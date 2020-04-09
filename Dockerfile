FROM debian:buster-slim
LABEL maintainer "Dave Curylo <dave@curylo.org>, Michael Hendricks <michael@ndrix.org>"
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libarchive13 \
    libgmp10 \
    libossp-uuid16 \
    libssl1.1 \
    ca-certificates \
    libpcre3 \
    libedit2 \
    libncurses6 && \
    rm -rf /var/lib/apt/lists/*
RUN set -eux; \
    SWIPL_VER=8.0.3; \
    SWIPL_CHECKSUM=cee59c0a477c8166d722703f6e52f962028f3ac43a5f41240ecb45dbdbe2d6ae; \
    BUILD_DEPS='make cmake gcc g++ wget git autoconf libarchive-dev libgmp-dev libossp-uuid-dev libpcre3-dev libreadline-dev libedit-dev libssl-dev zlib1g-dev libdb-dev'; \
    apt-get update; apt-get install -y --no-install-recommends $BUILD_DEPS; rm -rf /var/lib/apt/lists/*; \
    mkdir /tmp/src; \
    cd /tmp/src; \
    wget http://www.swi-prolog.org/download/stable/src/swipl-$SWIPL_VER.tar.gz; \
    echo "$SWIPL_CHECKSUM  swipl-$SWIPL_VER.tar.gz" >> swipl-$SWIPL_VER.tar.gz-CHECKSUM; \
    sha256sum -c swipl-$SWIPL_VER.tar.gz-CHECKSUM; \
    tar -xzf swipl-$SWIPL_VER.tar.gz; \
    mkdir swipl-$SWIPL_VER/build; \
    cd swipl-$SWIPL_VER/build; \
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DSWIPL_PACKAGES_X=OFF \
	  -DSWIPL_PACKAGES_JAVA=OFF \
	  -DCMAKE_INSTALL_PREFIX=/usr \
          ..; \
    # LANG=C.UTF8 is a work-around for a 7.7.22 bug
    LANG=C.UTF8 make; \
    LANG=C.UTF8 make install; \
    rm -rf /tmp/src; \
    mkdir -p /usr/lib/swipl/pack; \
    cd /usr/lib/swipl/pack; \
    dpkgArch="$(dpkg --print-architecture)"; \
    apt-get purge -y --auto-remove $BUILD_DEPS
ENV LANG C.UTF-8
CMD ["swipl"]
