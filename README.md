# Antigravity Config (`antigravity-config`)

This repository houses the configuration, memory, system instructions, and custom TUI statusline utilities for **Google Antigravity (`agy`)** in Thiraphat's development environment.

## Repository Structure

- **`AGENTS.md`**: Custom workspace rules containing environment profiles, identity constraints, technical coding styles, and behavior directives.
- **`statusline-command.sh`**: A highly optimized terminal status line script designed for the `agy` CLI that outputs user/host, model, active repository, git branch, context usage percentage, and weekly credit quota.
- **`setup.sh`**: Single-command setup helper script that symlinks rules and configures `settings.json`.
- **`sync.sh`**: Daemon-friendly auto-sync script to commit and push changes back to GitHub.
- **`memory/`**: Workspace memory catalog mapping servers, virtualization hosts (Proxmox/ESXi), project specifications (BoldFit, genius-lab, etc.), networks, and workflows.
- **`systemd/`**: Path-watcher configurations for automated rule/script synchronization (Linux environment).

---

## Setup & Installation

To deploy this configuration on a new workstation or restore the environment, clone this repository locally and run the setup script:

```bash
git clone https://github.com/12MICKY/Antigravity-config.git ~/antigravity-config
cd ~/antigravity-config
./setup.sh
```

### What `setup.sh` does:
1. Installs the environment rules to `~/.agents/AGENTS.md` for workspace auto-discovery.
2. Updates `~/.gemini/antigravity-cli/settings.json` to enable and link the custom statusline.
3. Registers and starts the user-level path watcher daemon (`systemd` - Linux only).

---

## Statusline Layout

The custom statusline runs on every CLI action loop. It outputs:

`thiraphatsrichit@MacBook-Air-khxng-Thiraphat ❯ Gemini 3.5 Flash (Medium) ❯ antigravity-config main ❯ 5h:█░░░░░░░░░11% ❯ 7d:█░░░░░░░░░12% ❯ 🅰:█░░░░░░░░░12% ❯ 22:05`

### Component Breakdown:
- **Host & User**: Current local context user/hostname.
- **Model**: Displays active Gemini model in use.
- **Repository / Project**: Active repository name or working directory.
- **Git Branch**: Displays current git branch.
- **`5h:` (Context Usage)**: Visual progress bar representing the current chat context usage percentage (mapped to avoid CLI constraints).
- **`7d:` & `🅰:` (Weekly Quota)**: Displays the weekly remaining token quota for the currently selected model.

---

## Auto-Sync (Linux Servers only)

Any local changes made by the agent to rules (`~/.agents/AGENTS.md`) or the statusline script will be automatically staged, committed, and pushed back to this GitHub repository. This is powered by user-level systemd path units (`sync.path` + `sync.service`).
