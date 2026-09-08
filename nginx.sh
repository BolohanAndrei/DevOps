#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y nginx

cat << 'EOF' > /etc/nginx/sites-available/vproapp
upstream vproapp {

 server tomcat:8080;

}

server {

  listen 80;

location / {

  proxy_pass http://vproapp;

}

}
EOF

rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/vproapp /etc/nginx/sites-enabled/vproapp

nginx -t

systemctl enable --now nginx
systemctl restart nginx

echo "==> nginx active!"