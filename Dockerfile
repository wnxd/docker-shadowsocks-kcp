FROM centos:6
LABEL MAINTAINER="wnxd <imiku@wnxd.me>"

ARG SS_VER=3.2.0
ARG SS_URL=https://github.com/shadowsocks/shadowsocks-libev/releases/download/v${SS_VER}/shadowsocks-libev-${SS_VER}.tar.gz
ARG KCP_VER=20180316
ARG KCP_URL=https://github.com/xtaci/kcptun/releases/download/v${KCP_VER}/kcptun-linux-amd64-${KCP_VER}.tar.gz

ENV ROOT_PASSWORD=centos

RUN yum update -y && \
    yum install -y openssh-server \
                git \
                vim \
                screen \
                gettext \
                gcc \
                autoconf \
                libtool \
                automake \
                make \
                asciidoc \
                xmlto \
                udns-devel \
                libev-devel \
                zlib-devel \
                openssl-devel \
                unzip \
                libevent \
                pcre \
                pcre-devel \
                perl \
                perl-devel \
                cpio \
                expat-devel \
                gettext-devel \
                htop \
                rng-tools \
                c-ares-devel

RUN sed -i 's/enabled=0/enabled=1/' /etc/yum.repos.d/CentOS-Base.repo && \
    echo "root:${ROOT_PASSWORD}" | chpasswd && \
    cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# 搭建SSH服务器
RUN sed -i 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config && \
    sed -i 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config && \
    sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    mkdir -p /root/.ssh/ && \
    echo "StrictHostKeyChecking=no" > /root/.ssh/config && \
    echo "UserKnownHostsFile=/dev/null" >> /root/.ssh/config && \
    /etc/init.d/sshd start

# 搭建Shadowsocks服务器
ENV SERVER_ADDR=0.0.0.0 \
    SERVER_PORT=8989 \
    PASSWORD=wnxd \
    METHOD=aes-256-cfb \
    TIMEOUT=300 \
    FASTOPEN=--fast-open \
    UDP_RELAY=-u \
    DNS_ADDR=8.8.8.8 \
    DNS_ADDR_2=8.8.4.4 \
    ARGS=''

RUN mkdir shadowsocks-libev && \
    cd shadowsocks-libev && \
    curl -sSL ${SS_URL} | tar xz --strip 1 && \
    ./configure && \
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
RUN yum clean all && \
    rm -rf /var/cache/yum

# 开放端口
EXPOSE 22

# 启动命令
ADD entrypoint.sh /usr/bin/entrypoint.sh
ENTRYPOINT [ "bash", "/usr/bin/entrypoint.sh" ]