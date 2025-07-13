#!/bin/bash

sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
sudo snap set certbot trust-plugin-with-root=ok
sudo snap install certbot-dns-cloudflare
read -p "Input your cloudflare API: " CLOUDFLARE_API
read -p "Input your domain name: " DOMAIN

echo "dns_cloudflare_api_token = $CLOUDFLARE_API" > ~/certbot.ini
certbot certonly \
  --dns-cloudflare \
  --dns-cloudflare-credentials ~/certbot.ini \
  -d *.$DOMAIN

chmod 600 ~/certbot.ini
