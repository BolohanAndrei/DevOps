#!/bin/bash
set -e
sudo yum update -y
dnf install -y curl socat logrotate firewalld

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash

dnf install -y erlang rabbitmq-server

systemctl enable --now rabbitmq-server

sh -c 'echo "loopback_users.guest = false" > /etc/rabbitmq/rabbitmq.conf'

rabbitmqctl add_user test test || rabbitmqctl change_password test test
rabbitmqctl set_user_tags test administrator
rabbitmqctl set_permissions -p / test ".*" ".*" ".*"

rabbitmq-plugins enable rabbitmq_management

systemctl enable --now firewalld
firewall-cmd --zone=public --add-port=5672/tcp --permanent   
firewall-cmd --zone=public --add-port=15672/tcp --permanent  
firewall-cmd --reload

systemctl restart rabbitmq-server

echo "==> RabbitMQ activ"