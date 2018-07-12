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
echo "Start Success !"

cat /etc/ssh/sshd_config

if [ ! -z "${ROOT_PASSWORD}" ] && [ "${ROOT_PASSWORD}" != "root" ]; then
    echo "root:${ROOT_PASSWORD}" | chpasswd
fi

/usr/sbin/sshd -D
# /usr/bin/ss-server -s $SERVER_ADDR \
#                    -p $SERVER_PORT \
#                    -k $PASSWORD \
#                    -m $METHOD \
#                    -t $TIMEOUT \
#                    $FASTOPEN \
#                    -d $DNS_ADDR \
#                    -d $DNS_ADDR_2 \
#                    $UDP_RELAY \
#                    $ARGS \
#                    -f /tmp/ss.pid