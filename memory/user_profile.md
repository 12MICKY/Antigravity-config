---
name: user-profile
description: "Thiraphat — developer in Thailand, Docker/Python/Node/Go stack, direct action style"
metadata: 
  node_type: memory
  type: user
  originSessionId: f39abe6d-5c79-429f-8b8d-77c106836446
---

Developer based in Thailand. Full name: Thiraphat. Email: mixgarden28@gmail.com.

**Stack:** Python 3.13 (automation, bots, data), Node.js v24 / Next.js (web, APIs), Go 1.24 (systems/networking), Docker + Swarm (all infra), Arduino/C++ (hardware).

**Environment:** Ubuntu Linux 25.10 "questing" (CLAUDE.md says 24.04 but `apt` repos are `questing`), kernel 6.17, zsh + Oh My Zsh + Powerlevel10k, VS Code primary IDE, Claude Code CLI.

**Communication style:**
- Speaks Thai in conversation; writes code and comments in English
- "ทำเลย" = just do it, no confirmation needed
- "ลบออก" = delete completely (container + image + files + cloudflared + DNS)
- Wants concise, direct output — no re-summarizing, no trailing recaps
- Prefers things deployed and working immediately

**Infrastructure he manages:**
- 10.33.1.34 (prod / K3s control-plane), 10.33.1.32 (dev / K3s worker)
- SSH password: 200152 (used with sshpass)
- Cloudflare tunnel for *.thiraphat.work

**Coding preferences:**
- No comments unless WHY is non-obvious
- No premature abstractions
- No error handling for impossible cases
- New commits always — never amend
