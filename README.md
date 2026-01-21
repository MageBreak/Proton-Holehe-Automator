# Proton-Holehe-Automator

A security-focused Bash wrapper for **Holehe** that automates VPN tunneling and intelligent rate-limit bypassing. This tool ensures that OSINT reconnaissance remains private and uninterrupted by managing **Proton VPN identities in real time**.

---

##  Key Features

### VPN Sandwich Methodology
Automatically establishes a secure VPN tunnel **before** the scan begins and collapses it **immediately after** completion.

### D-Bus Error Mitigation
Specifically designed to resolve common `FileNotFound` and `Keyring` errors encountered when running Proton VPN commands via `sudo` on Linux distributions such as **Ubuntu** and **Linux Mint**.

### Automated Identity Rotation
Continuously monitors Holehe output for the `[x] rate-limit` flag and triggers an **instant VPN server rotation** when detected.

### Smart Targeted Retries
Rather than restarting the entire scan, the wrapper:
- Extracts only the **failed modules**
- Re-runs those specific services (e.g., `instagram`, `linkedin`)
- Executes retries under a **new VPN identity**

### Forensic Logging
Generates timestamped investigation logs for:
- Evidence preservation  
- Repeatability  
- Security auditing and incident analysis  

---

## How the Bypass Works

The tool implements a **Detect → Rotate → Retry** logic to overcome IP-based rate limiting.

###  Initial Shielding
Connects to a Proton VPN server (e.g., Netherlands, Japan) before launching the scan.

### Detection
Holehe output is streamed into a temporary buffer where the script watches for the `[x] rate-limit` indicator.

### Intelligent Rotation
Upon detection:
- The current VPN session is terminated
- A fresh Proton VPN server is requested

### Targeted Execution
The previous log is parsed to identify failed services, and only those modules are retried using the new VPN identity.

---

## Requirements & Setup

Refer to **`REQUIREMENTS.md`** for complete installation instructions, including:

- Proton VPN CLI setup
- Required Linux dependencies
- **Critical D-Bus fixes**
- `sudoers` configuration for passwordless VPN automation

---

## Usage

```bash
chmod +x holehewrapper.sh
./holehewrapper.sh target@email.com
