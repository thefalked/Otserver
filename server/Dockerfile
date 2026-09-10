# Runtime-only image: uses prebuilt binary from server/.
# Rebuild the binary with: ./server/compile.sh
# Build from repo root: docker compose build otserver

FROM ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive \
	TZ=UTC

RUN apt-get update && apt-get install -y --no-install-recommends \
	ca-certificates \
	gettext-base \
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
COPY server/theforgottenserver /usr/local/bin/theforgottenserver
COPY docker/render-config.sh docker/entrypoint-otserver.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/render-config.sh /usr/local/bin/entrypoint-otserver.sh \
	&& ln -sf entrypoint-otserver.sh /usr/local/bin/docker-entrypoint.sh

EXPOSE 7171 7172
ENTRYPOINT ["entrypoint-otserver.sh"]
