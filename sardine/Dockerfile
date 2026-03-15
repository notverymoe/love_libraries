#syntax=docker/dockerfile:1.2

FROM docker.io/akorn/luarocks:luajit2.1-alpine AS builder

RUN apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing \
	dumb-init gcc libc-dev git

RUN git clone --depth 1 --branch v2.3.0 https://github.com/lunarmodules/busted.git /src
WORKDIR /src

RUN luarocks --tree /pkgdir/usr/local make
RUN find /pkgdir -type f -exec sed -i -e 's!/pkgdir!!g' {} \;

FROM docker.io/akorn/luarocks:luajit2.1-alpine AS final

RUN apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing \
	dumb-init

LABEL org.opencontainers.image.title="Busted"
LABEL org.opencontainers.image.description="A containerized version of Busted, a unit testing framework for Lua. Modified for luajit2.1"
LABEL org.opencontainers.image.authors="Caleb Maclennan <caleb@alerque.com>, Modified by Natalie Baker"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.url="https://github.com/lunarmodules/busted/pkgs/container/busted"
LABEL org.opencontainers.image.source="https://github.com/lunarmodules/busted"

COPY --from=builder /pkgdir /
RUN busted --version

WORKDIR /data

ENTRYPOINT ["busted", "--verbose", "--output=gtest"]
