#!/bin/bash

# HAProxy user is already present, but /var/lib/haproxy directory is not
mkdir -p /var/lib/haproxy

# This file is taken from reference (https://github.com/clearlinux/cloud-native-setup/blob/master/clr-k8s-examples/haproxy.cfg.example)
# Don't forget to update 'bind' and 'server' directives
cat <<EOF> /etc/haproxy/haproxy.cfg
global
    log /dev/log    local0
    chroot /var/lib/haproxy
    stats socket /run/haproxy-master.sock mode 660 level admin
    stats timeout 30s
    user haproxy
    group haproxy
    daemon
    # Default SSL material locations
    ca-base /etc/ssl/certs
    ssl-default-bind-ciphers ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:RSA+AESGCM:RSA+AES:!aNULL:!MD5:!DSS
    ssl-default-bind-options no-sslv3
defaults
    log     global
    mode    http
    option  httplog
    option  dontlognull
    timeout connect 5000
    timeout client  50000
    timeout server  50000
    timeout tunnel  4h
frontend kubernetes
    bind 10.0.3.15:6444
    option tcplog
    mode tcp
    default_backend kubernetes-master-nodes

backend kubernetes-master-nodes
    mode tcp
    balance source
    option tcp-check
    server master-1 10.0.3.100:6443 check fall 3 rise 2
    server master-2 10.0.3.101:6443 check fall 3 rise 2
    server master-3 10.0.3.102:6443 check fall 3 rise 2
EOF
