#!/bin/bash
set -e
sudo yum update -y
dnf install -y epel-release
dnf install -y memcached firewalld

sed -i 's/OPTIONS="-l 127.0.0.1/OPTIONS="-l 0.0.0.0/' /etc/sysconfig/memcached || \
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/sysconfig/memcached

systemctl enable --now firewalld
firewall-cmd --zone=public --add-port=11211/tcp --permanent
firewall-cmd --zone=public --add-port=11211/udp --permanent
firewall-cmd --reload

systemctl enable --now memcached
systemctl restart memcached

echo "==> Memcached activ!"