# 🚀 DevOps Engineering Lab & Multi-Tier Projects

<div align="center">

![Linux](https://img.shields.io/badge/Linux-Ubuntu%20%7C%20CentOS-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![VMs](https://img.shields.io/badge/Virtual%20Machines-Multi--VM%20Architecture-blueviolet?style=for-the-badge&logo=virtualbox)
![Vagrant](https://img.shields.io/badge/Vagrant-1563FF?style=for-the-badge&logo=vagrant)
![AWS](https://img.shields.io/badge/AWS-Cloud%20Services-232F3E?style=for-the-badge&logo=amazon-aws)
![Domains](https://img.shields.io/badge/Domains%20%26%20DNS-Hostmanager%20%7C%20Route53-orange?style=for-the-badge&logo=cloudflare)
<br/>
![Nginx](https://img.shields.io/badge/Nginx-Reverse%20Proxy-009639?style=for-the-badge&logo=nginx)
![Tomcat](https://img.shields.io/badge/Tomcat-App%20Server-F8DC75?style=for-the-badge&logo=apache-tomcat&logoColor=black)
![MySQL/MariaDB](https://img.shields.io/badge/MySQL%20%2F%20MariaDB-Database-003545?style=for-the-badge&logo=mariadb)
![Memcache](https://img.shields.io/badge/Memcached-In--Memory%20Cache-4B8BBE?style=for-the-badge)
![RabbitMQ](https://img.shields.io/badge/RabbitMQ-Message%20Broker-FF6600?style=for-the-badge&logo=rabbitmq)
![SonarQube](https://img.shields.io/badge/SonarQube-Code%20Quality-4E9BCD?style=for-the-badge&logo=sonarqube)

<p align="center">
  <b>A continuous, hands-on journey from local multi-VM virtualized environments to automated enterprise infrastructure, code analysis, and cloud delivery.</b>
</p>

</div>

---

> [!NOTE]
>
> ### 🚧 Project Status & Attribution
>
> This repository is an evolving DevOps portfolio and learning hub developed as part of the course **`DevOps Beginners to Advanced`** by **Imran Teli**.
> Special credits to **Imran Teli** and his project repository: [devopshydclub/vprofile-project](https://github.com/devopshydclub/vprofile-project). Modules are continuously added as separate feature/project branches as I progress through real-world DevOps architectures.

---

## 🛠️ Core Technologies & Tooling

| Category                 | Technologies & Tools                                     | Purpose in Projects                                                                     |
| :----------------------- | :------------------------------------------------------- | :-------------------------------------------------------------------------------------- |
| **Virtualization & OS**  | **Linux** (CentOS 7, Ubuntu 22.04), **VMs**, **Vagrant** | Multi-node guest provisioning, private networking, and host-guest synchronization.      |
| **Web & App Servers**    | **Nginx**, **Apache Tomcat**                             | Reverse proxy, SSL termination, load balancing, and Java Servlet/WAR container hosting. |
| **Data & Cache**         | **MySQL / MariaDB**, **Memcached**                       | Relational data persistence, schema seeding, and sub-millisecond memory caching.        |
| **Messaging**            | **RabbitMQ**                                             | Asynchronous message broker, task queue, and decouple inter-service dependencies.       |
| **Cloud & Networking**   | **AWS**, **Domains & DNS**                               | Cloud infrastructure lift-and-shift, domain routing, and internal host resolution.      |
| **Code Quality & CI/CD** | **SonarQube (Sonar)**, **Maven**, **Git**                | Static code analysis, quality gates, dependency packaging, and version control.         |

---

## 📚 Project Modules & Branch Index

Every project module lives in its own dedicated Git branch with isolated configurations, scripts, and documentation:

| Module | Branch Name                                                                         |    Status    | Tech Stack                                                   | Highlights                                                                     | Switch Command                       |
| :----: | :---------------------------------------------------------------------------------- | :----------: | :----------------------------------------------------------- | :----------------------------------------------------------------------------- | :----------------------------------- |
| **01** | [`multi-vm`](#-module-01-multi-vm)                                                  | ✅ Completed | Linux (CentOS, Ubuntu), VMs, Vagrant, Domains                | Dual-VM setup hosting static web template & LAMP WordPress stack.              | `git checkout multi-vm`              |
| **02** | [`local-setup-manual`](#-module-02-local-setup-manual)                              | ✅ Completed | Linux, VMs, MySQL/MariaDB, Memcache, RabbitMQ, Tomcat, Nginx | 5-Tier enterprise Java stack configured manually step-by-step.                 | `git checkout local-setup-manual`    |
| **03** | [`local-setup-automated`](#-module-03-local-setup-automated)                        | ✅ Completed | Vagrant Shell Provisioning, Bash, Linux Services             | Fully automated deployment of the 5-tier architecture via Bash scripts.        | `git checkout local-setup-automated` |
| **04** | [`containers-intro`](https://github.com/BolohanAndrei/DevOps/tree/containers-intro) | ✅ Completed | Docker, Multi-Stage Builds, Docker Compose, Vagrant          | Introduction to containerization, multi-stage Dockerfiles, and Docker Compose. | `git checkout containers-intro`      |

---

## 🏛️ System Architectures

### 1. Multi-VM Setup (`multi-vm`)

- **`website` (192.168.33.15)**: CentOS 7 with Apache HTTPD serving a responsive web template.
- **`wordpress` (192.168.33.16)**: Ubuntu 22.04 LTS running a full LAMP stack with WordPress and MySQL.

### 2. Enterprise 5-Tier Web Architecture (`local-setup-manual` & `local-setup-automated`)

```mermaid
flowchart LR
    Client([User / Browser]) -->|Port 80| NGINX[Nginx Reverse Proxy\n192.168.56.11]
    NGINX -->|Port 8080| TOMCAT[Tomcat App Server\n192.168.56.12]
    TOMCAT -->|Port 3306| DB[(MySQL / MariaDB\n192.168.56.15)]
    TOMCAT -->|Port 11211| MEMCACHE[Memcached Cache\n192.168.56.14]
    TOMCAT -->|Port 5672| RMQ[RabbitMQ Broker\n192.168.56.13]
```

---

## 💻 Prerequisites & Environment Setup

Ensure the following tools are installed on your workstation:

- [VirtualBox](https://www.virtualbox.org/)
- [Vagrant](https://developer.hashicorp.com/vagrant/install)
- Vagrant Hostmanager Plugin:
  ```bash
  vagrant plugin install vagrant-hostmanager
  ```

---

## 🧭 How to Navigate & Run Projects

Each branch is structured so you can run the project directly at the root:

```bash
# 1. Clone the repository
git clone https://github.com/BolohanAndrei/DevOps.git
cd DevOps

# 2. View all project branches
git branch -a

# 3. Switch into a project branch
git checkout multi-vm
# or
git checkout local-setup-manual
# or
git checkout local-setup-automated

# 4. Launch the environment
vagrant up
```

---

## 📌 Repository Roadmap

- [x] Multi-VM basic hosting (Website + WordPress LAMP)
- [x] Multi-tier Enterprise Architecture (Manual step-by-step: Nginx, Tomcat, RabbitMQ, Memcache, MySQL)
- [x] Infrastructure as Code (Automated Bash provisioning)
- [x] Containerization & Docker Compose (Docker containers)

---

## 🎓 Course & Repository Credits

- **Course**: Developed following the **`DevOps Beginners to Advanced`** course by **Imran Teli**.
- **Source Repository**: Special credits to **Imran Teli** and his project repository: [devopshydclub/vprofile-project](https://github.com/devopshydclub/vprofile-project).
