#!/bin/sh

# Download and extract Tailscale
wget https://pkgs.tailscale.com/stable/tailscale_1.76.1_amd64.tgz && \
    tar xzf tailscale_1.76.1_amd64.tgz --strip-components=1

# # Add Tailscale binaries to PATH
export PATH=$PATH:$(pwd)
# Create necessary directory for Tailscale
# mkdir -p /var/run/tailscale

# Start Tailscale

ls 

# tailscaled -no-logs-no-support --socket=/tmp/tailscaled.sock --tun=userspace-networking --outbound-http-proxy-listen=0.0.0.0:2000 --socks5-server=0.0.0.0:2001 &
tailscaled -no-logs-no-support --socket=/tmp/tailscaled.sock --tun=userspace-networking --socks5-server=localhost:1055 &

until tailscale --socket=/tmp/tailscaled.sock up --authkey=${TAILSCALE_AUTHKEY} --hostname=ephermeral-vpn-${PORT} --advertise-exit-node
do
    sleep 1
done

echo Tailscale started

# Set proxy and start Gunicorn
ALL_PROXY=socks5://localhost:1055/
gunicorn --bind 0.0.0.0:${PORT} --workers 2 --threads 2 wsgi:app