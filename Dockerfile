FROM centos:6
LABEL MAINTAINER="wnxd <imiku@wnxd.me>"

ARG SS_VER=3.2.0
ARG SS_URL=https://github.com/shadowsocks/shadowsocks-libev/archive/v${SS_VER}.tar.gz
ARG KCP_VER=20180316
ARG KCP_URL=https://github.com/xtaci/kcptun/releases/download/v${KCP_VER}/kcptun-linux-amd64-${KCP_VER}.tar.gz

ENV ROOT_PASSWORD=centos

RUN yum update -y
RUN yum install -y initscripts \
                epel-release \
                wget \
                passwd \
                tar \
                unzip \
                curl \
                openssh-server \
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

RUN sed -i 's/enabled=0/enabled=1/' /etc/yum.repos.d/CentOS-Base.repo
RUN echo "root:${ROOT_PASSWORD}" | chpasswd
RUN cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# 搭建SSH服务器
RUN sed -i 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN sed -i 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config
RUN sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN mkdir -p /root/.ssh/
RUN echo "StrictHostKeyChecking=no" > /root/.ssh/config
RUN echo "UserKnownHostsFile=/dev/null" >> /root/.ssh/config
RUN /etc/init.d/sshd start

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

RUN curl -sSL ${SS_URL} | tar xz --strip 1
RUN cd shadowsocks-libev-${SS_VER}
RUN git submodule update --init --recursive
RUN ./autogen.sh
RUN ./configure
RUN make
RUN make install
RUN cd ..
RUN rm -rf shadowsocks-libev-${SS_VER}
RUN git clone https://github.com/shadowsocks/simple-obfs.git
RUN cd simple-obfs
RUN git submodule update --init --recursive
RUN ./autogen.sh
RUN ./configure
RUN make
RUN make install
RUN cd ..
RUN rm -rf simple-obfs

# 清理环境
RUN yum clean all
RUN rm -rf /var/cache/yum

# 开放端口
EXPOSE 22

# 启动命令
ADD entrypoint.sh /usr/bin/entrypoint.sh
ENTRYPOINT [ "bash", "/usr/bin/entrypoint.sh" ]