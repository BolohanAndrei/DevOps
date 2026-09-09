# 🛠️ Emart Microservices: Commands & Troubleshooting Guide

This guide contains the complete operational workflow, configurations, and troubleshooting solutions for containerizing and deploying the **Emart** polyglot microservices stack using **Docker**, **Docker Compose**, and **Nginx**.

---

## 📑 Table of Contents

1. [VM Environment Preparation](#1-vm-environment-preparation)
2. [Tested Configuration Files](#2-tested-configuration-files)
   - [2.1 javaapi/Dockerfile (Optimized with Maven Cache)](#21-javaapidockerfile-optimized-with-maven-cache)
   - [2.2 docker-compose.yml (With Host Build Networking)](#22-docker-composeyml-with-host-build-networking)
3. [Starting the Stack & Verification](#3-starting-the-stack--verification)
4. [Troubleshooting Playbook (Common Errors & Solutions)](#4-troubleshooting-playbook)
   - [4.1 Error: `docker.io/library/openjdk:8: not found`](#41-error-dockeriolibraryopenjdk8-not-found)
   - [4.2 Error: Maven Dependency Download Timeouts (`byte-buddy`, `apache.pom`)](#42-error-maven-dependency-download-timeouts-byte-buddy-apachepom)
   - [4.3 Error: Docker Layer IPv6 Connection Timeout](#43-error-docker-layer-ipv6-connection-timeout)
   - [4.4 Error: `go-yaml load error ... did not find expected key`](#44-error-go-yaml-load-error--did-not-find-expected-key)
5. [Housekeeping & Teardown](#5-housekeeping--teardown)

---

## 1. VM Environment Preparation

Before launching Docker Compose, ensure the host VM has Docker and the Compose plugin ready:

```bash
# Start and SSH into the Vagrant VM
vagrant up
vagrant ssh

# Verify Docker and Docker Compose versions
docker --version
docker compose version
```

---

## 2. Tested Configuration Files

### 2.1 javaapi/Dockerfile (Optimized with Maven Cache)

This Dockerfile solves both the **retired OpenJDK 8 image** issue and the **slow/dropping Maven dependency download** issue by using persistent caching and extended wagon timeouts:

```dockerfile
# syntax=docker/dockerfile:1
FROM maven:3.8-eclipse-temurin-8 AS BUILD_IMAGE

WORKDIR /usr/src/app/
COPY ./ /usr/src/app/

# Enable persistent Maven cache & increase network timeouts to 60s
RUN --mount=type=cache,target=/root/.m2 mvn install -DskipTests \
    -Dmaven.wagon.http.retryHandler.count=10 \
    -Dmaven.wagon.http.pool=false \
    -Dmaven.wagon.http.timeout=60000 \
    -Dmaven.wagon.rto=60000

FROM eclipse-temurin:8-jdk

WORKDIR /usr/src/app/
# Copy the compiled JAR artifact from the build stage
COPY --from=BUILD_IMAGE /usr/src/app/target/book-work-0.0.1-SNAPSHOT.jar ./book-work-0.0.1.jar

EXPOSE 9000
ENTRYPOINT ["java", "-jar", "book-work-0.0.1.jar"]
```

---

### 2.2 docker-compose.yml (With Host Build Networking)

Using `network: host` for build steps stops Docker from throttling `npm install` and `mvn install` through virtual bridge adapters:

```yaml
services:
  client:
    build:
      context: ./client
      network: host
    ports:
      - "4200:4200"
    container_name: client
    depends_on:
      - api
      - webapi

  api:
    build:
      context: ./nodeapi
      network: host
    ports:
      - "5000:5000"
    restart: always
    container_name: api
    depends_on:
      - emongo

  webapi:
    build:
      context: ./javaapi
      network: host
    ports:
      - "9000:9000"
    restart: always
    container_name: webapi
    depends_on:
      - emartdb

  nginx:
    restart: always
    image: nginx:latest
    container_name: nginx
    volumes:
      - "./nginx/default.conf:/etc/nginx/conf.d/default.conf"
    ports:
      - "80:80"
    depends_on:
      - client
      - api
      - webapi

  emongo:
    image: mongo:4
    container_name: emongo
    environment:
      - MONGO_INITDB_DATABASE=epoc
    ports:
      - "27017:27017"

  emartdb:
    image: mysql:8.0.33
    container_name: emartdb
    ports:
      - "3306:3306"
    environment:
      - MYSQL_ROOT_PASSWORD=emartdbpass
      - MYSQL_DATABASE=books
```

---

## 3. Starting the Stack & Verification

```bash
# Navigate to the project directory
cd ~/emartapp

# Build images and start services in background
docker compose up -d --build

# Check the status of all running microservices
docker compose ps

# View live container logs
docker compose logs -f
```

---

## 4. Troubleshooting Playbook

### 4.1 Error: `docker.io/library/openjdk:8: not found`

* **Cause**: Docker Hub retired the legacy `openjdk:8` official repository.
* **Fix**: Find and replace `openjdk:8` with `eclipse-temurin:8-jdk`:

```bash
# 1. Search for Dockerfiles referencing the old image
grep -r "openjdk:8" ~/emartapp/

# 2. Update automatically via sed
sed -i 's/openjdk:8/eclipse-temurin:8-jdk/g' ~/emartapp/javaapi/Dockerfile
```

---

### 4.2 Error: Maven Dependency Download Timeouts (`byte-buddy`, `apache.pom`)

```text
[ERROR] Could not transfer artifact net.bytebuddy:byte-buddy:jar:1.10.11: GET request failed
```

* **Cause**: Maven's default 10-second timeout drops connections on slower virtual networks, and Docker throws away downloaded JARs whenever a build fails.
* **Fix**:
  1. Add `--mount=type=cache,target=/root/.m2` to the `RUN mvn install` step in `javaapi/Dockerfile`.
  2. Pass `-Dmaven.wagon.http.timeout=60000 -Dmaven.wagon.rto=60000` to extend the timeout to 60 seconds.
  3. Add `network: host` under the `webapi` and `client` build blocks in `docker-compose.yml`.

---

### 4.3 Error: Docker Layer IPv6 Connection Timeout

```text
ERROR: failed to copy: read tcp [...]:56518->[...]:443: read: connection timed out
```

* **Cause**: Docker is attempting to pull images over an unroutable or blocked IPv6 path on the host adapter.
* **Fix**: Force IPv4 and set Google/Cloudflare DNS in the VM:

```bash
# 1. Prioritize IPv4 over IPv6 in DNS queries
sudo sed -i 's/#precedence ::ffff:0:0\/96  100/precedence ::ffff:0:0\/96  100/' /etc/gai.conf

# 2. Disable IPv6 kernel routing
sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1

# 3. Configure Docker DNS and MTU (1400 prevents packet fragmentation)
sudo tee /etc/docker/daemon.json <<EOF
{
  "dns": ["8.8.8.8", "1.1.1.1"],
  "mtu": 1400
}
EOF

# 4. Restart Docker
sudo systemctl restart docker

# 5. Pre-pull images cleanly
docker compose pull
```

---

### 4.4 Error: `go-yaml load error ... did not find expected key`

* **Cause**: TAB characters (`\t`) were accidentally inserted into `docker-compose.yaml` instead of spaces. YAML strictly forbids tabs.
* **Fix**: Replace all tabs with 2 spaces:

```bash
sed -i 's/\t/  /g' docker-compose.yaml
```

> **Note**: If line 1 continues to error, you can safely delete `version: "3.8"` entirely; modern Docker Compose does not require a version key.

---

```bash
# 1. Locate the file
find / -name "*docker-compose*" 2>/dev/null

# 2. Navigate into the project folder
cd ~/emartapp

# 3. Confirm file existence
ls -la docker-compose*
```

---

## 5. Housekeeping & Teardown

```bash
# Stop all running containers
docker compose stop

# Stop containers and remove internal networks
docker compose down

# Full clean reset (removes database volumes and fresh start)
docker compose down -v
```
