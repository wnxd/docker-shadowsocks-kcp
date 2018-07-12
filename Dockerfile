FROM alpine:3.8
LABEL MAINTAINER="wnxd <imiku@wnxd.me>"

ARG SS_VER=3.2.0
ARG SS_URL=https://github.com/shadowsocks/shadowsocks-libev/releases/download/v${SS_VER}/shadowsocks-libev-${SS_VER}.tar.gz
ARG KCP_VER=20180316
ARG KCP_URL=https://github.com/xtaci/kcptun/releases/download/v${KCP_VER}/kcptun-linux-amd64-${KCP_VER}.tar.gz

ENV ROOT_PASSWORD=alpine
ENV TIMEZONE=Asia/Shanghai

RUN echo "${TIMEZONE}" > /etc/timezone && \
    ln -sf /usr/share/zoneinfo/${TIMEZONE}} /etc/localtime && \
    apk --no-cache upgrade && \
    apk --no-cache add \
        openssh-server \
        autoconf \
        build-base \
        curl \
        libev-dev \
        linux-headers \
        libsodium-dev \
        mbedtls-dev \
        pcre-dev \
        tar \
        tzdata \
        c-ares-dev \
        git \
        gcc \
        make \
        libtool \
        zlib-dev \
        automake \
        openssl \
        asciidoc \
        xmlto \
        libpcre32 \
        g++

# 搭建SSH服务器
RUN ssh-keygen -A

# 搭建Shadowsocks服务器
ENV SS_PORT=8989
ENV SS_PASSWORD=wnxd
ENV SS_METHOD=aes-256-cfb
ENV SS_TIMEOUT=300
ENV SS_FASTOPEN=--fast-open
ENV SS_UDP_RELAY=-u
ENV SS_DNS=8.8.8.8
ENV SS_DNS2=8.8.4.4
ENV SS_ARGS=''

RUN mkdir shadowsocks-libev && \
    cd shadowsocks-libev && \
    curl -sSL ${SS_URL} | tar xz --strip 1 && \
    ./configure --prefix=/usr --disable-documentation && \
    make install && \
    cd .. && \
    rm -rf shadowsocks-libev && \
    git clone https://github.com/shadowsocks/simple-obfs.git && \
    cd simple-obfs && \
    git submodule update --init --recursive && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install && \
    cd .. && \
    rm -rf simple-obfs

# 清理环境
RUN rm -rf /var/cache/apk/* /tmp/*

# 开放端口
EXPOSE 22
EXPOSE ${SS_PORT}/tcp
EXPOSE ${SS_PORT}/udp

# 启动命令
ADD entrypoint.sh /usr/bin/entrypoint.sh
ENTRYPOINT [ "bash", "/usr/bin/entrypoint.sh" ]