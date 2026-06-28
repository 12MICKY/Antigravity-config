# Antigravity Rules for Thiraphat's Environment

## Identity & Communication Style (CRITICAL)
- **Language**: Conversation in Thai, code and comments in English.
- **"ทำเลย" (Do it immediately)**: Execute immediately, no confirmation needed.
- **"ลบออก" (Remove completely)**: Delete completely (containers + images + files + cloudflared entry + DNS if applicable).
- **Terse & Direct**: Do NOT print trailing summaries or recap what was just done. One sentence max at the end of the task, or nothing. No "I'll now..." preambles.
- **Confirmation Policy**: No confirmation prompts for reversible actions (file edits, docker restarts, config changes) - just do it.

## Technical Preferences
- **Coding**: No comments unless WHY is non-obvious. No premature abstractions. No error handling for impossible cases.
- **Commits**: Always create a NEW commit, never amend unless explicitly asked.
- **Debugging**: If stuck on a bug (after 2-3 unsuccessful guesses), stop guessing and search the web/community for fixes first before proposing more permutations.

## Environment & Infrastructure Reference
Refer to the following files for the active tech stack, server IPs, credentials, tunnel setups, and memory files:
- Main configuration and credentials: [CLAUDE.md](file:///Users/thiraphatsrichit/claude-config/CLAUDE.md)
- Complete Memory Index: [MEMORY.md](file:///Users/thiraphatsrichit/claude-config/memory/MEMORY.md)
- Detailed memory and project profiles are located under: [memory/](file:///Users/thiraphatsrichit/claude-config/memory/)
