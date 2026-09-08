# 📦 Multi-VM Environment (Web & WordPress)

This module sets up two isolated virtual machines using Vagrant and VirtualBox, illustrating private networking, host customization, and service provisioning.

---

## 🏗️ Topology & Inventory

| VM Name | IP Address | OS Box | Service Stack |
| :--- | :--- | :--- | :--- |
| **website** | `192.168.33.15` | CentOS 7 (`geerlingguy/centos7`) | Apache HTTPD, HTML5 Orbital Template |
| **wordpress** | `192.168.33.16` | Ubuntu 22.04 LTS (`ubuntu/jammy64`) | Apache2, PHP 8.1, MySQL 8.0, WordPress |

---

## 🚀 Quickstart

```bash
# Spin up both virtual machines
vagrant up

# Or spin up one individually
vagrant up website
vagrant up wordpress
```

---

## 🧪 Verification & Testing

- **Static Website**: Open `http://192.168.33.15` in your browser.
- **WordPress Site**: Open `http://192.168.33.16` in your browser to complete the WordPress setup wizard.
- **SSH into nodes**:
  ```bash
  vagrant ssh website
  vagrant ssh wordpress
  ```

---

## 🧹 Teardown

```bash
# Suspend or stop VMs to conserve memory
vagrant halt

# Destroy VMs when finished
vagrant destroy -f
```
