#!/bin/bash
# ------------------------------------------------------------------
# Script Name: websetup.sh
# Description: Automated Apache HTTPD setup and website deployment
# Target OS  : CentOS / RHEL / Rocky / AlmaLinux Stream
# ------------------------------------------------------------------

set -e

echo "--> Installing dependencies (wget, unzip, httpd)..."
sudo yum install wget unzip httpd -y > /dev/null

echo "--> Starting and enabling Apache HTTPD service..."
sudo systemctl enable --now httpd

echo "--> Creating temporary staging directory..."
mkdir -p /tmp/webfiles
cd /tmp/webfiles

echo "--> Downloading website template..."
wget -q https://www.tooplate.com/zip-templates/2167_orbital.zip

echo "--> Extracting files..."
unzip -qo 2167_orbital.zip

echo "--> Deploying web files to /var/www/html/..."
sudo cp -r 2167_orbital/* /var/www/html/

echo "--> Restarting web server..."
sudo systemctl restart httpd

echo "--> Cleaning up temporary staging files..."
rm -rf /tmp/webfiles

echo "--> Deployment finished! Current HTTPD status:"
sudo systemctl status httpd --no-pager
