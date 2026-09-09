# 🛠️ Docker & Vagrant Command Reference

This document provides a clean, step-by-step walkthrough of all commands used in the **`containers-intro`** lab, spanning VM management, Docker container lifecycle, multi-stage image builds, and multi-service orchestration with Docker Compose.

---

## 📑 Table of Contents
1. [Vagrant VM Management](#1-vagrant-vm-management)
2. [Docker Basics & First Container](#2-docker-basics--first-container)
3. [Building Custom Images (Multi-Stage Build)](#3-building-custom-images-multi-stage-build)
4. [Container & Image Lifecycle (Cleanup)](#4-container--image-lifecycle-cleanup)
5. [Multi-Container Deployment (Docker Compose)](#5-multi-container-deployment-docker-compose)

---

## 1. Vagrant VM Management

All Docker labs run inside an automated Ubuntu 22.04 LTS (Jammy) virtual machine.

```bash
# Start and provision the virtual machine
vagrant up

# Log in to the Ubuntu VM via SSH
vagrant ssh

# Check the VM status
vagrant status

# Suspend or shut down the VM when finished
vagrant halt

# Destroy the VM completely (clean slate)
vagrant destroy -f
```

---

## 2. Docker Basics & First Container

Run an Nginx web server container in detached mode with port mapping:

```bash
# Run Nginx in background, mapping host port 9080 to container port 80
docker run --name nginx -d -p 9080:80 nginx

# List running containers
docker ps

# Check the VM's IP address (look for public/bridged network interface)
ip addr show
```

> **Verification**: Open your host machine's browser and navigate to:
> `http://<VM_IP_ADDRESS>:9080`

---

## 3. Building Custom Images (Multi-Stage Build)

A multi-stage build separates the build tools (wget, unzip, compilers) from the production image, keeping the final image lean and secure.

### Step 1: Create Directory and Dockerfile
```bash
mkdir -p images
cd images
touch Dockerfile
```

### Step 2: Dockerfile Definition
Add the following content to `Dockerfile`:

```dockerfile
# Stage 1: Build & Artifact Preparation
FROM ubuntu:latest AS BUILD_IMAGE
RUN apt update && apt install wget unzip -y
RUN wget https://www.tooplate.com/zip-templates/2128_tween_agency.zip
RUN unzip 2128_tween_agency.zip && \
    cd 2128_tween_agency && \
    tar -czf tween.tgz * && \
    mv tween.tgz /root/tween.tgz

# Stage 2: Production Web Server
FROM ubuntu:latest
LABEL "project"="Marketing"
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install apache2 git wget -y
COPY --from=BUILD_IMAGE /root/tween.tgz /var/www/html/
RUN cd /var/www/html/ && tar xzf tween.tgz && rm tween.tgz

WORKDIR /var/www/html/
VOLUME /var/log/apache2
EXPOSE 80

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
```

### Step 3: Build & Run the Custom Image
```bash
# Build image tagged as 'testimg'
docker build -t testimg .

# Run with random host port mapping (-P publishes all exposed ports)
docker run -d -P --name my-marketing-site testimg

# Find the dynamically assigned host port (e.g. 0.0.0.0:32768->80/tcp)
docker ps

# Find IP to test in browser
ip addr show
```

> **Access URL**: `http://<VM_IP_ADDRESS>:<MAPPED_PORT>`

---

## 4. Container & Image Lifecycle (Cleanup)

Commands to stop, remove, and clean up testing containers and images.

```bash
# List all containers (running and stopped)
docker ps -a

# Stop a container by name or container ID
docker stop nginx my-marketing-site

# Remove stopped containers
docker rm nginx my-marketing-site

# List local Docker images
docker images

# Remove an image by ID or repository tag
docker rmi testimg

# (Optional) One-liner to stop and remove all containers
docker stop $(docker ps -aq) 2>/dev/null
docker rm $(docker ps -aq) 2>/dev/null

# Remove unused dangling images and system cache
docker system prune -f
```

---

## 5. Multi-Container Deployment (Docker Compose)

Deploy a multi-tier application stack (such as the vprofile Java Web App with MySQL, Memcached, RabbitMQ, and Tomcat) using Docker Compose.

```bash
# Create and enter working directory
mkdir -p ~/compose
cd ~/compose

# Download the sample multi-container compose file
wget https://raw.githubusercontent.com/devopshydclub/vprofile-project/vp-docker/compose/docker-compose.yml

# Launch all interconnected services in background
docker compose up -d

# Verify all services are healthy and running
docker compose ps
docker ps

# Check host IP
ip addr show

# View live logs from a specific service (e.g. web/app)
docker compose logs -f

# Stop and remove the entire application stack
docker compose down
```

> **Accessing the App**: Look for the public-facing port mapped to the web/proxy service in `docker compose ps` and open `http://<VM_IP_ADDRESS>:<PORT>` in your browser.
