FROM alpine:3.8
LABEL MAINTAINER="wnxd <imiku@wnxd.me>"

ARG SS_VER=3.2.0
ARG SS_URL=https://github.com/shadowsocks/shadowsocks-libev/releases/download/v$SS_VER/shadowsocks-libev-$SS_VER.tar.gz
ARG KCP_VER=20180316
ARG KCP_URL=https://github.com/xtaci/kcptun/releases/download/v$KCP_VER/kcptun-linux-amd64-$KCP_VER.tar.gz

RUN echo -e "https://mirror.tuna.tsinghua.edu.cn/alpine/latest-stable/main\n" > /etc/apk/repositories && \
    apk add --no-cache openssh && \
    apk add --no-cache --virtual .build-deps \
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
                                g++ && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    cd /tmp && \
    curl -sSL $KCP_URL | tar xz server_linux_amd64 && \
    mv server_linux_amd64 /usr/bin/ && \
    mkdir ss && \
    cd ss && \
    curl -sSL $SS_URL | tar xz --strip 1 && \
    ./configure --prefix=/usr --disable-documentation && \
    make install && \
    cd /tmp && \
    git clone https://github.com/shadowsocks/simple-obfs.git && \
    cd simple-obfs && \
    git submodule update --init --recursive && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install && \
    cd .. && \
    runDeps="$( \
        scanelf --needed --nobanner /usr/bin/ss-* \
            | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
            | xargs -r apk info --installed \
            | sort -u \
    )" && \
    echo "root:alpine" | chpasswd && \
    sed -i s/#PermitRootLogin.*/PermitRootLogin\ yes/ /etc/ssh/sshd_config && \
    ssh-keygen -A && \
    apk add --no-cache --virtual .run-deps $runDeps && \
    apk del .build-deps && \
    rm -rf /var/cache/apk/* /tmp/*

ENV SERVER_ADDR=0.0.0.0 \
SERVER_PORT=8989 \
PASSWORD=wnxd \
METHOD=aes-256-cfb \
TIMEOUT=300 \
FASTOPEN=--fast-open \
UDP_RELAY=-u \
DNS_ADDR=8.8.8.8 \
DNS_ADDR_2=8.8.4.4 \
ARGS='' \
KCP_LISTEN=8990 \
KCP_PASS=wnxd \
KCP_ENCRYPT=aes-192 \
KCP_MODE=fast2 \
KCP_MUT=1350 \
KCP_NOCOMP='' \
KCP_ARGS=''

EXPOSE 22
EXPOSE $SERVER_PORT/tcp $SERVER_PORT/udp
EXPOSE $KCP_LISTEN/udp

CMD /usr/sbin/sshd -D && \
    /usr/bin/ss-server -s $SERVER_ADDR \
              -p $SERVER_PORT \
              -k $PASSWORD \
              -m $METHOD \
              -t $TIMEOUT \
              $FASTOPEN \
              -d $DNS_ADDR \
              -d $DNS_ADDR_2 \
              $UDP_RELAY \
              $ARGS \
              -f /tmp/ss.pid && \
    /usr/bin/server_linux_amd64 -t "127.0.0.1:$SERVER_PORT" \
              -l ":$KCP_LISTEN" \
              -key $KCP_PASS \
              --mode $KCP_MODE \
              --crypt $KCP_ENCRYPT \
              --mtu $KCP_MUT \
              $KCP_NOCOMP \
              $KCP_ARGS
