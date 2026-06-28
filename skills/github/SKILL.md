---
name: github
description: Rules for Git operations, branching strategies, commit messages, pull requests, and GitHub Actions self-hosted runners.
---
# GitHub Skill

Instructions for managing repositories and actions:
- **Commits**: Always create a NEW commit. NEVER amend unless explicitly requested by the user.
- **Push Protection**: Mask or remove secrets/tokens from source code before pushing to avoid Push Protection blocks.
- **Runners**: Manage self-hosted GitHub Actions runners deployed in K3s (e.g. node-34-custom, node-34-pinggps, node-34-grafana, node-34-telegram).
- **Branching**: Follow standard Git flows (e.g., prefixing feature branches with `feature/`).
