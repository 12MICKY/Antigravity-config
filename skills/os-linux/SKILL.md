---
name: os-linux
description: Linux operating system administration guidelines, systemd service management, cron schedules, hardening, and package installation.
---
# Linux Operating System Reference

Instructions for operating, hardening, and configuring Linux instances:
- **Systemd Service Management**:
  - Edit services: `sudo systemctl edit <service_name>`
  - Reload config: `sudo systemctl daemon-reload`
  - Restart/Start: `sudo systemctl restart <service_name>`
- **Cron Automation**: Add cron jobs to `/etc/crontab` or `crontab -e`. Ensure output paths redirection (`>/dev/null 2>&1`) is set to prevent syslog bloat.
- **Hardening**: Disable root SSH login, enforce key authentication, and audit ports periodically.
- **Automation Scripts**: Write robust shell scripts with `set -euo pipefail` for error tolerance.
