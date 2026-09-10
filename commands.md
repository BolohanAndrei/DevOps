# 🛠️ Bash Scripts: Command Reference & Lab Execution

This guide provides the complete terminal commands to manage the Vagrant lab, create the scripts in `/opt/scripts`, make them executable, and run automated deployments.

---

## 📑 Table of Contents

1. [Vagrant VM Management](#1-vagrant-vm-management)
2. [Setting Up the Scripts Workspace](#2-setting-up-the-scripts-workspace)
3. [Script 1: System Health Check (`firstscript.sh`)](#3-script-1-system-health-check-firstscriptsh)
4. [Script 2: Automated Web Deployment (`websetup.sh`)](#4-script-2-automated-web-deployment-websetupsh)
5. [Testing & Verification](#5-testing--verification)
6. [Multi-Node Deployment (Optional)](#6-multi-node-deployment-optional)
7. [Bash Scripting Best Practices](#7-bash-scripting-best-practices)

---

## 1. Vagrant VM Management

The [Vagrantfile](file:///D:/DevOps/Vagrantfile) defines 4 VMs. You can boot the scripting node individually or start all nodes:

```bash
# Start only the primary scripting box
vagrant up scriptbox

# (Optional) Start all 4 nodes
vagrant up

# Log in to scriptbox
vagrant ssh scriptbox

# Check status of all nodes
vagrant status

# Shut down VMs when finished
vagrant halt
```

---

## 2. Setting Up the Scripts Workspace

Inside the `scriptbox` VM:

```bash
# Create the standard scripts directory
sudo mkdir -p /opt/scripts

# Change ownership to the current user (vagrant)
sudo chown -R vagrant:vagrant /opt/scripts

# Switch into the workspace
cd /opt/scripts
```

---

## 3. Script 1: System Health Check (`firstscript.sh`)

### Create the file:
```bash
vim firstscript.sh
```

Paste the following script:
```bash
#!/bin/bash

echo "### Welcome to System Monitoring Script ###"
echo

echo "--> System Uptime & Load Average:"
uptime
echo

echo "--> Memory Utilization (MB):"
free -m
echo

echo "--> Disk Space Utilization:"
df -h
```

### Make it executable and run:
```bash
chmod +x firstscript.sh
./firstscript.sh
```

---

## 4. Script 2: Automated Web Deployment (`websetup.sh`)

### Create the file:
```bash
vim websetup.sh
```

Paste the following script:
```bash
#!/bin/bash

# Exit immediately if a command fails
set -e

echo "--> Installing packages (wget, unzip, httpd)..."
sudo yum install wget unzip httpd -y > /dev/null

echo "--> Enabling and starting Apache HTTPD..."
sudo systemctl enable --now httpd

echo "--> Staging web template..."
mkdir -p /tmp/webfiles
cd /tmp/webfiles
wget https://www.tooplate.com/zip-templates/2167_orbital.zip > /dev/null
unzip -o 2167_orbital.zip > /dev/null

echo "--> Copying files to document root..."
sudo cp -r 2167_orbital/* /var/www/html/
sudo systemctl restart httpd

echo "--> Cleaning up staging files..."
rm -rf /tmp/webfiles

echo "--> Checking Apache status..."
sudo systemctl status httpd --no-pager
```

### Make it executable and run:
```bash
chmod +x websetup.sh
./websetup.sh
```

---

## 5. Testing & Verification

### From terminal (CLI):
```bash
# Check if HTTPD is serving the page locally
curl -I http://localhost
```

### From your host machine browser:
Open your browser and navigate to the `scriptbox` private IP:
```text
http://192.168.10.12
```
You should see the **Orbital** website template running.

---

## 6. Multi-Node Deployment (Optional)

You can copy and execute `websetup.sh` on the other CentOS nodes (`web01` and `web02`):

```bash
# From scriptbox, copy script to web01
scp /opt/scripts/websetup.sh vagrant@192.168.10.13:/tmp/

# SSH into web01 and run it
ssh vagrant@192.168.10.13 "bash /tmp/websetup.sh"

# Verify web01 is serving traffic
curl -I http://192.168.10.13
```

---

## 7. Bash Scripting Best Practices

* **Shebang (`#!/bin/bash`)**: Always specify the interpreter at the very first line.
* **Error Handling (`set -e`)**: Stops the script immediately if any command returns a non-zero exit code.
* **Clean Output (`> /dev/null`)**: Redirect verbose standard output for package managers or unzip to keep script execution clean.
* **Quiet / No Pager (`--no-pager`)**: When checking service status with `systemctl status`, add `--no-pager` so the script doesn't pause waiting for keyboard input.
* **Executable Bit (`chmod +x`)**: Scripts require execute permission before they can be invoked with `./script.sh`.
