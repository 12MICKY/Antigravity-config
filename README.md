# Google Antigravity Configuration Environment

This repository houses the rules, profiles, custom domain skills, and terminal statusline configuration for **Google Antigravity (`agy`)** in Thiraphat's development environment.

It is structured to support rapid onboarding and automated synchronization of AI guidelines, project scopes, and context boundaries.

---

## Repository Layout

```
.
├── AGENTS.md                  # Custom agent behavioral rules & active project scopes
├── README.md                  # Repository documentation
├── setup.sh                   # Automated, colorized bootstrap script
├── sync.sh                    # Bidirectional local-to-remote sync utility
├── statusline-command.sh      # Highly optimized TUI statusline script
├── skills.tar.gz              # Compressed archive containing all 800+ custom skills
└── systemd/                   # Auto-sync path daemons (Linux environments)
    ├── sync.path
    └── sync.service
```

---

## Quick Start & Installation

To initialize or restore this configuration on any workstation, run the colorized bootstrap script:

```bash
gh repo clone 12MICKY/Antigravity-config ~/antigravity-config
cd ~/antigravity-config
./setup.sh
```

### Bootstrap Process:
1. **Instruction Syncing**: Registers rules to `~/.agents/AGENTS.md` and copies domain-specific skills to `~/.agents/skills/` for context-aware loading.
2. **TUI Interface Setup**: Automates configuration of `~/.gemini/antigravity-cli/settings.json` to link the custom statusline.
3. **Daemon Registration**: Installs and starts the user-level file monitor watcher (via `systemd` if running on Linux).

---

## Statusline Layout

The terminal statusline (`statusline-command.sh`) executes on every interaction loop to present a rich, real-time context display:

`thiraphatsrichit@MacBook-Air-khxng-Thiraphat ❯ Gemini 3.5 Flash (Medium) ❯ antigravity-config main ❯ 5h:█░░░░░░░░░11% ❯ 7d:█░░░░░░░░░12% ❯ A:█░░░░░░░░░12% ❯ 22:05`

### Components:
- **Host Context**: Renders `user@hostname`.
- **Active Model**: Dynamically lists the active LLM engine.
- **Active Repository**: Active directory/repo name.
- **Branch status**: Live Git branch tracker.
- **`5h:` (Context Window)**: Shows the current session's token consumption in the context window.
- **`7d:` & `A:` (Weekly Quota)**: Shows the weekly token quota utilization for the active model.

---

## Bidirectional Auto-Sync

Any configuration edits made by the agent locally in the active rule directories (e.g. `~/.agents/AGENTS.md`) are automatically synced back to this repository and pushed to GitHub.

- **Linux**: Handled transparently by the `antigravity-sync` systemd user path-unit.
- **macOS / Manual**: Sync and push updates at any time by executing:
  ```bash
  ./sync.sh
  ```

---

## Integrated Skill Libraries

This configuration integrates several custom and community-developed skill libraries to enhance the agent's capabilities:

- **Core Homelab & Network Configuration**: Local domain blueprints for Proxmox, Mikrotik routing, PBS, and K3s.
- **12MICKY Personal Skills**: Extracted and compiled from the `12MICKY/claude-skills` repository, providing local workflow optimization and developer context.
- **Context Engineering**: Cloned from `muratcankoylan/Agent-Skills-for-Context-Engineering`.
- **General Claude Skills**: Cloned from `alirezarezvani/claude-skills`.
- **Reverse Engineering**: Cloned from `meirm/reverse-engineering-skill`.
- **Network Automation**: Cloned from `arsallls/claude-network-skills`.

All skills are compiled and packaged directly inside the compressed `skills.tar.gz` archive to optimize memory footprints and speed up repository transactions.

---

## Reference Materials & Learning Logs

This setup is grounded in official, enterprise-grade networking and system administration training materials:

| Document / Training Guide | Core Implementations & Blueprints | Associated Skills |
|---|---|---|
| [MikroTik RouterOS Documentation](https://manual.mikrotik.com/) | <ul><li>Zero-Script Recursive Routing Failover via virtual target hops</li><li>Cloudflare Dynamic DNS API PUT updates using `/tool fetch`</li><li>Automated Discord webhook alerts</li><li>Bridge VLAN Filtering (Hardware Offloaded)</li></ul> | `network-mikrotik`, `network-engineer` |
| [Ubiquiti UEWA Training Guide](https://dl.ubnt.com/guides/training/courses/UEWA_Training_Guide_V2.1.pdf) | <ul><li>Layer-3 AP Adoption via DHCP Option 43 and DNS `unifi` resolution</li><li>Manual SSH `set-inform` binding flow</li><li>Minimum RSSI `-75 dBm` soft-kick threshold for client roaming</li><li>Airtime Fairness and Band Steering optimization</li></ul> | `network-unifi`, `network-engineer` |
| [Proxmox VE Admin Guide](https://pve.proxmox.com/pve-docs/pve-admin-guide.html) | <ul><li>PBS CT 104 datastore backup scheduling and prune policies</li><li>Watchdog High Availability group definitions</li><li>LXC unprivileged mapping and mount points</li></ul> | `proxmox-datacenter`, `proxmox-manager`, `proxmox-backup`, `proxmox-cli` |

---

## Releases & Versioning

- **v1.0.0 (Stable Configuration)**: Packages all 800+ community and environment-specific skills into `skills.tar.gz` for clean Git tracking and instant TUI bootstrap.
- To publish new releases, push a new git tag (`git tag vX.Y.Z && git push origin vX.Y.Z`) and draft the release on the GitHub web portal.
