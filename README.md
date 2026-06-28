# Google Antigravity Configuration Environment

This repository houses the rules, profiles, custom domain skills, and terminal statusline configuration for **Google Antigravity (`agy`)** in Thiraphat's development environment.

It is structured to support rapid onboarding and automated synchronization of AI guidelines, project scopes, and context boundaries.

---

## 🗂 Repository Layout

```
.
├── AGENTS.md                  # Custom agent behavioral rules & active project scopes
├── README.md                  # Repository documentation
├── setup.sh                   # Automated, colorized bootstrap script
├── sync.sh                    # Bidirectional local-to-remote sync utility
├── statusline-command.sh      # Highly optimized TUI statusline script
├── skills/                    # Specialized agent instruction sets (triggered by context)
│   ├── cli/                   # TUI configs & settings schema guides
│   ├── cmd/                   # Zsh aliases, custom CLI scripts, & PATH guides
│   ├── data-center-engineer/  # Proxmox clusters, PBS backup, & Swarm stacks
│   ├── designer/              # Styling guidelines, typography, & UI/UX tokens
│   ├── game-developer/        # Unity engine templates & logic optimization
│   ├── github/                # Git workflow, PR strategies, & CI/CD self-hosted runners
│   ├── linux/                 # Systemd configurations & general OS utilities
│   ├── network-engineer/      # Mikrotik CRS configs, Netwatch, & WireGuard VPNs
│   ├── os/                    # Filesystems, diagnostics, & cross-platform configs
│   ├── project-manager/       # Milestones, timelines, & scope breakdowns
│   └── server/                # Production/Dev cluster separation rules
└── systemd/                   # Auto-sync path daemons (Linux environments)
    ├── sync.path
    └── sync.service
```

---

## ⚡ Quick Start & Installation

To initialize or restore this configuration on any workstation, run the colorized bootstrap script:

```bash
git clone https://github.com/12MICKY/Antigravity-config.git ~/antigravity-config
cd ~/antigravity-config
./setup.sh
```

### Bootstrap Process:
1. **Instruction Syncing**: Registers rules to `~/.agents/AGENTS.md` and copies domain-specific skills to `~/.agents/skills/` for context-aware loading.
2. **TUI Interface Setup**: Automates configuration of `~/.gemini/antigravity-cli/settings.json` to link the custom statusline.
3. **Daemon Registration**: Installs and starts the user-level file monitor watcher (via `systemd` if running on Linux).

---

## 🖥 Statusline Layout

The terminal statusline (`statusline-command.sh`) executes on every interaction loop to present a rich, real-time context display:

`thiraphatsrichit@MacBook-Air-khxng-Thiraphat ❯ Gemini 3.5 Flash (Medium) ❯ antigravity-config main ❯ 5h:█░░░░░░░░░11% ❯ 7d:█░░░░░░░░░12% ❯ 🅰:█░░░░░░░░░12% ❯ 22:05`

### Components:
- **Host Context**: Renders `user@hostname`.
- **Active Model**: Dynamically lists the active LLM engine.
- **Active Repository**: Active directory/repo name.
- **Branch status**: Live Git branch tracker.
- **`5h:` (Context Window)**: Shows the current session's token consumption in the context window.
- **`7d:` & `🅰:` (Weekly Quota)**: Shows the weekly token quota utilization for the active model.

---

## 🔄 Bidirectional Auto-Sync

Any configuration edits made by the agent locally in the active rule directories (e.g. `~/.agents/AGENTS.md`) are automatically synced back to this repository and pushed to GitHub.

- **Linux**: Handled transparently by the `antigravity-sync` systemd user path-unit.
- **macOS / Manual**: Sync and push updates at any time by executing:
  ```bash
  ./sync.sh
  ```
