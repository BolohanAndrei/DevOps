#!/bin/bash
set -e
sudo yum update -y
TOMURL="https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.75/bin/apache-tomcat-9.0.75.tar.gz"

dnf install -y java-11-openjdk java-11-openjdk-devel git maven wget

id -u tomcat &>/dev/null || useradd --system --shell /sbin/nologin tomcat
mkdir -p /usr/local/tomcat

cd /tmp
wget -q $TOMURL -O tomcatbin.tar.gz
tar -xzf tomcatbin.tar.gz -C /usr/local/tomcat --strip-components=1
chown -R tomcat:tomcat /usr/local/tomcat

cat << 'EOF' > /etc/systemd/system/tomcat.service
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=simple
User=tomcat
Group=tomcat
WorkingDirectory=/usr/local/tomcat

Environment="JAVA_HOME=/usr/lib/jvm/java-11-openjdk"
Environment="CATALINA_HOME=/usr/local/tomcat"
Environment="CATALINA_BASE=/usr/local/tomcat"
Environment="CATALINA_PID=/usr/local/tomcat/temp/tomcat.pid"

ExecStart=/usr/local/tomcat/bin/catalina.sh run
ExecStop=/usr/local/tomcat/bin/shutdown.sh

RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now tomcat

cd /tmp
rm -rf vprofile-project
git clone -b main https://github.com/hkhcoder/vprofile-project.git
cd vprofile-project

cat << 'EOF' > src/main/resources/application.properties
#JDBC Configutation for Database Connection
jdbc.driverClassName=com.mysql.jdbc.Driver
jdbc.url=jdbc:mysql://db:3306/accounts?useUnicode=true&characterEncoding=UTF-8&zeroDateTimeBehavior=convertToNull
jdbc.username=admin
jdbc.password=admin

#Memcached Configuration For Active and StandBy Host
#For Active Host
memcached.active.host=memcache
memcached.active.port=11211
#For StandBy Host
memcached.standBy.host=127.0.0.2
memcached.standBy.port=11211

#RabbitMq Configuration
rabbitmq.address=rabbit
rabbitmq.port=5672
rabbitmq.username=test
rabbitmq.password=test

#Elasticesearch Configuration
elasticsearch.host =192.168.1.85
elasticsearch.port =9300
elasticsearch.cluster=vprofile
elasticsearch.node=vprofilenode
EOF

mvn install -DskipTests

systemctl stop tomcat
rm -rf /usr/local/tomcat/webapps/ROOT /usr/local/tomcat/webapps/ROOT.war
cp target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war
chown -R tomcat:tomcat /usr/local/tomcat/webapps/

systemctl stop firewalld || true
systemctl disable firewalld || true

systemctl start tomcat

echo "==> Tomcat started on 8080!"