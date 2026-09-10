# Runtime-only image: uses prebuilt binary from this directory.
# Rebuild the binary with: ./server/compile.sh

FROM ubuntu:26.04

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
COPY theforgottenserver /usr/local/bin/theforgottenserver

EXPOSE 7171 7172
CMD ["theforgottenserver"]
