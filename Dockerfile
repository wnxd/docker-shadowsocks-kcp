FROM alpine:3.8
LABEL MAINTAINER="wnxd <imiku@wnxd.me>"

ARG SS_VER=3.2.0
ARG SS_URL=https://github.com/shadowsocks/shadowsocks-libev/releases/download/v$SS_VER/shadowsocks-libev-$SS_VER.tar.gz
ARG KCP_VER=20180316
ARG KCP_URL=https://github.com/xtaci/kcptun/releases/download/v$KCP_VER/kcptun-linux-amd64-$KCP_VER.tar.gz

ENV SYS_ROOT_PASS="alpine" \
    SYS_TIMEZONE="Asia/Shanghai"

RUN apk --no-cache upgrade
RUN apk --no-cache add tzdata

RUN echo 'root:${SYS_ROOT_PASS}' | chpasswd
RUN echo "${SYS_TIMEZONE}" > /etc/timezone
RUN ln -sf /usr/share/zoneinfo/${SYS_TIMEZONE} /etc/localtime

# 搭建SSH服务器
RUN apk --no-cache add openssh-server
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN ssh-keygen -A

# 清理环境
RUN rm -rf /var/cache/apk/* /tmp/*

# 开放端口
EXPOSE 22

# 启动命令
CMD /usr/sbin/sshd -D