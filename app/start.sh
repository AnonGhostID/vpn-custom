#!/bin/sh

# Download and extract Tailscale
wget https://pkgs.tailscale.com/stable/tailscale_1.76.1_amd64.tgz && \
    tar xzf tailscale_1.76.1_amd64.tgz --strip-components=1

tailscaled --tun=userspace-networking --socks5-server=localhost:1055 &
tailscale up --authkey=${TAILSCALE_AUTHKEY} --hostname=ephermeral-vpn-${PORT} --advertise-exit-node
echo Tailscale started
ALL_PROXY=socks5://localhost:1055/
gunicorn --bind 0.0.0.0:${PORT} --workers 2 --threads 2 app.wsgi:app