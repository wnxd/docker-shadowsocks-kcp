#!/bin/bash
rm -f /etc/motd
cat >> /etc/motd << EOF

Author : wnxd <imiku@wnxd.me>
Project : https://hub.docker.com/r/wnxd/docker-shadowsocks-kcp/
Docker Image : wnxd/docker-shadowsocks-kcp

Linux Version : $(cat /etc/redhat-release)
Kernel Version : $(uname -r)
Hostname : $(uname -n)

Enjoy your Docker-Linux Node !

EOF

echo "root:$ROOT_PASSWORD" | chpasswd

/usr/sbin/sshd -D -e -o PermitRootLogin=yes &

/usr/bin/ss-server -s 0.0.0.0 \
                   -p $SS_PORT \
                   -k $SS_PASSWORD \
                   -m $SS_METHOD \
                   -t $SS_TIMEOUT \
                   $SS_FASTOPEN \
                   -d $SS_DNS \
                   -d $SS_DNS2 \
                   $SS_UDP_RELAY \
                   $SS_ARGS \
                   -f /tmp/ss.pid &

echo "Start Success !"