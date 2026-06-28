---
name: os
description: Operating system diagnostics, cross-platform compatibility (macOS/Linux), filesystems, permissions, and security parameters.
---
# OS Skill

Instructions for OS-level management:
- **Cross-Platform Compatibility**: Local shell environment is macOS, while target servers are Ubuntu Linux. Adjust commands (e.g. systemctl vs launchd, sed options) accordingly.
- **Permissions**: Respect file permissions, make shell scripts executable (`chmod +x`), and handle security shims for sensitive binaries (e.g. keychains).
- **Diagnostics**: Inspect system resources, processes, and memory limits (`top`, `df -h`, `mem`) to troubleshoot performance bottlenecks.
- **Filesystems**: Manage file storage structures (e.g., K3s dynamic volumes, Proxmox storage backends, and local/remote directories) securely.
