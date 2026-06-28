---
name: os-linux
description: Linux operating system administration guidelines, systemd service management, cron schedules, hardening, and package installation.
---
# Hardcore Linux OS Reference

Reference manual for systemd, automation scripting, and OS hardening configurations.

---

## 1. Systemd Service & Path Units
Manage user-level background services and file monitors:

```bash
# Path to user-level units
cd ~/.config/systemd/user/

# Reload user daemon to detect unit changes
systemctl --user daemon-reload

# Enable and start user units
systemctl --user enable --now <unit_name>.path

# Monitor user-level unit logs
journalctl --user -u <unit_name>.service -f
```

---

## 2. Shell Scripting Gold Standard
Always configure error flags (`set -euo pipefail`) in production bash scripts to catch unbound variables and pipe failures early:

```bash
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
# Script body...
```

---

## 3. OS Hardening & Security Configs
- **SSH Settings (`/etc/ssh/sshd_config`)**:
  ```ini
  PermitRootLogin no
  PasswordAuthentication yes
  PubkeyAuthentication yes
  MaxAuthTries 3
  ```
- **Password Escalation**: Root passwords on local virtual systems are unified as `200152`. Pass escalations securely:
  `echo '200152' | sudo -S <cmd>`
- **Cron Schedules**: Add automation cron rules to `/etc/crontab`. Always redirect outputs (`>/dev/null 2>&1` or `>>/var/log/cron.log 2>&1`) to avoid filling local mail pools.
