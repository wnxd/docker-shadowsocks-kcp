FROM centos:6
LABEL MAINTAINER="wnxd <imiku@wnxd.me>"

ARG SS_VER=3.2.0
ARG SS_URL=https://github.com/shadowsocks/shadowsocks-libev/releases/download/v$SS_VER/shadowsocks-libev-$SS_VER.tar.gz
ARG KCP_VER=20180316
ARG KCP_URL=https://github.com/xtaci/kcptun/releases/download/v$KCP_VER/kcptun-linux-amd64-$KCP_VER.tar.gz

RUN yum update -y
RUN yum install -y initscripts \
                epel-release \
                wget \
                passwd \
                tar \
                unzip \
                openssh-server

RUN sed -i 's/enabled=0/enabled=1/' /etc/yum.repos.d/CentOS-Base.repo
RUN echo "root:centos" | chpasswd
RUN cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# 搭建SSH服务器
RUN sed -i 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN sed -i 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config
RUN sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN mkdir -p /root/.ssh/
RUN echo "StrictHostKeyChecking=no" > /root/.ssh/config
RUN echo "UserKnownHostsFile=/dev/null" >> /root/.ssh/config
RUN /etc/init.d/sshd start

# 清理环境
RUN yum clean all
RUN rm -rf /var/cache/yum

# 开放端口
EXPOSE 22

# 启动命令
ADD entrypoint.sh /usr/bin/entrypoint.sh
ENTRYPOINT [ "bash", "/usr/bin/entrypoint.sh" ]