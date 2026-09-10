# Multi-stage build for The Forgotten Server 0.4 on Ubuntu 26.04
# Builder keeps compile deps; runtime is a cut-down image with shared libs only.

FROM ubuntu:26.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
	build-essential \
	autoconf \
	automake \
	libtool \
	pkg-config \
	ca-certificates \
	libboost-system-dev \
	libboost-thread-dev \
	libboost-regex-dev \
	libboost-filesystem-dev \
	libboost-date-time-dev \
	liblua5.1-0-dev \
	libxml2-dev \
	zlib1g-dev \
	libcrypto++-dev \
	libssl-dev \
	default-libmysqlclient-dev \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /src
COPY . /src/

RUN chmod +x autogen.sh build.sh \
	&& ./autogen.sh \
	&& ./configure --enable-mysql --enable-root-permission \
	&& make -j$(nproc) \
	&& strip theforgottenserver

# --- slim runtime ---
FROM ubuntu:26.04 AS runtime

ENV DEBIAN_FRONTEND=noninteractive \
	TZ=UTC

RUN apt-get update && apt-get install -y --no-install-recommends \
	ca-certificates \
	libboost-thread1.90.0 \
	libboost-regex1.90.0 \
	libboost-filesystem1.90.0 \
	libboost-date-time1.90.0 \
	liblua5.1-0 \
	libxml2-16 \
	zlib1g \
	libcrypto++8t64 \
	libssl3t64 \
	libmysqlclient24 \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /ot
COPY --from=builder /src/theforgottenserver /usr/local/bin/theforgottenserver

EXPOSE 7171 7172
CMD ["theforgottenserver"]
