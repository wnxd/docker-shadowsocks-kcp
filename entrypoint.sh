#!/bin/bash
rm -f /etc/motd
cat >> /etc/motd << EOF

Welcome to the CentOS Docker-Linux !

Author : wnxd <imiku@wnxd.me>
Project : https://hub.docker.com/r/wnxd/docker-shadowsocks-kcp/
Docker Image : wnxd/docker-shadowsocks-kcp

Linux Version : $(cat /etc/redhat-release)
Kernel Version : $(uname -r)
Hostname : $(uname -n)

Enjoy your Docker-Linux Node !

EOF
echo "Start Success !"

/usr/sbin/sshd -D