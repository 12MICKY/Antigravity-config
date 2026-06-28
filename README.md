# Google Antigravity Configuration Environment

This repository provides a template for managing workspace rules, domain-specific custom skills, and terminal statusline configurations for the **Google Antigravity (`agy`)** CLI.

It is designed to be fully open-source, forkable, and easily customized for any hypervisor, container, or network administration environment without exposing sensitive local network coordinates or credentials.

---

## Repository Layout

```
.
├── .gitignore                 # Standard file exclusions (ignoring scratch and DS_Store)
├── AGENTS.md                  # Template for agent persona rules and system constraints
├── README.md                  # Repository documentation and deployment guide
├── setup.sh                   # Automated, colorized workstation bootstrap script
├── sync.sh                    # Bidirectional local-to-remote sync utility
├── statusline-command.sh      # Highly optimized TUI statusline script
├── skills.tar.gz              # Compressed archive containing custom skills
└── systemd/                   # Auto-sync path daemons (Linux environments)
    ├── sync.path
    └── sync.service
```

---

## Quick Start & Installation

To initialize or restore this configuration on your workstation, clone the repository and run the bootstrap script:

```bash
gh repo clone 12MICKY/Antigravity-config ~/antigravity-config
cd ~/antigravity-config
./setup.sh
```

### Bootstrap Process:
1. **Instruction Syncing**: Registers rules to `~/.agents/AGENTS.md` and unpacks custom skills into `~/.agents/skills/` for context-aware loading.
2. **TUI Interface Setup**: Automates configuration of `~/.gemini/antigravity-cli/settings.json` to link the custom statusline.
3. **Daemon Registration**: Installs and starts the user-level file monitor watcher (via `launchd` on macOS or `systemd` on Linux).

---

## Statusline Layout

The terminal statusline (`statusline-command.sh`) executes on every interaction loop to present a rich, real-time context display:

`user@workstation ❯ Active Model ❯ current-repo main ❯ 5h:█░░░░░░░░░11% ❯ 7d:█░░░░░░░░░12% ❯ A:█░░░░░░░░░12% ❯ 12:00`

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

- **macOS**: Handled natively by the `com.thiraphat.antigravity-sync` launchd agent.
- **Linux**: Handled transparently by the `antigravity-sync` systemd user path-unit.
- **Manual**: Sync and push updates at any time by executing:
  ```bash
  ./sync.sh
  ```

---

## Security & Privacy Guidelines (Forking)

When forking this repository to build your own configuration environment:

1. **Placeholder Enforcement**: Never commit raw API tokens, system credentials, or public IP addresses. Replace sensitive parameters with placeholders (e.g., `CLOUDFLARE_API_TOKEN` or `127.0.0.1`).
2. **Untracked Scratch Directory**: The `scratch/` folder is explicitly git-ignored. Use it for temporary logs, credential downloads, or raw text blocks that should not be pushed to GitHub.
3. **Local Overrides**: Keep machine-specific settings inside local environment vars and restrict access permissions on sensitive configuration folders.

---

## Integrated Skill Libraries

This repository serves as a hub integrating several custom and community-developed skill libraries:

- **Core Homelab & Network Configuration**: Local domain blueprints for Proxmox, Mikrotik routing, PBS, and K3s.
- **12MICKY Personal Skills**: Extracted and compiled from the `12MICKY/claude-skills` repository, providing local workflow optimization.
- **Context Engineering**: Cloned from `muratcankoylan/Agent-Skills-for-Context-Engineering`.
- **General Claude Skills**: Cloned from `alirezarezvani/claude-skills`.
- **Reverse Engineering**: Cloned from `meirm/reverse-engineering-skill`.
- **Network Automation**: Cloned from `arsallls/claude-network-skills`.

All skills are compiled and packaged directly inside the compressed `skills.tar.gz` archive to optimize memory footprints and speed up repository transactions.

---

## Releases & Versioning

- **v1.0.0 (Stable Configuration)**: Packages all 800+ community and environment-specific skills into `skills.tar.gz` for clean Git tracking and instant TUI bootstrap.
- To publish new releases, push a new git tag (`git tag vX.Y.Z && git push origin vX.Y.Z`) and draft the release on the GitHub web portal.
