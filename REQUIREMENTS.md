# Installation & System Configuration Guide

This document details the step-by-step setup required to run the `holehewrapper.sh` script from scratch. It covers tool installation, credential management, and the critical system-level fixes discovered during development on an ASUS TUF Linux environment.

---

## 1. Core Tool Installation

The project relies on two primary tools for OSINT and identity management.

### 1.1 Holehe (OSINT Engine)
Holehe is an OSINT tool that checks whether an email address is associated with accounts across 120+ online services.

**Installation:**
```bash
pip3 install holehe
```
###1.2 Proton VPN CLI (v0.1.4)

The Proton VPN CLI is used to establish and rotate secure tunnels automatically during reconnaissance.

**Installation:**
```
# Install the official repository package
sudo apt install ./protonvpn-stable-release_1.0.10_all.deb
sudo apt update
sudo apt install protonvpn-cli
```

**Verification:**
```
protonvpn --version
```
---
## 2. Solving the D-Bus & Keyring Errors
### The Problem

When executed via sudo, Python-based CLI tools such as Proton VPN frequently crash with errors including FileNotFoundError, EOFError, and "D-Bus session unavailable". This occurs because sudo does not inherit the user's desktop D-Bus session, which Proton VPN relies on for credential storage and inter-process communication.

The Solution:
```
dbus-run-session
```
The wrapper script uses dbus-run-session to spawn a temporary virtual desktop bus. This simulates a logged-in GUI session and allows Proton VPN to access the GNOME Keyring and store credentials without crashing under sudo.

---

## 3. System Permissions (Sudoers Configuration)

To allow automated VPN connect and disconnect operations without password prompts, the sudoers file must be updated.

**Edit sudoers:**
   ```
   bash
   sudo visudo
   ```
  Add the following line to the bottom of the file (replace YOUR_USERNAME with your actual Linux username):

  ```
YOUR_USERNAME ALL=(ALL) NOPASSWD: /usr/bin/dbus-run-session, /usr/bin/protonvpn
```

## 4. Initializing Credentials (One-Time Setup)

Because the script operates inside a virtual D-Bus session, Proton VPN credentials must be "seeded" once for the root context.

**Sign in:**
```
sudo dbus-run-session protonvpn signin your_email@proton.me
```

**GNOME Keyring Prompt: If a "Create New Keyring" dialog appears:**
- Leave the password fields blank.
- Click Continue.
- Confirm Continue again on the unencrypted warning.
