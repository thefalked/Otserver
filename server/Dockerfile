# Build TFS for the *target* platform (amd64 on VPS, arm64 on Apple Silicon Docker).
# Do not COPY a checked-in binary — that caused Exec format error on x86 VPS
# when server/theforgottenserver was an aarch64 Mac build.
#
# Build from repo root: docker compose build otserver
# Optional host copy of the binary: ./server/compile.sh

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
COPY src/ /src/

RUN chmod +x autogen.sh build.sh \
	&& ./autogen.sh \
	&& ./configure --enable-mysql \
	&& make -j"$(nproc)" \
	&& strip theforgottenserver

FROM ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive \
	TZ=UTC

RUN apt-get update && apt-get install -y --no-install-recommends \
	ca-certificates \
	coreutils \
	gettext-base \
	util-linux \
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
	&& rm -rf /var/lib/apt/lists/* \
	# H7: locked-down runtime user (uid 1000). Ubuntu images ship login user "ubuntu".
	&& usermod -l otserver -d /ot -s /usr/sbin/nologin ubuntu \
	&& groupmod -n otserver ubuntu

WORKDIR /ot
COPY --from=builder /src/theforgottenserver /usr/local/bin/theforgottenserver
COPY docker/render-config.sh docker/entrypoint-otserver.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/theforgottenserver \
	/usr/local/bin/render-config.sh \
	/usr/local/bin/entrypoint-otserver.sh \
	&& ln -sf entrypoint-otserver.sh /usr/local/bin/docker-entrypoint.sh \
	&& mkdir -p /ot/logs \
	&& chown -R otserver:otserver /ot

EXPOSE 7171 7172
USER root
ENTRYPOINT ["entrypoint-otserver.sh"]
