# ⚡ 5-Tier Web Application (Automated Infrastructure as Code)

This module completely automates the multi-VM 5-tier architecture using Vagrant shell provisioners and modular Bash provisioning scripts.

---

## 🏗️ Architecture & VM Topology

```mermaid
flowchart LR
    Browser([Browser]) -->|HTTP :80| Nginx[nginx: 192.168.56.11]
    Nginx -->|Proxy :8080| Tomcat[tomcat: 192.168.56.12]
    Tomcat -->|JDBC :3306| DB[(db: 192.168.56.15)]
    Tomcat -->|Cache :11211| Memcache[memcache: 192.168.56.14]
    Tomcat -->|AMQP :5672| Rabbit[rabbit: 192.168.56.13]
```

| Node           | OS               | Memory  | Provisioner Script | Role                                                  |
| :------------- | :--------------- | :------ | :----------------- | :---------------------------------------------------- |
| **`db`**       | CentOS Stream 9  | 1024 MB | `mysql.sh`         | MariaDB, accounts DB, firewall rules, schema dump     |
| **`memcache`** | CentOS Stream 9  | 512 MB  | `memcache.sh`      | Memcached listener on `0.0.0.0:11211`                 |
| **`rabbit`**   | CentOS Stream 9  | 1024 MB | `rabbitmq.sh`      | Erlang, RabbitMQ server, admin user                   |
| **`tomcat`**   | CentOS Stream 9  | 1024 MB | `tomcat.sh`        | Java 11, Tomcat 9, Maven packaging, WAR deployment    |
| **`nginx`**    | Ubuntu 22.04 LTS | 512 MB  | `nginx.sh`         | Nginx reverse proxy routing requests to `tomcat:8080` |

---

## 📜 Provisioning Scripts Reference

- **[`mysql.sh`](mysql.sh)**: Installs MariaDB server, configures root password and application user (`admin`), sets up firewall rules for port 3306, and imports `db_backup.sql`.
- **[`memcache.sh`](memcache.sh)**: Configures Memcached to bind to `0.0.0.0` and enables systemd service.
- **[`rabbitmq.sh`](rabbitmq.sh)**: Adds package repositories, installs RabbitMQ 3.8 and Erlang, configures users, and starts the service.
- **[`tomcat.sh`](tomcat.sh)**: Configures system user `tomcat`, downloads Tomcat 9 binaries, writes a custom `systemd` unit, clones the source repository, runs `mvn install`, and places `ROOT.war` into `webapps/`.
- **[`nginx.sh`](nginx.sh)**: Installs Nginx, creates reverse proxy virtual host `vproapp`, tests configuration, and enables service.

---

## 🚀 One-Command Deployment

Ensure the `vagrant-hostmanager` plugin is installed:

```bash
vagrant plugin install vagrant-hostmanager
```

Start and provision all 5 virtual machines:

```bash
vagrant up
```

---

## 🧪 Validation & Verification

1. Check HTTP response:
   ```bash
   curl -I http://192.168.56.11
   ```
2. Open your web browser at:
   ```
   http://192.168.56.11
   ```
3. Test login:
   - **Username**: `admin_vp`
   - **Password**: `admin_vp`

---

## 🧹 Teardown

```bash
# Power off all VMs
vagrant halt

# Destroy all VMs and free disk space
vagrant destroy -f
```
