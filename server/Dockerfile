# Builder: compile TFS (used by ./server/compile.sh with --platform).
# Runtime: packages prebuilt server/theforgottenserver-{arm64,amd64}.
# Entrypoint picks the matching binary. No make during compose build.
#
# Order: ./server/compile.sh && docker compose build otserver

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
COPY server/theforgottenserver-arm64 server/theforgottenserver-amd64 /usr/local/bin/
COPY docker/render-config.sh docker/entrypoint-otserver.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/theforgottenserver-arm64 \
	/usr/local/bin/theforgottenserver-amd64 \
	/usr/local/bin/render-config.sh \
	/usr/local/bin/entrypoint-otserver.sh \
	&& ln -sf entrypoint-otserver.sh /usr/local/bin/docker-entrypoint.sh \
	&& mkdir -p /ot/logs \
	&& chown -R otserver:otserver /ot

EXPOSE 7171 7172
USER root
ENTRYPOINT ["entrypoint-otserver.sh"]
